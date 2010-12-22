package massive.munit.command;

import massive.neko.io.File;
import massive.neko.io.FileSys;

class ConfigCommand extends MUnitCommand
{
	
	private var src:File;
	private var bin:File;
	
	private var report:File;
	private var hxml:File;
	public function new():Void
	{
		super();
		
		afterCommands.push(GenerateCommand);
	}
	

	override public function initialise():Void
	{
		var del:String = console.getOption("delete");
		
		if(del != null)
		{
			config.remove();
			exit(0);
		}
		
	
		var reset:String = console.getOption("reset");
		
		if(reset != null)
		{
			config.remove();
		}
		else if(config.exists)
		{
			print("Current munit settings\n--------------------");
			print(config.toString());
			print("--------------------");
			print("Please use '-reset' to overwrite existing values");
			exit(0);
		}
		
		
		
		var arg = console.getNextArg("test src dir (defaults to 'test')");
		
		
		if(arg == null) arg = "test";
		
		src = File.create(arg, config.dir);
		
		if(src == null) throw "invaid src path" + arg;
		if(!src.exists) src.createDirectory();
		if(!src.isDirectory) throw "src path is not a valid directory " + arg;
		
		arg = console.getNextArg("bin dir (defaults to 'bin')");
		
		if(arg == null) arg = "bin";
		
		bin = File.create(arg, config.dir);
		
		if(bin == null) throw "invaid bin path " + arg;
		if(!bin.exists) bin.createDirectory();
		if(!bin.isDirectory) throw "bin path is not a valid directory " + arg;
		
		
		arg = console.getNextArg("report dir (defaults to 'report')");
		
		if(arg == null) arg = "report";
		
		report = File.create(arg, config.dir);
		
		if(report == null) throw "invaid report path " + arg;
		if(!report.exists) report.createDirectory();
		if(!report.isDirectory) throw "report path is not a valid directory " + arg;
		
		
		arg = console.getNextArg("hxml file (defaults to test.hxml)");
		
		if(arg == null) arg = "test.hxml";
		
		hxml = File.create(arg, config.dir);
		
		if(hxml == null) throw "invaid hxml path" + arg;
		if(hxml.isDirectory) throw "hxml path is a directory " + arg;
	}

	override public function execute():Void
	{
		if(!config.exists)
		{
			config.createDefault(src, bin, report, hxml);
		}

	}

	
}
