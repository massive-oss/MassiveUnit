/****
* Copyright 2013 Massive Interactive. All rights reserved.
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

import haxe.PosInfos;

import massive.munit.Assert;
import massive.munit.async.AsyncDelegate;
import massive.munit.async.AsyncFactory;
import massive.munit.async.AsyncTimeoutException;
import massive.munit.async.IAsyncDelegateObserver;
import massive.munit.async.MissingAsyncDelegateException;
import massive.munit.util.Timer;
import massive.munit.ITestResultClient;

#if neko
import neko.vm.Thread;
#elseif cpp
import cpp.vm.Thread;
#end

#if haxe3
import haxe.CallStack;
#else
import haxe.Stack;
private typedef CallStack = Stack;
#end

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
    /**
     * Handler called when all tests have been executed and all clients
     * have completed processing the results.
     */
    public var completionHandler:Bool -> Void;

    public var clientCount(get_clientCount, null):Int;
    private function get_clientCount():Int { return clients.length; }

    public var running(default, null):Bool;

    private var testCount:Int;
    private var failCount:Int;
    private var errorCount:Int;
    private var passCount:Int;
    private var ignoreCount:Int;
    private var clientCompleteCount:Int;

    private var clients:Array<ITestResultClient>;

    private var activeHelper:TestClassHelper;
    private var testSuites:Array<TestSuite>;

    private var asyncPending:Bool;
    private var asyncDelegate:AsyncDelegate;
    private var suiteIndex:Int;

    public var asyncFactory(default, set_asyncFactory):AsyncFactory;
    private function set_asyncFactory(value:AsyncFactory):AsyncFactory
    {
        if (value == asyncFactory) return value;
        if (running) throw new MUnitException("Can't change AsyncFactory while tests are running");
        value.observer = this;
        return asyncFactory = value;
    }

    private var emptyParams:Array<Dynamic>;

    private var startTime:Float;
    private var testStartTime:Float;

    private var isDebug(default, null):Bool;


    /**
     * Class constructor.
     *
     * @param	resultClient	a result client to interpret test results
     */
    public function new(resultClient:ITestResultClient)
    {
        clients = new Array<ITestResultClient>();
        addResultClient(resultClient);
        asyncFactory = createAsyncFactory();
        running = false;

        #if (testDebug||testdebug)
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
    public function addResultClient(resultClient:ITestResultClient):Void
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
    public function debug(testSuiteClasses:Array<Class<TestSuite>>):Void
    {
        isDebug = true;
        run(testSuiteClasses);
    }

    /**
     * Run one or more suites of unit tests.
     *
     * @param	testSuiteClasses
     */
    public function run(testSuiteClasses:Array<Class<TestSuite>>):Void
    {
        if (running) return;

        running = true;
        asyncPending = false;
        asyncDelegate = null;
        testCount = 0;
        failCount = 0;
        errorCount = 0;
        passCount = 0;
        ignoreCount = 0;
        suiteIndex = 0;
        clientCompleteCount = 0;
        Assert.assertionCount = 0; // don't really like this static but can't see way around it atm. ms 17/12/10
        emptyParams = new Array();
        testSuites = new Array<TestSuite>();
        startTime = Timer.stamp();

        for (suiteType in testSuiteClasses)
        {
            testSuites.push(Type.createInstance(suiteType, new Array()));
        }

        #if (neko||cpp) 
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
                    Reflect.callMethod(activeHelper.test, activeHelper.beforeClass, emptyParams);
                }
                executeTestCases();
                if (!asyncPending)
                {
                    Reflect.callMethod(activeHelper.test, activeHelper.afterClass, emptyParams);
                }
                else
                {
                    suite.repeat();
                    suiteIndex = i;
                    return;
                }
            }
        }

        if (!asyncPending)
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

    private function executeTestCases():Void
    {
        for(c in clients)
        {
            if(Std.is(c, IAdvancedTestResultClient))
            {
                if (activeHelper.hasNext())
                {
                    var cl:IAdvancedTestResultClient = cast c;
                    cl.setCurrentTestClass(activeHelper.className);
                }
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
                Reflect.callMethod(activeHelper.test, activeHelper.before, emptyParams);
                testStartTime = Timer.stamp();
                executeTestCase(testCaseData, testCaseData.result.async);

                if (!asyncPending)
                    Reflect.callMethod(activeHelper.test, activeHelper.after, emptyParams);
                else
                    break;
            }
        }
    }

    private function executeTestCase(testCaseData:Dynamic, async:Bool):Void
    {
        var result:TestResult = testCaseData.result;
        try
        {
            var assertionCount:Int = Assert.assertionCount;
            if (async)
            {
                Reflect.callMethod(testCaseData.scope, testCaseData.test, [asyncFactory]);

                if(asyncDelegate == null)
                {
                    throw new MissingAsyncDelegateException("No AsyncDelegate was created in async test at " + result.location, null);
                }

                asyncPending = true;
            }
            else
            {
                Reflect.callMethod(testCaseData.scope, testCaseData.test, emptyParams);

                result.passed = true;
                result.executionTime = Timer.stamp() - testStartTime;
                passCount++;
                for (c in clients)
                    c.addPass(result);
            }
        }
        catch(e:Dynamic)
        {
            if(async && asyncDelegate != null)
            {
                asyncDelegate.cancelTest();
                asyncDelegate = null;
            }

			#if hamcrest
			if (Std.is(e, org.hamcrest.AssertionException))
				e = new AssertionException(e.message, e.info);
			#end

            if (Std.is(e, AssertionException))
            {
                result.executionTime = Timer.stamp() - testStartTime;
                result.failure = e;
                failCount++;
                for (c in clients)
                    c.addFail(result);
            }
            else
            {
                result.executionTime = Timer.stamp() - testStartTime;
                if (!Std.is(e, MUnitException))
                    e = new UnhandledException(e, result.location);

                result.error = e;
                errorCount++;
                for (c in clients)
                    c.addError(result);
            }

        }
    }

    private function clientCompletionHandler(resultClient:ITestResultClient):Void
    {
        if (++clientCompleteCount == clients.length)
        {
            if (completionHandler != null)
            {
                var successful:Bool = (passCount == testCount);
                var handler:Dynamic = completionHandler;

                Timer.delay(function() { handler(successful); }, 10);
            }
            running = false;
        }
    }

    /**
     * Called when an AsyncDelegate being observed receives a successful asynchronous callback.
     *
     * @param	delegate		delegate which received the successful callback
     */
    public function asyncResponseHandler(delegate:AsyncDelegate):Void
    {
        var testCaseData:Dynamic = activeHelper.current();
        testCaseData.test = delegate.runTest;
        testCaseData.scope = delegate;

        asyncPending = false;
        asyncDelegate = null;
        executeTestCase(testCaseData, false);
        Reflect.callMethod(activeHelper.test, activeHelper.after, emptyParams);
        execute();
    }

    /**
     * Called when an AsyncDelegate being observed does not receive its asynchronous callback
     * in the time allowed.
     *
     * @param	delegate		delegate whose asynchronous callback timed out
     */
    public function asyncTimeoutHandler(delegate:AsyncDelegate):Void
    {
        var testCaseData:Dynamic = activeHelper.current();
        var result:TestResult = testCaseData.result;
        result.executionTime = Timer.stamp() - testStartTime;
        result.error = new AsyncTimeoutException("", delegate.info);

        asyncPending = false;
        asyncDelegate = null;
        errorCount++;
        for (c in clients) c.addError(result);
        Reflect.callMethod(activeHelper.test, activeHelper.after, emptyParams);
        execute();
    }

    public function asyncDelegateCreatedHandler(delegate:AsyncDelegate):Void
    {
        asyncDelegate = delegate;
    }

    private function createAsyncFactory():AsyncFactory
    {
        return new AsyncFactory(this);
    }
}
