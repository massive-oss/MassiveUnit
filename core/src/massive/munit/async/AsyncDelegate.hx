package massive.munit.async;
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
	 * <p>
	 * Each subclass of AsyncDelegate should implement its own delegateHandler method and pass 
	 * a reference to it down through its super constructor call. This handler's signature
	 * should match that of the callback type its responsible for.
	 * </p>
	 */
	public var delegateHandler:Dynamic;

	public var timeoutDelay(default, null):Int;
	public var timedOut(default, null):Bool;
	
	private var testCase:Dynamic;
	private var handler:Dynamic;
	private var timer:Timer;
	
	/* An array of values to be passed as parameters to the test class handler.
	 * This should be populated inside the delegateHandler when it's called.
	 */ 
	private var params:Array<Dynamic>;
	
	/**
	 * Class constructor.
	 * 
	 * @param	testCase			test case instance where the async test originated
	 * @param	handler				the handler in the test case for a successful async response
	 * @param	delegateHandler		the handler in this delegate which listens directly for a successful async response
	 * @param	?timeout			[optional] number of milliseconds to wait before timing out. Defaults to 400
	 * @param	?info				[optional] pos infos of the test which requests an instance of this delegate
	 */
	public function new(testCase:Dynamic, handler:Dynamic, ?delegateHandler:Dynamic, ?timeout:Int, ?info:PosInfos) 
	{
		var self = this;
		this.testCase = testCase;
		this.handler = handler;
		
		this.delegateHandler = delegateHandler;
		this.info = info;
		params = [];
		timedOut = false;

		if (timeout == null || timeout <= 0) timeout = DEFAULT_TIMEOUT;
		timeoutDelay = timeout;
		timer = Timer.delay(timeoutHandler, timeoutDelay);
	}
	
	/**
	 * Execute the remainder of the asynchronous test. This should be called after observer
	 * has been notified of a successful asynchronous response.
	 */
	public function runTest():Void
	{
		Reflect.callMethod(testCase, handler, params);
	}
	
	/* Call this from your delegate handler, passing through array of params to be passed to the real handler */
	public function responseHandler(?params:Array<Dynamic>):Void
	{		
		// TODO: look into Reflect.makeVarArgs. This would remove the need for differnet delegate types
		//       but need to check support is universal. 
		//       See: http://lists.motion-twin.com/pipermail/haxe/2006-December/006455.html
		//       ms 16/12/10
		
		if (timedOut) return;
		timer.stop();
		
		if (params == null) params = [];
		this.params = params;
		
		if (observer != null) observer.asyncExecuteHandler(this);
	}
	
	private function timeoutHandler():Void
	{
		handler = null;
		delegateHandler = null;
		timedOut = true;
		if (observer != null) observer.asyncTimeoutHandler(this);
	}
}
