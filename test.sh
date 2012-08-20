#!/bin/bash
set -e

#test core library
cd core
haxelib run munit test -neko -coverage
haxelib run munit test -cpp -coverage

#test tool
cd ../tool
haxelib run munit test -neko -coverage
cd ../
