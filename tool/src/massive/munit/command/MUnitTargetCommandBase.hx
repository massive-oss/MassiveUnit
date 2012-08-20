package massive.munit.command;

import massive.neko.io.File;

import massive.munit.Config;
import massive.munit.Target;

import massive.neko.io.FileSys;


class MUnitTargetCommandBase extends MUnitCommand
{
	var hxml:File;
	var targets:Array<Target>;
	var targetTypes:Array<TargetType>;

	var includeCoverage:Bool; 

	public function new()
	{
		super();
	}

	override public function initialise():Void
	{
		super.initialise();

			//append code coverage
		var coverage:String  = console.getOption("-coverage");
		includeCoverage = coverage == "true";
	}



	override public function execute():Void
	{
		super.execute();
	}


	function initialiseTargets(getHxmlFromConsole:Bool)
	{
		setTargetTypes();
		setHXMLFile(getHxmlFromConsole);
		setFilteredTargets();

		hxml = config.hxml;
		targetTypes = config.targetTypes;
		targets = config.targets;	
	}

	///////// common utilities

	function getTargetsFromConsole():Array<TargetType>
	{
		var targetTypes = new Array();

		if (console.getOption("swf") == "true")
		{
			targetTypes.push(TargetType.as3);
			targetTypes.push(TargetType.as2);
		}
		else
		{
			if (console.getOption("as2") == "true")
				targetTypes.push(TargetType.as2);
			if (console.getOption("as3") == "true")
				targetTypes.push(TargetType.as3);
		}
		if (console.getOption("js") == "true")
			targetTypes.push(TargetType.js);
		if (console.getOption("neko") == "true")
			targetTypes.push(TargetType.neko);
		if (console.getOption("cpp") == "true")
			targetTypes.push(TargetType.cpp);

		return targetTypes;
	}

	/**
	Updates the config targetTypes if user has specified via the CLI.
	*/
	function setTargetTypes():Void
	{
		if (config.targetTypes != config.defaultTargetTypes) return;

		var targetTypes = getTargetsFromConsole();

		if (targetTypes.length == 0)
			targetTypes = config.targetTypes.concat([]);
		else
			config.targetTypes = targetTypes;//update config targets
	}

	/**
	Updates and validates the hxml file for the project.
	*/
	function setHXMLFile(checkConsole:Bool):Void
	{
		var hxml:File = null;
		var hxmlPath:String = null;

		if (checkConsole) hxmlPath = console.getNextArg();


		if (hxmlPath != null)
		{
			hxml = File.create(hxmlPath, console.dir);

			if (!hxml.exists)
			{
				error("Cannot locate hxml file: " + hxmlPath);
			}

			config.hxml = hxml;//update config hxml file
		}
		else
		{
			hxml = config.hxml;
			
			if (hxml == null)
			{
				error("Default hxml file path is not set. Please run munit config.");
			}
			if (!hxml.exists)
			{
				error("Default hxml file path does not exist. Please run munit config.");
			}			
		}
	}

	/**
	Updates the set of valid targets for the project.
	Note: also removes config.targetTypes that are not present in the hxml.
	*/
	function setFilteredTargets()
	{

		if (config.targets.length > 0 ) return;

		var tempTargets = getTargetsFromHXML(config.hxml);
		
		var targets:Array<Target> = [];

		var tempTargetTypes = [];

		for(target in tempTargets)
		{
			for(type in config.targetTypes)
			{
				if (target.type == type)
				{
					targets.push(target);
					tempTargetTypes.push(type);
					break;
				}
			}
		}

		config.targetTypes = tempTargetTypes;
		config.targets = targets;
	}

	/**
	Parses the contents of an hxml file and returns contents as an array of targets

	@param hxml: path to hxml file
	@return array of Targets
	
	*/
	function getTargetsFromHXML(hxml:File):Array<Target>
	{
		var contents:String = hxml.readString();		
		var lines:Array<String> = contents.split("\n");
		var target:Target = new Target();
		
		var targets:Array<Target> = [];
		
		for (line in lines)
		{
			line = StringTools.trim(line);

			if (line == "" || line.indexOf("#") == 0) continue;
			
			if (line.indexOf("--next") == 0)
			{
				targets.push(target);
				target = new Target();
				continue;
			}
			
			var mainReg:EReg = ~/^-main (.*)/;	
			if (mainReg.match(line))
			{
				target.main = config.src.resolveFile(mainReg.matched(1) + ".hx");
			}

			var flagReg:EReg = ~/^-D (.*)/;
			if (flagReg.match(line))
			{
				var flag = flagReg.matched(1).split(" ");
				target.flags.set(flag.shift(), flag.join(" "));
			}

			if (line == "-debug")
			{
				target.debug = true;
			}

			var fileStr:String = getOutputFileFromLine(line);

			if(target.file == null && fileStr != null)
			{
				//dont add to hxml just yet
				target.file = File.create(fileStr, File.current);
			}
			else
			{
				target.hxml += line + "\n";
			}

			if (target.type == null)
			{
				for(type in config.targetTypes)
				{
					var s:String = null;
					switch(type)
					{
						case TargetType.as2: s = "swf-version 8";
						case TargetType.as3: s = "swf-version [^8]";
						default: s = Std.string(type);
					}	
					var targetMatcher = new EReg("^-" + s, "");
					if (targetMatcher.match(line))
					{
						target.type = type;
						break;
					}
				}
			}

		}

		targets.push(target);

		for(target in targets)
		{
			if(target.type != null)
				updateHxmlOutput(target);
		}

		return targets;
	}

	function updateHxmlOutput(target:Target)
	{
		var output:String = null;

		switch(target.type)
		{
			case TargetType.as2: output = "-swf";
			case TargetType.as3: output = "-swf";
			default: output = "-" + Std.string(target.type);
		}

		var file = config.dir.getRelativePath(target.file);

		if(target.type == TargetType.cpp)
		{
			var executablePath = target.main.name;

			if(target.debug)
			{
				executablePath += "-debug";
			}

			if (FileSys.isWindows)
				executablePath += ".exe";

			target.executableFile = target.file.resolveFile(executablePath);
		}
		else
		{
			target.executableFile = target.file;
		}

		output += " " + file;

		target.hxml += output + "\n";
	}

	function getOutputFileFromLine(line:String):String
	{
		for (type in config.targetTypes)
		{
			var s:String = null;
			switch (type)
			{
				case TargetType.as2: s = "swf";
				case TargetType.as3: s = "swf";
				default: s = Std.string(type);
			}
			var targetMatcher = new EReg("^-" + s + "\\s+", "");
			if (targetMatcher.match(line))
			{
				if(type == cpp && includeCoverage)
				{
					return line.substr(s.length + 2) + "-coverage";
				}
				else
				{
					return line.substr(s.length + 2);
				}

			}
		}
		return null;
	}

}