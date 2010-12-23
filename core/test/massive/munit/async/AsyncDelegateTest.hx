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
	public function new() 
	{}
	
	@After
	public function tearDown():Void
	{
		handler = null;
		delegate = null;
		handlerCalled = false;
	}
	
	@Test
	public function testConstructorThreeParams():Void
	{
		var delegate:AsyncDelegate = new AsyncDelegate(this, asyncTestHanlder); 
		
		Assert.areEqual(AsyncDelegate.DEFAULT_TIMEOUT, delegate.timeoutDelay);
		Assert.isNull(delegate.observer);
		Assert.isNotNull(delegate.info);
		Assert.isFalse(delegate.timedOut);
	}
	
	@Test
	public function testConstructorFourParamas():Void
	{
		var delegate:AsyncDelegate = new AsyncDelegate(this, asyncTestHanlder, 200);
		Assert.areEqual(200, delegate.timeoutDelay);
	}
	
	@Test("Async")
	public function testTimeout(factory:AsyncFactory):Void
	{
		handler = factory.createHandler(this, onTestTimeout);
		
		delegate = new AsyncDelegate(this, asyncTestHanlder, 10); 
		delegate.observer = this;
	}
		
	public function asyncTimeoutHandler(delegate:AsyncDelegate):Void
	{
		Assert.isTrue(delegate.timedOut);
		Assert.areEqual(this.delegate, delegate);
		handler(); // should trigger onTestTimeout
	}
	
	private function onTestTimeout():Void
	{
		Assert.isTrue(true); // need to assert in handler or we'll get an exception
	}
	
	//-----------------------------
	
	@Test("Async")
	public function testHandler(factory:AsyncFactory):Void
	{
		handler = factory.createHandler(this, onTestHandler);
		
		delegate = new AsyncDelegate(this, asyncTestHanlder);
		delegate.observer = this;		
		Timer.delay(asyncDelegateTestHanlder, 10);
	}

	private function asyncDelegateTestHanlder():Void
	{
		var param = true;
		delegate.delegateHandler(param); // should trigger asyncResponseHandler
	}
	
	public function asyncResponseHandler(delegate:AsyncDelegate):Void
	{	
		Assert.isFalse(delegate.timedOut);
		Assert.areEqual(this.delegate, delegate);
		handlerCalled = false;
		delegate.runTest(); // should trigger asyncTestHanlder 
		Assert.isTrue(handlerCalled);
		handler();
	}

	private function asyncTestHanlder(param:Bool):Void
	{
		Assert.isTrue(param);
		handlerCalled = true;
	}

	private function onTestHandler():Void
	{
		Assert.isTrue(true); // need to assert in async handler or we'll get an exception
	}	
}