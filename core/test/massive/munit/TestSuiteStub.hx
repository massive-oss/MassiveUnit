package massive.munit;

/**
 * ...
 * @author Mike Stead
 */

class TestSuiteStub extends massive.munit.TestSuite
{
	public function new() 
	{
		super();
		add(TestClassStub);
	}
}