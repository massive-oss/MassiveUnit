package massive.munit.client;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import massive.munit.client.HTTPClient;
/**
* Auto generated MassiveUnit Test Class  for massive.munit.client.URLRequest 
*/
class URLRequestTest 
{
	var instance:URLRequest; 
	
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
		var url = "http://www.example.org";
		instance = new URLRequest(url);
		
		Assert.isNotNull(instance.client);
		
		#if (js || neko || cpp)
			Assert.areEqual(url, instance.client.url);
		#elseif flash9
			Assert.areEqual(url, instance.client.url);
		#elseif flash
			
		#end
	}
}