To generate the TestSuite (and the TestMain if it doesn't exist):
haxelib run munit gen -test test


To compile and run all the targets in the test.hxml build file:
haxelib run munit build -hxml test.hxml -out bin


To run a single compiled target:
haxelib run munit run -file main_test.swf -out bin
