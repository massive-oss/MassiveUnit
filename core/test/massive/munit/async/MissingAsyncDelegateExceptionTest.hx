package massive.munit.async;

import massive.munit.Assert;
/**
 * ...
 * @author Mike Stead
 */

class MissingAsyncDelegateExceptionTest 
{
	public function new() 
	{}

	@Test
	public function testConstructor():Void
	{
		var msg:String = "custom msg";
		var e:MissingAsyncDelegateException = new MissingAsyncDelegateException(msg);
		
		Assert.areEqual(msg, e.message);
		Assert.isNotNull(e.info);
	}
}