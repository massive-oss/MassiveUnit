package massive.munit;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import massive.munit.UnhandledException;
import massive.haxe.util.ReflectUtil;
class UnhandledExceptionTest 
{
	var instance:UnhandledException; 
	
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
		try
		{
			throw "";
		}
		catch(e:Dynamic)
		{
			var source = "original msg";
			var location:String = "location";
			var exception = new UnhandledException(source, location);
			Assert.isNull(exception.info);
			Assert.isTrue(exception.message.indexOf(source) == 0);
			Assert.isTrue(exception.message.indexOf(" at " + location) > 0);
		}
	}
	
}