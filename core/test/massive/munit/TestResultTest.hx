package massive.munit;

/**
 * ...
 * @author Mike Stead
 */

class TestResultTest 
{
	public function new() 
	{}
	
	@Test
	public function testConstructor():Void
	{
		var result:TestResult = new TestResult();
		Assert.isFalse(result.passed);
		Assert.areEqual(0.0, result.executionTime);
		Assert.areEqual("", result.name);
		Assert.areEqual("", result.className);
		Assert.areEqual("", result.location);
		Assert.isFalse(result.async);
		Assert.isNull(result.error);
		Assert.isNull(result.failure);
	}
	
	@Test
	public function testLocation():Void
	{
		var result:TestResult = new TestResult();
		result.name = here.methodName;
		Assert.areEqual("#" + here.methodName, result.location);
		
		result = new TestResult();
		result.className = here.className;
		Assert.areEqual(here.className + "#", result.location);
		
		result = new TestResult();
		result.name = here.methodName;
		result.className = here.className;
		Assert.areEqual(here.className + "#" + here.methodName, result.location);
	}
}