package massive.munit.command;

import massive.neko.haxe.HaxeWrapper;
import massive.neko.io.File;
import massive.neko.io.FileSys;
import massive.neko.util.PathUtil;
import massive.munit.Config;
import massive.haxe.log.Log;

class TestCommand extends MUnitCommand
{

	private var hxml:File;
	private var targets:Array<Target>;
	private var targetTypes:Array<TargetType>;

	public function new():Void
	{
		super();
	}

	override public function initialise():Void
	{
		targetTypes = new Array();
		
		if(console.getOption("swf") == "true") targetTypes.push(TargetType.swf);
		if(console.getOption("swf9") == "true") targetTypes.push(TargetType.swf9);
		if(console.getOption("js") == "true") targetTypes.push(TargetType.js);
		if(console.getOption("neko") == "true") targetTypes.push(TargetType.neko);
		
		if(targetTypes.length == 0)
		{
			targetTypes = config.targetTypes.concat([]);
		}
		

		//hxml
		var hxmlPath =  console.getNextArg();

		if(hxmlPath == null)
		{
			hxml = config.hxml;
			
			if(hxml == null)
			{
				error("Default hxml file path is not set. Please run munit config.");
			}
			if(!hxml.exists)
			{
				error("Default hxml file path does not exist. Please run munit config.");
			}
		}
		else
		{
			hxml = File.create(hxmlPath, console.dir);

			if(!hxml.exists)
			{
				error("Cannot locate hxml file: " + hxmlPath);
			}
		}
		
		
		
		//prevent generation from occuring
		var noGen:String  = console.getOption("-nogen");
		
		if(noGen != "true")
		{
			beforeCommands.push(GenerateCommand);
		}
		
		//prevent generation from occuring
		var noRun:String  = console.getOption("-norun");
		
		if(noRun != "true")
		{
			afterCommands.push(RunCommand);
		}


	}

	override public function execute():Void
	{
		
		var contents:String = hxml.readString();
		
		var lines:Array<String> = contents.split("\n");
		
		targets = [];
	
	
		var target:Target = new Target();
		
		for(line in lines)
		{
			if(line.indexOf("--next") == 0)
			{
				targets.push(target);
				target = new Target();
				continue;
			}
						
			target.hxml += line + "\n";
			
			if(target.type == null)
			{
				for(type in targetTypes)
				{
					var s:String = Std.string(type);
				
					if(line.indexOf("-" + s) == 0 && target.type == null)
					{
						target.type = type;
						target.file = File.create(line.substr(s.length + 2), File.current);
					}
				}
			}
		}
		
		

		targets.push(target);
		
		
		
		
		for(target in targets)
		{
			if(target.type == null && targetTypes.length < config.targetTypes.length ) continue;
			
			Log.debug("Compile " + target.type + " -- " + target);
			if(HaxeWrapper.compile(target.hxml) > 0)
			{
				error("Error compiling hxml for " + target.type + "\n" + target);
			}	
		}
		
		Log.debug("All targets compiled successfully");
	}
	
	

}


