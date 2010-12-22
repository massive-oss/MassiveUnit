package massive.munit;
import massive.neko.io.File;
class Config
{
	public var currentVersion(default, null):String;
	public var configVersion(default, null):String;
	
	public var dir(default, null):File;
	private var configFile:File;
	
	public var exists(default, null):Bool;
	
	public var bin(default, null):File;
	public var report(default, null):File;
	public var src(default, null):File;
	public var hxml(default, null):File;
	
	public var targets:Array<Target>;
	
	public var targetTypes:Array<TargetType>;
	
	public function new(dir:File, currentVersion:String):Void
	{
		this.dir = dir;
		this.currentVersion = currentVersion;
		
		targetTypes = [TargetType.swf, TargetType.swf9, TargetType.js, TargetType.neko];
		
		configFile = dir.resolveFile(".munit");
		
		exists = configFile.exists;
		
		if(exists)
		{
			load();
		}
	}
		
	private function load():Void
	{
		var lines:Array<String> = configFile.readString().split("\n");
		
		for(line in lines)
		{
			line = StringTools.trim(line);
			if(line.length == 0 || line.substr(0,1) == "#") continue;
			
			var args:Array<String> = line.split("=");
			
			var value:String = args[1];
			if(value == null) continue;
			
			
			if(value.substr(-1) == ";") value = value.substr(0,-1);
			
			switch(args[0])
			{
				case "version": configVersion = value;
				case "src": src = File.create(value, dir);
				case "bin": bin = File.create(value, dir);
				case "report": report = File.create(value, dir);
				case "hxml": hxml = File.create(value, dir);
				
			}
		}
	}
	
	public function remove():Void
	{
		
		configFile.deleteFile();
		exists = false;
		src = null;
		bin = null;
		report = null;
		hxml = null;
		configVersion = null;
		
	}
	
	public function createDefault(?src:File=null, ?bin:File=null, ?report:File=null, ?hxml:File=null):Void
	{
		this.src = src != null ? src : dir.resolveDirectory("test");
		this.bin = bin != null ? bin : dir.resolveDirectory("bin");
		this.report = report != null ? report : dir.resolveDirectory("report");
		this.hxml = hxml != null ? hxml : dir.resolveFile("test.hxml");
		this.configVersion = currentVersion;
		
		
		save();
	}
	
	public function updateSrc(file:File):Void
	{
		if(!file.exists) throw "Directory does not exist " + file;
		if(!file.isDirectory) throw "File is not a directory " + file;
		src = file;
		save();
	}
	
	public function updateBin(file:File):Void
	{
		if(!file.exists) throw "Directory does not exist " + file;
		if(!file.isDirectory) throw "File is not a directory " + file;
		bin = file;
		save();
	}
	
	
	public function updateReport(file:File):Void
	{
		if(!file.exists) throw "Directory does not exist " + file;
		if(!file.isDirectory) throw "File is not a directory " + file;
		report = file;
		save();
	}
	
	
	public function updateHxml(file:File):Void
	{
		if(file.isDirectory) throw "File is a directory " + file;
		hxml = file;
		save();
	}

	
	public function toString():String
	{
		var str:String = "";

		if(currentVersion != null)
		{
			str += "version=" + currentVersion + "\n";
		}
		if(src != null)
		{
			str += "src=" + dir.getRelativePath(src) + "\n";
		}
		if(bin != null)
		{
			str += "bin=" + dir.getRelativePath(bin) + "\n";
		}
		if(report != null)
		{
			str += "report=" + dir.getRelativePath(report) + "\n";
		}
		if(hxml != null)
		{
			str += "hxml=" + dir.getRelativePath(hxml);	
		}
		
		return str;
	}
	
	private function save():Void
	{
		configFile.writeString(toString());	
		
		if(!exists) exists = true;
	}
	
	/*
	version=::version::
	src=::src::
	bin=::bin::
	hxml=::hxml::
	*/
}

enum TargetType
{
	swf;
	swf9;
	js;
	neko;
}

class Target
{
	public var type:TargetType;
	public var hxml:String;
	public var file:File;
	
	public function new():Void
	{
		hxml = "";
	}
	
	public function toString():String
	{
		return "Target " + [type, file];
	}
}