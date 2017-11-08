## dev
- Added cs support
- Added java support
- Dropped support for Haxe 2
- Dropped support for flash8
- Dropped support for flash9

## 2.1.2

- [#77](https://github.com/massiveinteractive/MassiveUnit/pull/77) Windows and FlashDevelop compatibility.
- [#89](https://github.com/massiveinteractive/MassiveUnit/pull/89) Easily add a delay before the test suite runs.
- [#99](https://github.com/massiveinteractive/MassiveUnit/pull/99) Completed TestSuites are available for GC.
- [#102](https://github.com/massiveinteractive/MassiveUnit/pull/102) Fixes munit hanging when the haxe compiler spits too many errors.
- [#105](https://github.com/massiveinteractive/MassiveUnit/pull/105) The server output must be read, otherwise it hits a 4kb buffer limit.
- [#106](https://github.com/massiveinteractive/MassiveUnit/pull/106) Adding custom timeout option.

## 2.1.1
- Recompile binaries for backwards compatibility with neko v1.8
- Remove dependency on hamcrest

## 2.1.0

- Adds support to launch tests in FlashDevelop browser
- No longer displays test classes when no tests are executed
- Improved nodejs support

## 2.0.3

- Minor pattern matching fix for stricter 3.next (backwards compatible)

## 2.0.x
- Added haxelib.json
- Added support for Haxe3
- Some breaking changes to APIs and interfaces for Haxe 3 compatibility
- Cleaned up folder structure to support haxelib dev path on src

## 0.9.6.x - 
-  Minor tweaks for Haxe svn (2.11) using --no-inline and mockatoo

## 0.9.6 - 09-11-12
- Included support for enum equality checking through Assert.areEqual/areNotEqual.
- Added Assert.areSame/areNotSame for strict equality checks. 
- Update to fix --js-modern errors.

## 0.9.5.2.2 - 21.08.12
- TestCommand prints stderr even if exit code is 0 from haxe compiler

## 0.9.5.2.1 - 21.08.12
- reverted '#if mcover' to '#if MCOVER' in template

## 0.9.5.2 - 21.08.12
- added forced update to testmain to use coverage
- added clearer CLI warning if TestMain uses outdated mcover references
- update TestMain template to use '#if mcover' rather than '#if MCOVER' (still checks for both for backwards compatibility)

## 0.9.5.1 - 20.08.12
- neko/cpp: Added catch for when process throws exception before process.exitCode()
- cpp: Remove executable before re-compiling
- cpp: Added CLI support for cpp TestMain-debug executables
- cli: Added Target.executableFile for targets that output a directory
- all: updated integration with mcover 1.4.0

## 0.9.5.0 - 19.08.12
- new : added cpp support (beta - hxcpp 2.09 only)
- all : updated internals of test/run/report commands
- all : removed optional params from ICoverageTestResultClient due to incompatibility with hxcpp209
- all : updated examples to include cpp target
- neko : updated references to use Sys rather than neko.Sys
- all : run command only copies compiled target files from bin directory to test-runner (ignores other directories and files)
- cpp: compile coverage and non-coverage versions of cpp target to different directories (appends '-coverage' to cpp output dir) to prevent full recompile when switching between the two
- all: merged pull request #38 from tynril - adding custom coverage include/ignored packages to munit config 

## 0.9.4.3 - 17.08.12
- all: Fixed issue #36 - trace statements no longer appear in print client output
- removed haxe.trace redirect from AbstractTestResultClient, now only in concrete instances
- traces now logged to static array to prevent dropped traces when print clients compose other print clients

## 0.9.4.2 - 23.07.12
- all: Fixed Issue #35 - TestMain template uses incorrect coverage package

## 0.9.4.1 - 14.07.12
- flash: Fixed issue #32 - icons don't always appear in result client for AS3 
- flash, js : moved html print client icons into single spritesheet
- flash, js : cleaned up js and css on html print client (and html templates)
- flash : Fixed issue #29 detect debug flash player for as3 targets and print warning if not available
- flash : UnhandledException only generates native flash stack trace if Capabilities.isDebugger is true
- flash : Fixed issue #27 - Use name of swf file in hxml
- all : changed how target files are located in RunCommand (TestCommadn generates temp files containing target file locations )

## 0.9.4.0 - 02.07.12
- added report command
- added ReportFormatter and TeamCityReportFormatter

## 0.9.3.3 - 29.06.12
- fixed '-debug' option not being detected correctly
- fixed occassional issue on Windows with line return encoding in hxml file.
- changed icon for code coverage

## 0.9.3.2 - 22.06.12
- Bug fix: AsyncTest with successful sync asserts causing runner to execute out of order.

## 0.9.3.1
- hotfix for 9.3.0

## 0.9.3.0 - 25.05.12
- Improved CI support
- Added -result-exit-code option for exiting if tests on one or more platforms fail.
- Added simple SummaryReportClient to en in the testable results back to command line without incurring HTTP POST bugs in nekotools server.
- Re-enabled http result clients for examples

## 0.9.2.6 - 23.05.12
- added example for junit report functionality
- enabled permature exitcode (1) if either the neko test app or the browser returns exit code > 0

## 0.9.2.5
- Minor hotfix for linux

## 0.9.2.4 - 09.05.12
- Fixed tooling issues on Linux due to location of tmp nekotools server files
- Fixed https://github.com/massiveinteractive/MassiveUnit/issues/8 (test runner not respecting targets in hxml file)
- moved tmp runner directory (and nekotools server file) on osx and linux targets to local bin directory. Windows remained as is

## 0.9.2.3 - 31.03.12
- Added configuration for project specific html templates
- Added configuration for project specific runner resources
- Added new example: examples/02_customTemplates 

## 0.9.2.2 - 28.02.12
- Added support for synchronous assertions inside async tests.
- Fixed related bug with exceptions inside async tests not removing async timeout.
- Fixed bug with neko tests not running from local project directory.
- Updated coverage support to MCover 1.2.x

## 0.9.2.1 - 22.11.11
- Added rich html print client
- added support for MCover
- added command line apis for creating stub test classes,
- minor additions to .munit project config file.
- Fixed bug with as2/as3 targets being compiled when not targets

## 0.9.2.0 - 22.11.2011
- Added RichPrintClient outputs rich html for js/flash targets
- Added integrated support for mcover code coverage ('munit test -coverage').
- Added support for creating stub tests (and stub classes if they dont already exist)
	- 'munit create com.FooTest'
	- 'munit create -for com.Foo'
	- 'munit create FooBarTest -for com.Foo'
- Added support for setting .munit project configuration from an existing file ('munit config -file [path]')
- Added support for setting default .munit project properties (munit config -default)
- Added support for setting .munit properties inline (e.g. 'munit config -src path/to/test')
- Added new classPath(s) property to .munit config file to facilitate coverage and stub class creation

## 0.9.1.8 - 11.10.2011
- Added hamcrest support.

## 0.9.1.7 - 7.10.2011
- Added -debug flag to command line tool to run only tests marked with @TestDebug.
- Switched to using monospace font when printing results in browser.
- Now auto removes old test runner files not being executed in latest test run.

## 0.9.1.6 - 13.9.2011
- Improved HTML Test Runner output (displays as2/as3 results in HTML using same styles as JS). Fixed AsyncTest race condition bug where timeout and response handlers execute out of order when both occur on same frame (as2/as3 targets only)

## 0.9.1.5 - 5.9.2011
- Added support for @Ignore("optional explanation") tag against @Test method. More info here https://github.com/massiveinteractive/MassiveUnit/wiki/Working-with-test-classes

## 0.9.1.4 - 3.9.2011

- Added support for tag inheritance, i.e. @Test in super classes now picked up.
- Added support for stack trace in uncaught exceptions for AS3 and Neko targets (unable to get this info in other supported targets).
- Deprecated @Test("Async"). Introduced @AsyncTest tag in its place.
- Updated example in project.
- Added haxelib docs to lib package, should now appear on lib.haxe.org.

## 0.9.1.3 - 18.8.2011

- Fixed win bug where spaces in path to neko test file would cause file not to be found.
- Updated munit config to generate template test.hxml file if one doesn't exist.
- Gen command now creates test directory if one doesn't exist.
- Update command line runner help files.
- Made sure HTTPClient POSTs reports across all supported platforms.
- Still open issue of nekoserver hanging. See http://lists.motion-twin.com/pipermail/neko/2011-August/002913.html

## 0.9.1.2 - 27.7.2011

- Updated test runner tool to run multiple target tests in parallel instead of sequentially (good speed boost).
- Local result server is now opened once per test run instead of for each target in test run.
- Fix major bug where local results server could crash when receiving result string.
- Browser based tests are now presented in multi-framed browser page.
- Reversed option to close browser on completion so default is to keep it open now. -kill-browser to close it (Chrome only due to javascript restrictions)
- Remove -swf8 and -swf9 options and replace with -as2 and -as3. Sorry if this causes any headaches but wanted to future proof this. -as2 (ActionScript 2) covers Flash v6-v8, -as3 (ActoinScript 3) for anything greater. Can still use -swf option to run both as2 and as3 tests.
