package massive.munit;

import massive.sys.io.File;

#if haxe3
import haxe.ds.StringMap;
#else
private typedef StringMap<T> = Hash<T>
#end


class Target
{
	public var type:TargetType;
	public var hxml:String;
	public var file:File;
	public var main:File;
	public var flags:StringMap<String>;
	public var debug:Bool;

	public var executableFile:File;

	public function new():Void
	{
		hxml = "";
		debug = false;
		flags = new StringMap();
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