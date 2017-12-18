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



package massive.munit.async;
import haxe.Constraints.Function;
import haxe.PosInfos;

import massive.munit.util.Timer;

/**
 * Sits between an asynchronous test and an observer (typically the TestRunner), notifying 
 * the observer when an asynchronous test has returned or timed out.
 * 
 * @author Mike Stead
 */
class AsyncDelegate 
{
	/**
	 * Default timeout period in milliseconds.
	 */
	public inline static var DEFAULT_TIMEOUT:Int = 400;
	
	/**
	 * Observer interested in the outcome of this asynchronous call.
	 */
	public var observer:IAsyncDelegateObserver;
	
	/**
	 * Pos infos of the test which requests an instance of this delegate.
	 */
	public var info:PosInfos;
	
	/**
	 * The handler for a successful response from the asynchronous call.
	 * <p>
	 * This notifies the observer of the success. The observer can then call runTest when
	 * it is ready for the remainder of the async test to be run.
	 * </p>
	 */
	public var delegateHandler(default, null):Dynamic;
	public var timeoutDelay(default, null):Int;
	public var timedOut(default, null):Bool = false;
	public var canceled(default, null):Bool = false;
	var testCase:Dynamic;
	var handler:Function;
	var timer:Timer;
	var deferredTimer:Timer;

	/**
	 * An array of values to be passed as parameters to the test class handler.
	 * This should be populated inside the delegateHandler when it's called.
	 */
	var params:Array<Dynamic> = [];
	
	/**
	 * Class constructor.
	 * 
	 * @param	testCase			test case instance where the async test originated
	 * @param	handler				the handler in the test case for a successful async response
	 * @param	?timeout			[optional] number of milliseconds to wait before timing out. Defaults to 400
	 * @param	?info				[optional] pos infos of the test which requests an instance of this delegate
	 */
	public function new(testCase:Dynamic, handler:Function, ?timeout:Int, ?info:PosInfos)
	{
		this.testCase = testCase;
		this.handler = handler;
		this.delegateHandler = Reflect.makeVarArgs(responseHandler);
		this.info = info;
		if (timeout == null || timeout <= 0) timeout = DEFAULT_TIMEOUT;
		timeoutDelay = timeout;
		timer = Timer.delay(timeoutHandler, timeoutDelay);
	}
	
	/**
	 * Execute the remainder of the asynchronous test. This should be called after observer
	 * has been notified of a successful asynchronous response.
	 */
	public function runTest()
	{
		Reflect.callMethod(testCase, handler, params);
	}

	/**
	 * Cancels pending async timeout.
	 */
	public function cancelTest()
	{
		canceled = true;
		timer.stop();
		if(deferredTimer != null) deferredTimer.stop();
	}

	function responseHandler(?params:Array<Dynamic>):Dynamic
	{	
		if (timedOut || canceled) return null;
		timer.stop();
		if(deferredTimer != null) deferredTimer.stop();
		this.params = params != null ? params.copy() : [];
		// defer callback to force async runner
		if (observer != null) Timer.delay(delayActualResponseHandler, 1);
		return null;
	}

	function delayActualResponseHandler()
	{
		observer.asyncResponseHandler(this);
		observer = null; 
	}

	function timeoutHandler()
	{
		#if flash
			//pushing timeout onto next frame to prevent raxe condition bug when flash framerate drops too low and timeout timer executes prior to response on same frame
			deferredTimer = Timer.delay(actualTimeoutHandler, 1);
		#else
			actualTimeoutHandler();
		#end
	}

	function actualTimeoutHandler()
	{
		deferredTimer = null;
		handler = null;
		delegateHandler = null;
		timedOut = true;
		if (observer != null)
		{
			observer.asyncTimeoutHandler(this);
			observer = null; 
		}
	}
}
