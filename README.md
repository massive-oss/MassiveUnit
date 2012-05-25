MassiveUnit
====================

MassiveUnit is a metadata driven unit testing framework for cross-platform haXe development.

It includes tools for creating, updating, compiling and running unit test cases from the command line.

For more information see the **[wiki](https://github.com/massiveinteractive/MassiveUnit/wiki)**

Features
---------------------

### Cross Platform

MassiveUnit has been designed for cross platform haXe development.
It currently supports swf8, swf9, js and neko, and the tool chain works on PC and OSX

### Test Metadata

Test cases use haXe metadata to simplify creating tests (and avoid needing to extend or implement framework classes).

	@Test
	public function testExample():Void
	{
		Assert.isTrue(true);
	}

### Asynchronous Tests

Unlike the default haxe unit test classes, MassiveUnit supports asynchronous testing

	@AsyncTest
	public function asyncTestExample(factory:AsyncFactory):Void
	{
		...
	}

### Tool Chain

MassiveUnit is way more than just a unit test framework. It includes a command line tool for working with munit projects to streamline your development workflow.

*	Setup stub test projects in seconds
*	Auto generate test suites based on test classes in a src directory
*	Compile and run multiple targets from an hxml build file
*	Launch and run test applications in the browser or command line (neko)
*	Save out text and junit style test reports to the file system for reporting and ci
*	Auto generate stub test classes (and/or target classes) (new in 0.9.2.0)
*	Integrated code coverage compilation with MCover (new in 0.9.2.0)


Installation
---------------------

To install you must have [haXe](http://www.haxe.org) installed

Then just use haxelib to download the latest version

	haxelib install munit


To check that it is all installed and to view the help run:

	haxelib run munit



New since 0.9.3.x
--------------------

### Better CI support

Get error exit code when tests on one or more platforms fail

	haxelib run munit test -exit-on-fail

Workaround for issues with nekotools server HTTP POST via a simple SummaryReportClient

	runner.addResultClient(new HTTPClient(new SummaryReportClient()));


New since 0.9.2.x
---------------------

Rich HTML output for JavaScript and Flash targets (see RichPrintClient)

	var client = new RichPrintClient();

Seamless support for MCover code coverage

	haxelib run munit test -coverage

Commands for generating stub test classes on demand

	haxelib run munit create package.FooTest -for package.Foo  

CI friendly options for munit config command

	haxelib run munit config -default
	haxelib run munit config -src path/to/src -hxml path/to/test.hxml
	haxelib run munit config -file path/to/my/custom/config.txt

Support for assertions inside async tests

	public function someAsyncTest(factory:AsyncFactory)
	{
		Assert.isTrue(false);
	}

Support for custom runner html templates and resources

```Run 'munit config' to set template and resources directories```





For full list of recent changes see the **[change log](https://github.com/massiveinteractive/MassiveUnit/blob/master/CHANGES.txt)**

	