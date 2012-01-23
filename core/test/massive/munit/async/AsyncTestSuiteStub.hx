package massive.munit.async;

import massive.munit.async.AsyncTestClassStub;
/**
 * Set of stub tests to verify behaviour of async tests during
 * synchronous inline assertions/exceptions
 */
class AsyncTestSuiteStub extends massive.munit.TestSuite
{
	public function new() 
	{
		super();
		add(AsyncTestClassStub);
		add(AsyncTestClassStub2);
	}
}
