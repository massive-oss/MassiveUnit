haxelib run mlib allClasses

cd tool
haxe build.hxml
cd ../

cd core
haxe build.hxml
cd ../

haxelib run mlib install