package massive.munit.async;

import haxe.PosInfos;

import massive.munit.async.delegate.AsyncBasicDelegate;

/**
 * Factory for asynchronous delegates.
 * 
 * <p>
 * An instance of this factory is passed to test methods which define themselves as asynchronous.
 * They can then request a delegate handler to 
 * </p>
 * <pre>
 * class TimerTest
 * {
 *     @Test("Async")
 *     public function testTimer(factory:AsyncFactory):Void
 *     {
 *         var handler:Dynamic = factory.createBasicHandler(this, onTestTimer);
 *         Timer.delay(onTestTimer, 100);
 *     }
 *     
 *     private function onTestTimer():Void
 *     {
 *         Assert.isTrue(true);
 *     }
 * }
 * </pre>
 * 
 * @author Mike Stead
 */
class AsyncFactory 
{
	/**
	 * The number of asynchronous delegates created by this factory.
	 */
	public var asyncDelegateCount(default, null):Int;
	
	public var observer:IAsyncDelegateObserver;

	/**
	 * Class constructor.
	 * 
	 * @param	observer			an observer for all asynchronous delegates this factory creates
	 */
	public function new(observer:IAsyncDelegateObserver) 
	{
		this.observer = observer;
		asyncDelegateCount = 0;
	}
	
	/**
	 * Create a basic AsyncDelegate which requires no parameters to be passed to its handler.
	 * 
	 * @param	testCase			test case instance where the async test originated
	 * @param	handler				the handler in the test case for a successful async response
	 * @param	?timeout			[optional] number of milliseconds to wait before timing out
	 * @param	?info				[optional] pos infos of the test which requests an instance of this delegate
	 * @return	an AsyncDelegate for handling MassiveUI Dispatcher notifications
	 */
	public function createBasicHandler(testCase:Dynamic, handler:Dynamic, ?timeout:Int, ?info:PosInfos):Dynamic
	{
		var dispatcher:AsyncBasicDelegate = new AsyncBasicDelegate(testCase, handler, timeout, info);
		dispatcher.observer = observer;
		asyncDelegateCount++;
		return dispatcher.delegateHandler;
	}
}