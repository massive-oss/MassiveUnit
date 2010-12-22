package massive.munit;

/**
 * ...
 * @author Mike Stead
 */

class TestSuiteTest 
{
	private var suite:massive.munit.TestSuite;

	public function new() 
	{}
	
	@Before
	public function setup():Void
	{
		suite = new massive.munit.TestSuite();
	}
	
	@After
	public function tearDown():Void
	{
		suite = null;
	}
	
	@Test
	public function testConstructor():Void
	{
		Assert.isFalse(suite.hasNext());
	}
	
	@Test
	public function testAdd():Void
	{
		suite.add(TestSuiteTest);
		Assert.isTrue(suite.hasNext());
	}
	
	@Test
	public function testIterator():Void
	{
		suite.add(TestSuiteTest);
		suite.add(TestRunnerTest);
		
		Assert.isTrue(suite.hasNext());		
		Assert.areEqual(TestRunnerTest, suite.next());
		Assert.isTrue(suite.hasNext());
		Assert.areEqual(TestSuiteTest, suite.next());
		Assert.isFalse(suite.hasNext());
		
		suite.repeat();

		Assert.isTrue(suite.hasNext());
		Assert.areEqual(TestSuiteTest, suite.next());
	}
}