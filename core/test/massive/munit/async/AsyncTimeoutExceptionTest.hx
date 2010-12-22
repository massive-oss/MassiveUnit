package massive.munit.async;

import massive.munit.Assert;

/**
 * ...
 * @author Mike Stead
 */
class AsyncTimeoutExceptionTest
{
	public function new() 
	{}

	@Test
	public function testConstructor():Void
	{
		var msg:String = "custom msg";
		var e:AsyncTimeoutException = new AsyncTimeoutException(msg);
		
		Assert.areEqual(msg, e.message);
		Assert.isNotNull(e.info);
	}
}