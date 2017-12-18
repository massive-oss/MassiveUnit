package;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

/**
 * Auto generated ExampleTest for MassiveUnit.
 * This is an example test class can be used as a template for writing normal and async tests
 * Refer to munit command line tool for more information (haxelib run munit)
 */
class ExampleTest 
{
	public function new()
	{
	}
	
	@BeforeClass
	public function beforeClass()
	{
	}
	
	@AfterClass
	public function afterClass()
	{
	}
	
	@Before
	public function setup()
	{
	}
	
	@After
	public function tearDown()
	{
	}
	
	@Test
	public function testExample()
	{
		Assert.isTrue(true);
	}
	
	@AsyncTest
	public function testAsyncExample(factory:AsyncFactory)
	{
		var handler:Dynamic = factory.createHandler(this, onTestAsyncExampleComplete, 300);
		var timer = Timer.delay(handler, 200);
	}
	
	function onTestAsyncExampleComplete()
	{
		Assert.isFalse(false);
	}
	
	/**
	 * test that only runs when compiled with the -D testDebug flag
	 */
	@TestDebug
	public function testExampleThatOnlyRunsWithDebugFlag()
	{
		Assert.isTrue(true);
	}
	
}