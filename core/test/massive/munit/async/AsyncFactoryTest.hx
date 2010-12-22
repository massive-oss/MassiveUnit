package massive.munit.async;

import massive.munit.Assert;

/**
 * ...
 * @author Mike Stead
 */

class AsyncFactoryTest implements IAsyncDelegateObserver
{
	private var handlerCalled:Bool;
	private var execHandlerCalled:Bool;
	
	public function new() 
	{}
	
	@Test
	public function testConstructor():Void
	{
		var factory:AsyncFactory = new AsyncFactory(this);
		Assert.areEqual(this, factory.observer);
		Assert.areEqual(0, factory.asyncDelegateCount);
	}
	
	@Test
	public function testCreateBasicHandler():Void
	{
		var factory:AsyncFactory = new AsyncFactory(this);
		var handler:Dynamic = factory.createBasicHandler(this, onTestCreateBasicHandler, 333);

		Assert.isNotNull(handler);
		
		execHandlerCalled = false;
		handlerCalled = false;
		
		handler();

		Assert.isTrue(handlerCalled);
		Assert.isTrue(execHandlerCalled);
	}
	
	private function onTestCreateBasicHandler():Void
	{
		handlerCalled = true;
	}
	
	public function asyncExecuteHandler(delegate:AsyncDelegate):Void
	{
		execHandlerCalled = true;
		delegate.runTest();
	}
	
	public function asyncTimeoutHandler(delegate:AsyncDelegate):Void
	{
		Assert.fail("Async timeout occured when it shouldn't have");
	}
}