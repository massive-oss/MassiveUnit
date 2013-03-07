import massive.munit.TestSuite;

import massive.munit.AssertionExceptionTest;
import massive.munit.AssertTest;
import massive.munit.async.AsyncDelegateTest;
import massive.munit.async.AsyncFactoryTest;
import massive.munit.async.AsyncTimeoutExceptionTest;
import massive.munit.async.MissingAsyncDelegateExceptionTest;
import massive.munit.client.URLRequestTest;
import massive.munit.MUnitExceptionTest;
import massive.munit.TestClassHelperTest;
import massive.munit.TestResultTest;
import massive.munit.TestRunnerTest;
import massive.munit.TestSuiteTest;
import massive.munit.UnhandledExceptionTest;
import massive.munit.util.MathUtilTest;
import massive.munit.util.TimerTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestSuite extends massive.munit.TestSuite
{		

	public function new()
	{
		super();

		add(massive.munit.AssertionExceptionTest);
		add(massive.munit.AssertTest);
		add(massive.munit.async.AsyncDelegateTest);
		add(massive.munit.async.AsyncFactoryTest);
		add(massive.munit.async.AsyncTimeoutExceptionTest);
		add(massive.munit.async.MissingAsyncDelegateExceptionTest);
		add(massive.munit.client.URLRequestTest);
		add(massive.munit.MUnitExceptionTest);
		add(massive.munit.TestClassHelperTest);
		add(massive.munit.TestResultTest);
		add(massive.munit.TestRunnerTest);
		add(massive.munit.TestSuiteTest);
		add(massive.munit.UnhandledExceptionTest);
		add(massive.munit.util.MathUtilTest);
		add(massive.munit.util.TimerTest);
	}
}
