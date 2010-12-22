package massive.munit;

/**
 * ...
 * @author Mike Stead
 */

class TestClassHelperTest 
{
	public function new() 
	{}

	@Test
	public function testConstructor():Void
	{
		var helper:TestClassHelper = new TestClassHelper(TestClassStub);
		
		Assert.isNotNull(helper.test);
		Assert.isType(helper.test, TestClassStub);
		Assert.areEqual(helper.type, TestClassStub);
		
		Assert.areEqual(helper.test.beforeClass, helper.beforeClass);
		Assert.areEqual(helper.test.afterClass, helper.afterClass);
		Assert.areEqual(helper.test.before, helper.before);
		Assert.areEqual(helper.test.after, helper.after);
	}
	
	@Test
	public function testIterator():Void
	{
		var helper:TestClassHelper = new TestClassHelper(TestClassStub);
		
		Assert.isTrue(helper.hasNext());
		Assert.isNotNull(helper.current());
		Assert.areEqual(helper.test.exampleTestOne, helper.current().test);
		Assert.areEqual(helper.test.exampleTestOne, helper.next().test);
		Assert.areEqual(helper.test.exampleTestOne, helper.current().test);
		
		Assert.isFalse(helper.current().result.async);		
		Assert.areEqual(helper.test, helper.current().scope);
		
		Assert.areEqual(helper.test.exampleTestTwo, helper.next().test);
		Assert.areEqual(helper.test.exampleTestTwo, helper.current().test);
		
		Assert.isTrue(helper.current().result.async);
		Assert.areEqual(helper.test, helper.current().scope);

		Assert.isFalse(helper.hasNext());
		Assert.isNull(helper.next());
	}
}