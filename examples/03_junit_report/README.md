

Examples: Junit and Txt reports
===========

The following example demonstrates support for junit reports by adding the appropriate client to the TestMain runner

		runner.addResultClient(new massive.munit.client.HTTPClient(new massive.munit.client.JUnitReportClient()));


Output
------

Both txt and junit reports can be located in the report/test directory.

Seperate junit reports are generated for each target platform.


Known issues
------------

Please refer to latest [Known Issues](https://github.com/massiveinteractive/MassiveUnit/wiki/Compiling-and-running-tests) on the wiki.

In summary - there are several issues with the NekoVM that may cause problems when using the nekottols server

Windows Only:

- browser targets break in Safari due to manformed header information injected into html body
- bad stack trace in Fatal error in gc: Bad stack base in GC_register_my_thread_inner

All platforms:

- POST HTTP requests fail when aggregate total across all targets exceeds a certain size 

