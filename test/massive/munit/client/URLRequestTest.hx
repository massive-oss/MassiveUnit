package massive.munit.client;

import massive.munit.Assert;
import massive.munit.client.HTTPClient.URLRequest;

/**
 * Auto generated MassiveUnit Test Class  for massive.munit.client.URLRequest 
 */
class URLRequestTest 
{
	public function new() {}
	
	@Test
	public function testConstructor()
	{
		var url = "http://www.example.org";
		var instance = new URLRequest(url);
		Assert.isNotNull(instance.client);
		#if (js || neko || cpp || java || cs)
		Assert.areEqual(url, instance.client.url);
		#end
	}
}