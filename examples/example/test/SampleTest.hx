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
	
	@Test("Async")
	public function testConstructor(asyncFactory:AsyncFactory):Void
	{
		var handler:Dynamic = asyncFactory.createBasicHandler(this, onTestConstructor, 5000);
		timer = Timer.delay(handler, 200);
	}
	
	private function onTestConstructor():Void
	{
		Assert.isFalse(false);
	}
	
	@Test
	public function testBlah():Void
	{
		Assert.isTrue(true);
	}
	
	@Test
	public function testAahr():Void
	{
		Assert.isTrue(true);
	}
}