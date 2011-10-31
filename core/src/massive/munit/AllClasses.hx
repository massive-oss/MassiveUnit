package massive.munit;

import massive.munit.Assert;
import massive.munit.AssertionException;
import massive.munit.async.AsyncDelegate;
import massive.munit.async.AsyncFactory;
import massive.munit.async.AsyncTimeoutException;
import massive.munit.async.IAsyncDelegateObserver;
import massive.munit.async.MissingAsyncDelegateException;
import massive.munit.client.HTTPClient;
import massive.munit.client.JUnitReportClient;
import massive.munit.client.PrintClient;
import massive.munit.client.PrintClientHelper;
import massive.munit.ITestResultClient;
import massive.munit.MUnitException;
import massive.munit.TestClassHelper;
import massive.munit.TestResult;
import massive.munit.TestRunner;
import massive.munit.TestSuite;
import massive.munit.UnhandledException;
import massive.munit.util.MathUtil;
import massive.munit.util.Timer;

class AllClasses
{
	public static function main():AllClasses {return new AllClasses();}
	public function new(){trace('This is a generated main class');}
}

