#!/bin/bash
set -e

## compile tool
cd tool
haxe build.hxml
cd ../

## set dev directory for testing
haxelib dev munit `pwd`/src

## run tool tests

cd tool
haxelib run munit test -coverage
cd ../

## run core tests
haxelib run munit test -coverage


## package up and install over current version
haxelib run mlib install