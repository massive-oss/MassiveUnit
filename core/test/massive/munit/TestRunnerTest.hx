package massive.munit;
import massive.munit.client.PrintClient;
import massive.munit.async.AsyncFactory;

/**
 * ...
 * @author Mike Stead
 */
class TestRunnerTest 
{
	private var runner:TestRunner;
	private var client:TestResultClientStub;
	private var assertionCount:Int;
	
	public function new() 
	{}
	
	@Before
	public function setup():Void
	{
		client = new TestResultClientStub();
		runner = new TestRunner(client);
	}
	
	@After
	public function tearDown():Void
	{
		runner = null;
		client = null;
	}
	
	@Test
	public function testConstructor():Void
	{
		Assert.areEqual(1, runner.clientCount);
		Assert.isFalse(runner.running);
	}
	
	@Test
	public function testAddResultClient():Void
	{
		Assert.areEqual(1, runner.clientCount);		
		runner.addResultClient(client);
		Assert.areEqual(1, runner.clientCount);
		
		var client2 = new PrintClient();
		runner.addResultClient(client2);
		Assert.areEqual(2, runner.clientCount);
	}
	
	@Test("Async")
	public function testRun(factory:AsyncFactory):Void
	{
		// save assertion count in this runner instance. Ugly.
		assertionCount = Assert.assertionCount;
		
		var suites = new Array<Class<massive.munit.TestSuite>>();
		suites.push(TestSuiteStub);
		runner.completionHandler = factory.createHandler(this, completionHandler, 5000);
		runner.run(suites);
	}
	
	private function completionHandler(isSuccessful:Bool):Void
	{
		// restore assertion count
		Assert.assertionCount = assertionCount;
		
		Assert.isFalse(isSuccessful);
		Assert.areEqual(2, client.testCount);
		Assert.areEqual(2, client.finalTestCount);
		Assert.areEqual(1, client.passCount);
		Assert.areEqual(1, client.finalPassCount);
		Assert.areEqual(1, client.failCount);
		Assert.areEqual(1, client.finalFailCount);
		Assert.areEqual(0, client.errorCount);
		Assert.areEqual(0, client.finalErrorCount);
	}
}