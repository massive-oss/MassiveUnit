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
package massive.munit.async;
import massive.munit.Assert;
import massive.munit.util.Timer;

/**
 * ...
 * @author Mike Stead
 */

class AsyncDelegateTest implements IAsyncDelegateObserver
{
	private var delegate:AsyncDelegate;
	private var handler:Dynamic;
	private var handlerCalled:Bool;
	private var timeoutCalled:Bool;

	public function new() 
	{}

	@Before
	public function setup():Void
	{
		handler = null;
		delegate = null;
		handlerCalled = false;
		timeoutCalled = false;
	}
		
	@After
	public function tearDown():Void
	{
		handler = null;
		delegate = null;
		handlerCalled = false;
		timeoutCalled = false;
	}
	
	@Test
	public function testConstructorThreeParams():Void
	{
		var delegate:AsyncDelegate = new AsyncDelegate(this, asyncTestHandler); 
		
		Assert.areEqual(AsyncDelegate.DEFAULT_TIMEOUT, delegate.timeoutDelay);
		Assert.isNull(delegate.observer);
		Assert.isNotNull(delegate.info);
		Assert.isFalse(delegate.timedOut);
	}


	@Test
	public function testConstructorFourParamas():Void
	{
		var delegate:AsyncDelegate = new AsyncDelegate(this, asyncTestHandler, 200);
		Assert.areEqual(200, delegate.timeoutDelay);
	}

	@Test
	public function testConstructorWithNegativeTimeout():Void
	{
		var delegate:AsyncDelegate = new AsyncDelegate(this, asyncTestHandler, -1);
		Assert.areEqual(AsyncDelegate.DEFAULT_TIMEOUT, delegate.timeoutDelay);
	}
	
	@AsyncTest
	public function testTimeout(factory:AsyncFactory):Void
	{
		delegate = new AsyncDelegate(this, asyncTestHandler, 10); 
		delegate.observer = this;
		handler = factory.createHandler(this, onTestTimeout);//created after delegate to ensure delegate timer executes beofre handler one (interval bug in flash when under heavy load)
	}
		
	public function asyncTimeoutHandler(delegate:AsyncDelegate):Void
	{
		timeoutCalled = true;
		Assert.isTrue(delegate.timedOut);
		handler(); // should trigger onTestTimeout
	}
	
	private function onTestTimeout():Void
	{

		Assert.isTrue(true); // need to assert in handler or we'll get an exception
	}


	//---------------

	@AsyncTest
	public function testCancel(factory:AsyncFactory):Void
	{
		delegate = new AsyncDelegate(this, onCancelTestDelegateHandler, 10);
		delegate.observer = this;
		delegate.cancelTest();

		Assert.isTrue(delegate.canceled);

		handler = factory.createHandler(this, onTestCancelHandler);
		Timer.delay(handler, 100);

	}
	public function asyncDelegateCreatedHandler(delegate:AsyncDelegate):Void
    {
        //just implementing part of IAsyncDelegateObserver
    }

    private function onCancelTestDelegateHandler()
    {
		Assert.isTrue(true); // need to assert in async handler or we'll get an exception
    }

    public function onTestCancelHandler()
    {
    	Assert.isTrue(delegate.canceled);
    	Assert.isFalse(timeoutCalled);
    	Assert.isFalse(handlerCalled);
    }


	//-----------------------------
	
	@AsyncTest
	public function testHandler(factory:AsyncFactory):Void
	{
		handler = factory.createHandler(this, onTestHandler, 1000);
		delegate = new AsyncDelegate(this, asyncTestHandler);
		delegate.observer = this;		
		Timer.delay(asyncDelegateTestHandler, 10);
	}

	private function asyncDelegateTestHandler():Void
	{
		var param = true;
		delegate.delegateHandler(param); // should trigger asyncResponseHandler
	}
	
	public function asyncResponseHandler(delegate:AsyncDelegate):Void
	{	
		Assert.isFalse(delegate.timedOut);
		Assert.areEqual(this.delegate, delegate);
		handlerCalled = false;
		delegate.runTest(); // should trigger asyncTestHandler 
		Assert.isTrue(handlerCalled);
		handler();
	}

	private function asyncTestHandler(param:Bool):Void
	{
		Assert.isTrue(param);
		handlerCalled = true;
	}

	private function onTestHandler():Void
	{
		Assert.isTrue(true); // need to assert in async handler or we'll get an exception
	}
}
