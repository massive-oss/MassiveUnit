/****
* Copyright 2017 Massive Interactive. All rights reserved.
* 
* Redistribution and use in source and binary forms, with or without modification, are
* permitted provided that the following conditions are met:
* 
*    1. Redistributions of source code must retain the above copyright notice, this list of
*       conditions and the following disclaimer.
* 
*    2. Redistributions in binary form must reproduce the above copyright notice, this list
*       of conditions and the following disclaimer in the documentation and/or other materials
*       provided with the distribution.
* 
* THIS SOFTWARE IS PROVIDED BY MASSIVE INTERACTIVE ``AS IS'' AND ANY EXPRESS OR IMPLIED
* WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
* FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL MASSIVE INTERACTIVE OR
* CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
* CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
* ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
* ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
* 
* The views and conclusions contained in the software and documentation are those of the
* authors and should not be interpreted as representing official policies, either expressed
* or implied, of Massive Interactive.
****/

package massive.munit;
import haxe.Constraints.Function;
import massive.munit.Assert;
import massive.munit.ITestResultClient;
import massive.munit.async.AsyncDelegate;
import massive.munit.async.AsyncFactory;
import massive.munit.async.AsyncTimeoutException;
import massive.munit.async.IAsyncDelegateObserver;
import massive.munit.async.MissingAsyncDelegateException;
import massive.munit.async.UnexpectedAsyncDelegateException;
import massive.munit.util.Timer;
import massive.munit.TestResult;

#if neko
import neko.vm.Thread;
#elseif cpp
import cpp.vm.Thread;
#elseif java
import java.vm.Thread;
#end

using Lambda;

/**
 * Runner used to execute one or more suites of unit tests.
 *
 * <pre>
 * // Create a test runner with client (PrintClient) and pass it a collection of test suites
 * public class TestMain
 * {
 *     public function new()
 *     {
 *         var suites = new Array<Class<massive.munit.TestSuite>>();
 *         suites.push(TestSuite);
 *
 *         var runner:TestRunner = new TestRunner(new PrintClient());
 *         runner.run(suites);
 *     }
 * }
 *
 * // A test suite with one test class (MathUtilTest)
 * class TestSuite extends massive.unit.TestSuite
 * {
 *     public function new()
 *     {
 *          add(MathUtilTest);
 *     }
 * }
 *
 * // A test class with one test case (testAdd)
 * class MathUtilTest
 * {
 *     @Test
 *     public function testAdd():Void
 *     {
 *         Assert.areEqual(2, MathUtil.add(1,1));
 *     }
 * }
 * </pre>
 * @author Mike Stead
 * @see TestSuite
 */
class TestRunner implements IAsyncDelegateObserver
{
	static var emptyParams:Array<Dynamic> = [];
	
    /**
     * The currently active TestRunner.  Will be null if no test is executing.
     **/
    public static var activeRunner(default, null):TestRunner;

    /**
     * Handler called when all tests have been executed and all clients
     * have completed processing the results.
     */
    public var completionHandler:Bool->Void;

    public var clientCount(get, null):Int;
    function get_clientCount():Int { return clients.length; }

    public var running(default, null):Bool = false;
    var testCount:Int;
    var failCount:Int;
    var errorCount:Int;
    var passCount:Int;
    var ignoreCount:Int;
    var clientCompleteCount:Int;
    var clients:Array<ITestResultClient> = [];
    var activeHelper:TestClassHelper;
    var testSuites:Array<TestSuite>;
    var asyncDelegates:Array<AsyncDelegate>; // array to support multiple async handlers (chaining, or simultaneous)
    var suiteIndex:Int;

    public var asyncFactory(default, set):AsyncFactory;
    function set_asyncFactory(value:AsyncFactory):AsyncFactory
    {
        if (value == asyncFactory) return value;
        if (running) throw new MUnitException("Can't change AsyncFactory while tests are running");
        value.observer = this;
        return asyncFactory = value;
    }

    var startTime:Float;
    var testStartTime:Float;
    var isDebug(default, null):Bool;

    /**
     * Class constructor.
     *
     * @param	resultClient	a result client to interpret test results
     */
    public function new(resultClient:ITestResultClient)
    {
        addResultClient(resultClient);
        asyncFactory = createAsyncFactory();
        #if(testDebug || testdebug)
        isDebug = true;
        #else
        isDebug = false;
        #end
    }

