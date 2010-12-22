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
	public function new() 
	{}
	
	@After
	public function tearDown():Void
	{
		handler = null;
		delegate = null;
	}
	
	@Test
	public function testConstructorThreeParams():Void
	{
		var delegate:AsyncDelegate = new AsyncDelegate(this, asyncTestHanlder, asyncDelegateTestHanlder); 
		
		Assert.areEqual(AsyncDelegate.DEFAULT_TIMEOUT, delegate.timeoutDelay);
		Assert.isNull(delegate.observer);
		Assert.isNotNull(delegate.info);
		Assert.isFalse(delegate.timedOut);
	}
	
	@Test
	public function testConstructorFourParamas():Void
	{
		var delegate:AsyncDelegate = new AsyncDelegate(this, asyncTestHanlder, asyncDelegateTestHanlder, 200);
		Assert.areEqual(200, delegate.timeoutDelay);
	}
	
	@Test("Async")
	public function testTimeout(factory:MUnitAsyncFactory):Void
	{
		delegate = new AsyncDelegate(this, asyncTestHanlder, asyncDelegateTestHanlder, 10); 
		delegate.observer = this;
		handler = factory.createBasicHandler(this, onTestTimeout);
	}
	
	private function onTestTimeout():Void
	{
		Assert.isTrue(true);
	}
		
	public function asyncTimeoutHandler(delegate:AsyncDelegate):Void
	{
		Assert.isTrue(delegate.timedOut);
		Assert.areEqual(this.delegate, delegate);
		handler(); // should trigger onTestTimeout
	}
	
	@Test("Async")
	public function testHandler(factory:MUnitAsyncFactory):Void
	{
		handler = factory.createBasicHandler(this, onTestTimeout);

		delegate = new AsyncDelegate(this, asyncTestHanlder, asyncDelegateTestHanlder); 
		delegate.observer = this;		
		Timer.delay(asyncDelegateTestHanlder, 10);
	}

	private function asyncDelegateTestHanlder():Void
	{
		delegate.responseHandler(); // should trigger asyncExecuteHandler
	}
	
	public function asyncExecuteHandler(delegate:AsyncDelegate):Void
	{	
		Assert.isFalse(delegate.timedOut);
		Assert.areEqual(this.delegate, delegate);
		handler(); // should trigger onTestTimeout
	}

	private function onTestHandler():Void
	{
		Assert.isTrue(true);
	}

	private function asyncTestHanlder():Void
	{}
}