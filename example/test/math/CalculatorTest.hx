package math;

import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

class CalculatorTest 
{
	var calculator:Calculator;
	
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
	public function setup():Void
	{
		calculator = new Calculator();
	}
	
	@After
	public function tearDown():Void
	{
	}
	
	@Test
	public function shouldAddXToY()
	{
		Assert.areEqual(5, calculator.add(3, 2));
	}
	
	@AsyncTest
	public function shouldAddXToYAfterDelay(factory:AsyncFactory):Void
	{
		var resultHandler:Dynamic = factory.createHandler(this, verifyShouldAddXToYAfterDelay, 1000);
		calculator.addAsync(3, 2, resultHandler);
	}
	
	function verifyShouldAddXToYAfterDelay(result:Int):Void
	{
		Assert.areEqual(5, result);
	}
}