    /**
     * Add one or more result clients to interpret test results.
     *
     * @param	resultClient			a result client to interpret test results
     */
    public function addResultClient(resultClient:ITestResultClient)
    {
        for (client in clients) if (client == resultClient) return;
        resultClient.completionHandler = clientCompletionHandler;
        clients.push(resultClient);
    }

    /**
     * Run one or more suites of unit tests containing @TestDebug.
     *
     * @param	testSuiteClasses
     */
    public function debug(testSuiteClasses:Array<Class<TestSuite>>)
    {
        isDebug = true;
        run(testSuiteClasses);
    }

    /**
     * Run one or more suites of unit tests.
     *
     * @param	testSuiteClasses
     */
    public function run(testSuiteClasses:Array<Class<TestSuite>>)
    {
        if (running) return;
        running = true;
        activeRunner = this;
        testCount = 0;
        failCount = 0;
        errorCount = 0;
        passCount = 0;
        ignoreCount = 0;
        suiteIndex = 0;
        clientCompleteCount = 0;
        Assert.assertionCount = 0; // don't really like this static but can't see way around it atm. ms 17/12/10
        asyncDelegates = new Array<AsyncDelegate>();
        testSuites = [for(suiteType in testSuiteClasses) Type.createInstance(suiteType, emptyParams)];
        startTime = Timer.stamp();

        #if (!lime && !nme && (neko || cpp || java))
            var self = this;
            var runThread:Thread = Thread.create(function()
            {
                self.execute();
                while (self.running)
                {
                    Sys.sleep(.2);
                }
                var mainThead:Thread = Thread.readMessage(true);
                mainThead.sendMessage("done");
            });

            runThread.sendMessage(Thread.current());
            Thread.readMessage(true);
        #else
        execute();
        #end
    }

    private function callHelperMethod(method:Dynamic):Void
    {
        try
        {
            /*
                Wrapping in try/catch solves below problem:
                    If @BeforeClass, @AfterClass, @Before, @After methods
                    have any Assert calls that fail, and if they are not
                    caught and handled here ... then TestRunner stalls.
            */
            Reflect.callMethod(activeHelper.test, method, emptyParams);
        }
        catch (e:Dynamic)
        {
            var testcaseData:Dynamic = activeHelper.current(); // fetch the test context
            exceptionHandler(e, testcaseData.result);
        }
    }


    private inline function exceptionHandler(e:Dynamic, result:TestResult):Void
    {
        #if hamcrest
        if (Std.is(e, org.hamcrest.AssertionException))
        {
            e = new AssertionException(e.message, e.info);
        }
        #end

        result.executionTime = Timer.stamp() - testStartTime;

        if (Std.is(e, AssertionException))
        {
            result.failure = e;
            failCount++;
            for (c in clients)
                c.addFail(result);
        }
        else
        {
            if (!Std.is(e, MUnitException))
                e = new UnhandledException(e, result.location);

            result.error = e;
            errorCount++;
            for (c in clients)
                c.addError(result);
        }
    }


    private function execute():Void
    {
        for (i in suiteIndex...testSuites.length)
        {
            var suite:TestSuite = testSuites[i];
            for (testClass in suite)
            {
                if (activeHelper == null || activeHelper.type != testClass)
                {
                    activeHelper = new TestClassHelper(testClass, isDebug);
                    activeHelper.beforeClass.iter(callHelperMethod);
                }
                executeTestCases();
                if (!isAsyncPending())
                {
                    activeHelper.afterClass.iter(callHelperMethod);
                }
                else
                {
                    suite.repeat();
                    suiteIndex = i;
                    return;
                }
            }
            testSuites[i] = null;
        }

        if (!isAsyncPending())
        {
            var time:Float = Timer.stamp() - startTime;
            for (client in clients)
            {
                if(Std.is(client, IAdvancedTestResultClient))
                {
                    var cl:IAdvancedTestResultClient = cast client;
                    cl.setCurrentTestClass(null);
                }
                client.reportFinalStatistics(testCount, passCount, failCount, errorCount, ignoreCount, time);
            } 
        }
    }

    function executeTestCases()
    {
        for(c in clients)
        {
            if(Std.is(c, IAdvancedTestResultClient) && activeHelper.hasNext())
			{
				var cl:IAdvancedTestResultClient = cast c;
				cl.setCurrentTestClass(activeHelper.className);
			}
        }
        for (testCaseData in activeHelper)
        {
            if (testCaseData.result.ignore)
            {
                ignoreCount++;
                for (c in clients)
                    c.addIgnore(cast testCaseData.result);
            }
            else
            {
                testCount++; // note we don't include ignored in final test count
                activeHelper.before.iter(callHelperMethod);
                testStartTime = Timer.stamp();
                executeTestCase(testCaseData, testCaseData.result.async);

                if (!isAsyncPending())
                {
                    activeRunner = null;  // for SYNC tests: resetting this here instead of clientCompletionHandler
                    activeHelper.after.iter(callHelperMethod);
                }
                else
                    break;
            }
        }
    }

