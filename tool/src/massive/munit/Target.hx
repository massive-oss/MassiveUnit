package massive.munit;

import massive.sys.io.File;
import haxe.ds.StringMap;

class Target
{
	public var type:TargetType;
	public var hxml:String = "";
	public var file:File;
	public var main:File;
	public var flags:StringMap<String> = new StringMap();
	public var debug:Bool = false;
	public var executableFile:File;

	public function new() {}
	
	public function toString():String return 'Target ${type} ${file.toString()}';

	public function toHxmlString():String
	{
		var output = "haxe";
		var lines = hxml.split("\n");
		for(line in lines)
		{
			line = StringTools.trim(line);
			if(line == "" || line.indexOf("#") == 0) continue;
			output += " " + line;
		}
		return output;
	}
}

@:enum
@:forward
abstract TargetType(String) from String to String
{
	var as3 = "as3";
	var js = "js";
	var neko = "neko";
	var cpp = "cpp";
	var java = "java";
	var cs = "cs";
	var python = "python";
	var php = "php";
	var hl = "hl";
	var lua = "lua";
}