package massive.munit;

/**
 * ...
 * @author Mike Stead
 */

class AssertionExceptionTest 
{
	public function new() 
	{}
	
	@Test
	public function testConstructor():Void
	{
		var msg:String = "custom msg";
		var e:AssertionException = new AssertionException(msg);
		
		Assert.areEqual(msg, e.message);
		Assert.isNotNull(e.info);
	}
}