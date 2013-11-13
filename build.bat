
cd tool
haxe build.hxml
cd ..

haxelib dev munit %CD%\src

cd tool
haxelib run munit test -coverage
cd ..

haxelib run munit test -coverage

haxelib run mlib install 
