package massive.munit;

/**
 * ...
 * @author Mike Stead
 */

class MUnitExceptionTest 
{
	public function new() 
	{}

	@Test
	public function testConstructor():Void
	{
		var msg:String = "custom msg";
		var e:MUnitException = new MUnitException(msg);
		
		Assert.areEqual(msg, e.message);
		Assert.isNotNull(e.info);
	}
	
	@Test
	public function testToString():Void
	{
		var msg:String = "custom msg";
		var line:Int = here.lineNumber + 1;
		var e:MUnitException = new MUnitException(msg, here);
		
		var str:String = Type.getClassName(MUnitException) + ": " + msg + " at " + here.className + "#" + here.methodName + " (" + line + ")";
		Assert.areEqual(str, e.toString());
	}
}