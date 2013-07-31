/**************************************** ****************************************
 * Copyright 2010 Massive Interactive. All rights reserved.
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
 */
package massive.munit;
import massive.munit.client.JUnitReportClient;
import massive.munit.async.AsyncFactory;
import massive.munit.async.AsyncTestSuiteStub;

/**
 * ...
 * @author Mike Stead
 */
class TestRunnerTest
{
    private var runner:TestRunner;
    private var client:TestResultClientStub;

    public function new()
    {}

    @Before
    public function setup():Void
    {
        client = new TestResultClientStub();
        runner = new TestRunner(client);
    }

    @After
    public function tearDown():Void
    {
        client.completionHandler = null;
        client = null;
        runner.completionHandler = null;
        runner = null;
    }

    @Test
    public function testConstructor():Void
    {
        Assert.areEqual(1, runner.clientCount);
        Assert.isFalse(runner.running);
    }

    @Test
    public function testAddResultClient():Void
    {
        Assert.areEqual(1, runner.clientCount);
        runner.addResultClient(client);
        Assert.areEqual(1, runner.clientCount);
        var client2 = new JUnitReportClient();
        runner.addResultClient(client2);
        Assert.areEqual(2, runner.clientCount);
    }

    @AsyncTest
    public function testRun(factory:AsyncFactory):Void
    {
        var suites = new Array<Class<massive.munit.TestSuite>>();
        suites.push(TestSuiteStub);
        runner.completionHandler = factory.createHandler(this, completionHandler, 5000);
        runner.run(suites);
    }

    private function completionHandler(isSuccessful:Bool):Void
    {
        Assert.isFalse(isSuccessful);
        Assert.areEqual(2, client.testCount);
        Assert.areEqual(2, client.finalTestCount);
        Assert.areEqual(1, client.passCount);
        Assert.areEqual(1, client.finalPassCount);
        Assert.areEqual(1, client.failCount);
        Assert.areEqual(1, client.finalFailCount);
        Assert.areEqual(0, client.errorCount);
        Assert.areEqual(0, client.finalErrorCount);
        Assert.areEqual(1, client.testClasses.length);
        Assert.isNull(client.currentTestClass);

        Assert.areEqual("massive.munit.TestClassStub", client.testClasses[client.testClasses.length-1]);
    }

    @AsyncTest
    public function testDebug(factory:AsyncFactory):Void
    {
        var suites = new Array<Class<massive.munit.TestSuite>>();

        suites.push(TestSuiteStub);
        runner.completionHandler = factory.createHandler(this, completionHandler, 5000);
        runner.debug(suites);
    }

    @AsyncTest
    public function noDebugTestsDuringDebugShouldNotRun(factory:AsyncFactory):Void
    {
        var suites = new Array<Class<massive.munit.TestSuite>>();

        suites.push(DebuglessTestSuiteStub);
        runner.completionHandler = factory.createHandler(this, debugCompletetionHandler, 5000);
        runner.debug(suites);
    }

    private function debugCompletetionHandler(isSuccessful:Bool):Void {
        Assert.areEqual(0, client.testClasses.length);
    }

    @AsyncTest
    public function testAsyncAssertionTests(factory:AsyncFactory):Void
    {
        var suites = new Array<Class<massive.munit.TestSuite>>();

        suites.push(AsyncTestSuiteStub);
        runner.completionHandler = factory.createHandler(this, asyncCompletionHandler, 5000);
        runner.run(suites);
    }

    private function asyncCompletionHandler(isSuccessful:Bool):Void
    {
        Assert.isFalse(isSuccessful);
        Assert.areEqual(8, client.testCount);
        Assert.areEqual(8, client.finalTestCount);
        Assert.areEqual(3, client.passCount);
        Assert.areEqual(3, client.finalPassCount);
        Assert.areEqual(3, client.failCount);
        Assert.areEqual(3, client.finalFailCount);
        Assert.areEqual(2, client.errorCount);
        Assert.areEqual(2, client.finalErrorCount);
        Assert.areEqual(2, client.testClasses.length);
        Assert.isNull(client.currentTestClass);

        Assert.areEqual("massive.munit.async.AsyncTestClassStub2", client.testClasses[client.testClasses.length-1]);
        Assert.areEqual("massive.munit.async.AsyncTestClassStub", client.testClasses[client.testClasses.length-2]);
    }
}
