import massive.munit.TestSuite;

import massive.munit.TestRunnerTest;
import massive.munit.async.AsyncTimeoutExceptionTest;
import massive.munit.async.AsyncDelegateTest;
import massive.munit.async.MissingAsyncDelegateExceptionTest;
import massive.munit.async.AsyncFactoryTest;
import massive.munit.AssertTest;
import massive.munit.UnhandledExceptionTest;
import massive.munit.TestClassHelperTest;
import massive.munit.TestSuiteTest;
import massive.munit.client.URLRequestTest;
import massive.munit.TestResultTest;
import massive.munit.util.TimerTest;
import massive.munit.util.MathUtilTest;
import massive.munit.MUnitExceptionTest;
import massive.munit.AssertionExceptionTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestSuite extends massive.munit.TestSuite
{		

	public function new()
	{
		super();

		add(massive.munit.TestRunnerTest);
		add(massive.munit.async.AsyncTimeoutExceptionTest);
		add(massive.munit.async.AsyncDelegateTest);
		add(massive.munit.async.MissingAsyncDelegateExceptionTest);
		add(massive.munit.async.AsyncFactoryTest);
		add(massive.munit.AssertTest);
		add(massive.munit.UnhandledExceptionTest);
		add(massive.munit.TestClassHelperTest);
		add(massive.munit.TestSuiteTest);
		add(massive.munit.client.URLRequestTest);
		add(massive.munit.TestResultTest);
		add(massive.munit.util.TimerTest);
		add(massive.munit.util.MathUtilTest);
		add(massive.munit.MUnitExceptionTest);
		add(massive.munit.AssertionExceptionTest);
	}
}
