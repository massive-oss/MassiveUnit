/**************************************** ****************************************
 * Copyright 2010 Massive Interactive. All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification, are
 * permitted provided that the following conditions are met:
 * 
 *    1. Redistributions of source code must retain the above copyright notice, this list of
 *       conditions and the following disclaimer.
 * 
 *    2. Redistributions in binary form must reproduce the above copyright notice, this list
 *       of conditions and the following disclaimer in the documentation and/or other materials
 *       provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY MASSIVE INTERACTIVE ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL MASSIVE INTERACTIVE OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * The views and conclusions contained in the software and documentation are those of the
 * authors and should not be interpreted as representing official policies, either expressed
 * or implied, of Massive Interactive.
 */
package massive.munit;
import massive.neko.io.File;
import massive.munit.Target;

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
	public var hxml:File;

	public var resources(default, null):File;
	public var templates(default, null):File;

	public var classPaths:Array<File>;
	
	public var targets:Array<Target>;
	
	public var targetTypes:Array<TargetType>;

	public var defaultTargetTypes:Array<TargetType>;

	public var coveragePackages:Array<String>;
	public var coverageIgnoredClasses:Array<String>;
	
	public function new(dir:File, currentVersion:String):Void
	{
		this.dir = dir;
		this.currentVersion = currentVersion;
		
		defaultTargetTypes = [TargetType.as2, TargetType.as3, TargetType.js, TargetType.neko, TargetType.cpp];
		targetTypes = defaultTargetTypes;
		targets = [];

		configFile = dir.resolveFile(".munit");
		
		exists = configFile.exists;
		
		if(exists)
		{
			load();
		}
	}
		
	public function load(?file:File):Void
	{
		if(file == null) file = configFile;
		parseConfig(file.readString());
	}

	private function parseConfig(string:String)
	{
		var lines:Array<String>  = string.split("\n");
	
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
				case "src": src = File.create(value, dir, true);
				case "bin": bin = File.create(value, dir, true);
				case "report": report = File.create(value, dir, true);
				case "hxml": hxml = File.create(value, dir);
				case "resources": resources = value != "null" ? File.create(value, dir) : null;
				case "templates": templates = value != "null" ? File.create(value, dir) : null;
				case "classPaths" :
				{
					var paths = value.split(",");
					classPaths = [];
					for(path in paths)
					{
						classPaths.push(File.create(path, dir, true));
					}
				}
				case "coveragePackages": coveragePackages = value != "null" ? value.split(",") : null;
				case "coverageIgnoredClasses": coverageIgnoredClasses = value != "null" ? value.split(",") : null;
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
		classPaths = [];

		resources = null;
		templates = null;

		coveragePackages = null;
		coverageIgnoredClasses = null;
	}
	
	public function createDefault(?src:File=null, ?bin:File=null, ?report:File=null, ?hxml:File=null, ?classPaths:Array<File>=null, ?resources:File=null, ?templates:File=null, ?coveragePackages:Array<String>=null, ?coverageIgnoredClasses:Array<String>=null):Void
	{
		this.src = src != null ? src : dir.resolveDirectory("test", true);
		this.bin = bin != null ? bin : dir.resolveDirectory("bin", true);
		this.report = report != null ? report : dir.resolveDirectory("report", true);
		this.hxml = hxml != null ? hxml : dir.resolveFile("test.hxml");
		this.classPaths = classPaths != null ? classPaths : [dir.resolveDirectory("src", true)];
		this.resources = resources != null ? resources : null;
		this.templates = templates != null ? templates : null;
		this.configVersion = currentVersion;
		this.coveragePackages = coveragePackages != null ? coveragePackages : null;
		this.coverageIgnoredClasses = coverageIgnoredClasses != null ? coverageIgnoredClasses : null;

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

	public function updateResources(file:File):Void
	{
		if(!file.exists) throw "Directory does not exist " + file;
		if(!file.isDirectory) throw "File is not a directory " + file;
		resources = file;
		save();
	}

	public function updateTemplates(file:File):Void
	{
		if(!file.exists) throw "Directory does not exist " + file;
		if(!file.isDirectory) throw "File is not a directory " + file;
		templates = file;
		save();
	}

	public function updateClassPaths(classPaths:Array<File>):Void
	{
		for(file in classPaths)
		{
			if(!file.exists) throw "Class path does not exist " + file;
			if(!file.isDirectory) throw "Class path is not a directory " + file;

		}
		this.classPaths = classPaths;
		save();
	}

	public function updateCoveragePackages(coveragePackages:Array<String>):Void
	{
		this.coveragePackages = coveragePackages;
		save();
	}

	public function updateCoverageIgnoredClasses(coverageIgnoredClasses:Array<String>):Void
	{
		this.coverageIgnoredClasses = coverageIgnoredClasses;
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
			str += "hxml=" + dir.getRelativePath(hxml) + "\n";	
		}
		if(classPaths != null)
		{
			var value = "";
			for(path in classPaths)
			{
				if(value != "") value += ",";
				value += dir.getRelativePath(path);
				
			}
			str += "classPaths=" + value + "\n";
		}
		if(resources != null)
		{
			str += "resources=" + dir.getRelativePath(resources) + "\n";	
		}
		if(templates != null)
		{
			str += "templates=" + dir.getRelativePath(templates) + "\n";	
		}
		if(coveragePackages != null)
		{
			str += "coveragePackages=" + coveragePackages.join(",") + "\n";
		}
		if(coverageIgnoredClasses != null)
		{
			str += "coverageIgnoredClasses=" + coverageIgnoredClasses.join(",") + "\n";
		}
		
		return str;
	}
	
	public function save():Void
	{
		configFile.writeString(toString());	
		
		if(!exists) exists = true;
	}
	
	/*
	version=::version::
	src=::src::
	bin=::bin::
	hxml=::hxml::
	classPaths=::classPaths::
	resources=::resources::
	templates=::templates::
	coveragePackages=::coveragePackages::
	coverageIgnoredClasses=::coverageIgnoredClasses::
	*/
}

