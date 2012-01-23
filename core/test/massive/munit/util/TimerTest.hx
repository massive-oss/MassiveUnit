package massive.munit.util;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

/**
* Auto generated MassiveUnit Test Class  for massive.munit.util.Timer 
*/
class TimerTest 
{
	var instance:Timer; 
	var count:Int;
	var stamp:Float;
	var handler:Void->Void;
	
	public function new() 
	{
		
	}
	
	@BeforeClass
	public function beforeClass():Void
	{
	}
	
	@AfterClass
	public function afterClass():Void
	{
	}
	
	@Before
	public function setup():Void
	{
		count = 0;
	}
	
	@After
	public function tearDown():Void
	{
		if(instance != null)
			instance.stop();
		
		handler = null;
	}
	
	@AsyncTest
	public function testConstructor(factory:AsyncFactory):Void
	{
		handler = factory.createHandler(this, onRepeatedTimer, 5000);
		instance = new Timer(10);
		instance.run = timerHandler;
		Timer.delay(delayedHandler, 200);
	}

	function delayedHandler()
	{
		Timer.delay(handler, 1);
	}

	function onRepeatedTimer()
	{
		Assert.isTrue(count > 1);
	}


	@AsyncTest
	public function shouldStopTimer(factory:AsyncFactory):Void
	{
		handler = factory.createHandler(this, onStoppedTimer);
	
		instance = new Timer(10);
		instance.run = timerHandler;
		instance.stop();

		Timer.delay(handler, 200);
	}

	function onStoppedTimer()
	{
		Assert.areEqual(0, count);
	}

	@AsyncTest
	public function shouldDelayAndCallOnce(factory:AsyncFactory):Void
	{
		handler = factory.createHandler(this, onDelayedTimer);
		instance = Timer.delay(timerHandler, 10);
		Timer.delay(handler, 200);
	}

	function onDelayedTimer()
	{
		Assert.areEqual(1, count);
	}

	@AsyncTest
	public function shouldIncrementStamp(factory:AsyncFactory):Void
	{
		handler = factory.createHandler(this, onStampDelay);
		stamp = Timer.stamp();
		Timer.delay(handler, 200);
	}

	function onStampDelay()
	{
		var newStamp = Timer.stamp();
		Assert.isTrue(newStamp > stamp);
	}

	#if js
		@AsyncTest
		public function shouldClearOutIntervals(factory:AsyncFactory):Void
		{
			var timer:Timer;

			handler = factory.createHandler(this, onMegaTimerDelay);

			for(i in 1...102)
			{
				timer = Timer.delay(timerHandler, i);
			}

			Timer.delay(handler, 200);
		}

		function onMegaTimerDelay()
		{
			Assert.isTrue(untyped Timer.arr.length < 100);
		}

	#end


	//-------------

	function timerHandler()
	{
		count ++;
	}
}