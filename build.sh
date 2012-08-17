#!/bin/bash
set -e

#update allClasses imports
haxelib run mlib allClasses


#compile tool
cd tool
haxe build.hxml
cd ../

#compile core library
cd core
haxe build.hxml
cd ../

#test core and tool

#bash test.sh


echo haxelib run mlib install
#package up and install over current version
haxelib run mlib install