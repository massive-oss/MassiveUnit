MassiveUnit
====================

MassiveUnit is a meta-data driven unit testing framework for cross-platform haXe development.

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

	@Test("Async")
	public function testAsyncExample(factory:AsyncFactory):Void
	{
		...
	}

### Tool Chain

MassiveUnit is way more than just a unit test framework. It includes a command line tool for working with munit projects to streamline your development workflow.

*	Setup stub test projects in seconds
*	Auto generate test suites based on test classes in a src directory
*	Compile and run multiple targets from an hxml build file
*	Launch and run test applications in the browser or command line (neko)
*	Save out junit style test reports to the file system for reporting and ci




Installation
---------------------

To install you must have [haXe](http://www.haxe.org) installed

Then just use haxelib to download the latest version

	haxelib install munit


To check that it is all installed and to view the help run:

	haxelib run munit

	