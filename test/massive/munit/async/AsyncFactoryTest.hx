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
import massive.munit.async.AsyncFactory;
import massive.munit.util.Timer;
/**
 * ...
 * @author Mike Stead
 */

class AsyncFactoryTest implements IAsyncDelegateObserver
{
	private var handlerCalled:Bool;
	private var execHandlerCalled:Bool;
	private var delegate:AsyncDelegate;
	
	public function new() 
	{}

	@After
	public function tearDown():Void
	{
		if(delegate != null)
		{
			delegate.cancelTest();
			delegate = null;
		}
	}
	
	@Test
	public function testConstructor():Void
	{
		var factory:AsyncFactory = new AsyncFactory(this);
		Assert.areEqual(this, factory.observer);
		Assert.areEqual(0, factory.asyncDelegateCount);
	}
	
	@AsyncTest
	public function testCreateBasicHandler(factory:AsyncFactory):Void
	{
		var tempFactory:AsyncFactory = new AsyncFactory(this);
		var tempHandler:Dynamic = tempFactory.createHandler(this, onTestCreateBasicHandler, 333);

		Assert.isNotNull(delegate);

		Assert.isNotNull(tempHandler);
		Assert.areEqual(tempHandler, delegate.delegateHandler);
		
		execHandlerCalled = false;
		handlerCalled = false;
		
		tempHandler();

		var actualHandler:Dynamic = factory.createHandler(this, assertOnTestCreateBasicHandlerCalled, 333);
		Timer.delay(actualHandler, 10);
	}

	private function onTestCreateBasicHandler():Void
	{
		handlerCalled = true;
	}

	private function assertOnTestCreateBasicHandlerCalled():Void
	{
		Assert.isTrue(handlerCalled);
		Assert.isTrue(execHandlerCalled);
	}

	public function asyncDelegateCreatedHandler(delegate:AsyncDelegate):Void
    {
        this.delegate = delegate;
    }
	
	public function asyncResponseHandler(delegate:AsyncDelegate):Void
	{
		execHandlerCalled = true;
		delegate.runTest();
	}
	
	public function asyncTimeoutHandler(delegate:AsyncDelegate):Void
	{
		Assert.fail("Async timeout occured when it shouldn't have");
	}

	
}
