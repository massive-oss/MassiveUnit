
MUnit is a metadata driven unit testing framework for cross-platform Haxe development.

It includes tools for creating, updating, compiling and running unit test cases from the command line.

Installation
---------------------

To install you must have [Haxe](http://www.haxe.org) installed

Then just use haxelib to download the latest version

	haxelib install munit

To check that it is all installed and to view the help run:

	haxelib run munit


**Please note:** After upgrading you may be required to update the TestMain.hx in existing project before being able to test with -coverage


Features
---------------------

### Cross Platform

MUnit has been designed for cross platform Haxe development.
It currently supports js, swf8, swf9, neko and c++ (beta, see note below), and the tool chain works on PC and OSX

> Note: C++ target is currently in beta. Only supported using hxcpp 2.10 or greater (Haxe 2.09/Haxe 2.10). All other targets supported in Haxe 2.08 +


### Test Metadata

Test cases use Haxe metadata to simplify creating tests (and avoid needing to extend or implement framework classes).

	@Test
	public function testExample():Void
	{
		Assert.isTrue(true);
	}

### Asynchronous Tests

Unlike the default haxe unit test classes, MUnit supports asynchronous testing

	@AsyncTest
	public function asyncTestExample(factory:AsyncFactory):Void
	{
		...
	}

### Tool Chain

MUnit is way more than just a unit test framework. It includes a command line tool for working with munit projects to streamline your development workflow.

*	Setup stub test projects in seconds
*	Auto generate test suites based on test classes in a src directory
*	Compile and run multiple targets from an hxml build file
*	Launch and run test applications in the browser or command line (neko)
*	Save out text and junit style test reports to the file system for reporting and ci
*	Auto generate stub test classes (and/or target classes)
*	Integrated code coverage compilation with [MCover](https://github.com/massiveinteractive/MassiveCover)



## Documentation


For detailed user guides refer to the **[wiki](https://github.com/massiveinteractive/MassiveUnit/wiki)**

The API documentation is available on the [haxelib project page](http://lib.haxe.org/d/munit).


## How to contribute

If you find a bug, [report it](https://github.com/massiveinteractive/MassiveUnit/issues).

If you want to help, [fork it](https://github.com/massiveinteractive/MassiveUnit/fork_select).

If you want to make sure it works, make sure to run the bash script (build.sh) and check that the tests all pass on all platforms:

	cd core
	haxelib run munit test -coverage

	cd ../test
	haxelib run munit test -coverage


New since 0.9.5.x
--------------------

### C++ Target

MUnit now compiles/runs c++ targets

	haxelib run munit test -cpp

Updates to TestMain to work with MCover 1.4.x

	Note: You may be required to update the TestMain.hx in existing project
	before being able to run `munit test -coverage`.

### Code Coverage customisation

Munit now supports custom [mcover](https://github.com/massiveinteractive/MassiveCover) settings when compiling via `munit test -coverage`.

re-run `haxelib run munit config` in a project to set `coverage packages` and `coverage ignored classes`

Thanks to [tynril](https://github.com/tynril) for adding these options.


New since 0.9.4.x
--------------------

### Report Command

Convert munit summary reports into different format(s). As of 0.9.4.0 there is only one supported format (TeamCity)

	haxelib run munit report [format] [dest] [-coverage percent]

Example:

The following example generates a teamcity-info.xml report in the project directory (.)

	haxelib run munit report teamcity . -coverage 85

> Note: You must run and generated summary reports prior to executing the report command. 



New since 0.9.3.x
--------------------

### Better CI support

Get error exit code when tests on one or more platforms fail

	haxelib run munit test -result-exit-code

> Note: haxelib currently doesnt return exit codes > 0 on OSX (see [issue](http://code.google.com/p/haxe/issues/detail?id=879))

Workaround for issues with nekotools server HTTP POST via a simple SummaryReportClient
	
	var httpClient = new HTTPClient(new SummaryReportClient())
	runner.addResultClient(httpClient);


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


For full list of recent changes see the **[change log](https://github.com/massiveinteractive/MassiveUnit/blob/master/CHANGES)**




## Credits

This project is brought to you by [Dominic](https://github.com/misprintt) and [Mike](https://github.com/mikestead) 
from [Massive Interactive](http://massiveinteractive.com)

	