    function executeTestCase(testCaseData:Dynamic, async:Bool):Void
    {
        var result:TestResult = testCaseData.result;
        try
        {
            var assertionCount:Int = Assert.assertionCount;

            // This was being reset to null when testing TestRunner itself i.e. testing munit using munit.
            // By setting this here, this runner value will be valid right when tests (Sync/ASync) are about to run.
            activeRunner = this;

            if (async)
            {
                var args:Array<Dynamic> = [asyncFactory];
                if (result.args != null) args = args.concat(result.args);
                
                var delegateCount = asyncFactory.asyncDelegateCount;
                Reflect.callMethod(testCaseData.scope, testCaseData.test, args);

                if(asyncFactory.asyncDelegateCount <= delegateCount)
                {
                    throw new MissingAsyncDelegateException("No AsyncDelegate was created in async test at " + result.location, null);
                }
            }
            else
            {
                Reflect.callMethod(testCaseData.scope, testCaseData.test, result.args);
            }

            if (!isAsyncPending())
            {
                result.passed = true;
                result.executionTime = Timer.stamp() - testStartTime;
                passCount++;
                for (c in clients)
                    c.addPass(result);
            }
        }
        catch(e:Dynamic)
        {
            cancelAllPendingAsyncTests();
            exceptionHandler(e, result);
        }
    }

    function clientCompletionHandler(resultClient:ITestResultClient)
    {
        if (++clientCompleteCount == clients.length)
        {
            if(completionHandler != null) Timer.delay(completionHandler.bind(passCount == testCount), 10);
			running = false;
        }
    }

    /**
     * Called when an AsyncDelegate being observed receives a successful asynchronous callback.
     *
     * @param	delegate		delegate which received the successful callback
     */
    public function asyncResponseHandler(delegate:AsyncDelegate)
    {
        var testCaseData = activeHelper.current();
        testCaseData.test = delegate.runTest;
        testCaseData.scope = delegate;

        asyncDelegates.remove(delegate);
        executeTestCase(testCaseData, false);
        if (!isAsyncPending())
        {
            activeRunner = null; // for ASync regular cases: resetting this here instead of clientCompletionHandler
            activeHelper.after.iter(callHelperMethod);
            execute();
        }
    }

    /**
     * Called when an AsyncDelegate being observed does not receive its asynchronous callback
     * in the time allowed.
     *
     * @param	delegate		delegate whose asynchronous callback timed out
     */
    public function asyncTimeoutHandler(delegate:AsyncDelegate)
    {
        var testCaseData:Dynamic = activeHelper.current();
        asyncDelegates.remove(delegate);

        if (delegate.hasTimeoutHandler)
        {
            testCaseData.test = delegate.runTimeout;
            testCaseData.scope = delegate;
            executeTestCase(testCaseData, false);
        }
        else
        {
            cancelAllPendingAsyncTests();

            var result:TestResult = testCaseData.result;
            result.executionTime = Timer.stamp() - testStartTime;
            result.error = new AsyncTimeoutException("", delegate.info);

            errorCount++;
            for (c in clients) c.addError(result);
        }
        if (!isAsyncPending())
        {
             activeRunner = null; // for ASync Time-out cases: resetting this here instead of clientCompletionHandler
             activeHelper.after.iter(callHelperMethod);
             execute();
        }
    }

    public function asyncDelegateCreatedHandler(delegate:AsyncDelegate)
    {
        asyncDelegates.push(delegate);
    }

    inline function createAsyncFactory():AsyncFactory return new AsyncFactory(this);
	
    static inline function tryCallMethod(o:Dynamic, func:Function, args:Array<Dynamic>):Dynamic {
        if(Reflect.compareMethods(func, TestClassHelper.nullFunc)) return null;
        return Reflect.callMethod(o, func, args);
    }

    private inline function isAsyncPending() : Bool
    {
        return (asyncDelegates.length > 0);
    }

    private function cancelAllPendingAsyncTests() : Void
    {
        for (delegate in asyncDelegates)
        {
            delegate.cancelTest();
            asyncDelegates.remove(delegate);
        }
    }
}
