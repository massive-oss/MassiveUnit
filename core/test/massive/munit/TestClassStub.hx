package massive.munit;
import massive.munit.async.AsyncFactory;
import massive.munit.util.Timer;

/**
 * ...
 * @author Mike Stead
 */

class TestClassStub 
{
	public function new() 
	{}
	
	@BeforeClass
	public function beforeClass():Void
	{
	}
	
	@AfterClass
	public function afterClass():Void
	{
	}
	
	@Before
	public function before():Void
	{
	}
	
	@After
	public function after():Void
	{
	}
	
	@Test
	public function exampleTestOne():Void
	{
		Assert.isTrue(false);
	}
	
	@Test("Async")
	public function exampleTestTwo(factory:AsyncFactory):Void
	{
		var handler:Dynamic = factory.createBasicHandler(this, onExampleTestTwo, 200);
		Timer.delay(handler, 100);
	}
	
	private function onExampleTestTwo():Void
	{
		Assert.isTrue(true);
	}
}