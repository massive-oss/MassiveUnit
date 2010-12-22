MassiveUnit
====================

Overview
---------------------

MassiveUnit is a cross-platform haXe unit testing framework from Massive Interactive in Sydney that utilises haxe metadata markup for test cases and includes tools for generating, compiling and running test cases from the command line.

### Features

*	Simple metadata markup for test classes

	@Test
	public function testExample():Void
	{
		Assert.isTrue(true);
	}
	
*	Asynchronous Tests

	@Test("Async")
	public function testAsyncExample():Void
	{
		...
	}	
	
*	Cross platform. Currently supports swf8, swf9, js and neko targets.
	
*	Includes multiple print clients for generating useful reports including JUnit format xml reports

*	Command line tools. munit provides easy commands to get you up and running tests in seconds!

### Installation

To install you must have [haXe](http://www.haxe.org) installed

Then just use haxelib to download the latest version

	haxelib install munit


### Getting Started

More documentation to come.

For now, full help can be accessed from munit

	haxelib run munit help
	
	haxelib run munit help <command>
	