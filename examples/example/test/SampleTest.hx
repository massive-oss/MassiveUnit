package;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

/**
 * ...
 * @author Mike Stead
 */
class SampleTest 
{
	private var timer:Timer;
	private var handler:Dynamic;
	
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
	}
	
	@After
	public function tearDown():Void
	{
	}
	
	@Test
	public function testConstructor():Void
	{
		Assert.isTrue(true);
	}
		
	@Test("Async")
	public function testAsyncOperation(factory:AsyncFactory):Void
	{
		var handler:Dynamic = factory.createHandler(this, onTestConstructor, 1000);
		timer = Timer.delay(handler, 200);
	}
	
	private function onTestConstructor():Void
	{
		Assert.isFalse(false);
	}
}