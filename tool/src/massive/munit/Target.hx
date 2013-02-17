package massive.munit;

import massive.sys.io.File;

class Target
{
	public var type:TargetType;
	public var hxml:String;
	public var file:File;
	public var main:File;
	public var flags:Map<String,String>;
	public var debug:Bool;

	public var executableFile:File;

	public function new():Void
	{
		hxml = "";
		debug = false;
		flags = new Map();
	}
	
	public function toString():String
	{

		return "Target " + Std.string(type) + " " + file.toString();
	}

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

enum TargetType
{
	as2;
	as3;
	js;
	neko;
	cpp;
}