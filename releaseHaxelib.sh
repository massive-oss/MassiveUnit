#!/bin/sh
set -e

echo Build command...
echo haxe build.hxml
cd tool
haxe build.hxml

echo Zip haxelib...
cd ../src
rm -f munit.zip
zip -r munit.zip .

echo Submit...
haxelib submit munit.zip
