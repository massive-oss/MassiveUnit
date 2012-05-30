#test core library
cd core
haxelib run munit test -neko -coverage

#test tool
cd ../tool
haxelib run munit test -neko -coverage
cd ../
