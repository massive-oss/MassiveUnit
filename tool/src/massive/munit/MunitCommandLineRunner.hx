package massive.munit;
import massive.haxe.log.Log;
import massive.neko.cmd.CommandLineRunner;
import massive.neko.cmd.ICommand;
import haxe.Resource;

import massive.munit.command.GenerateCommand;
import massive.munit.command.RunCommand;
import massive.munit.command.TestCommand;
import massive.munit.command.ConfigCommand;
import massive.munit.command.MUnitCommand;

class MunitCommandLineRunner extends CommandLineRunner
{
	static function main() {new MunitCommandLineRunner();}
	
	public var config:Config;
	private var version:String;

	function new():Void
	{
		super();
		
		mapCommand(GenerateCommand, "gen", ["g"], "Generate a test runner based on classes in a test src directory", Resource.getString("help_gen"));
		mapCommand(RunCommand, "run", ["r"], "Runs a single unit test target and generates results", Resource.getString("help_run"));
		mapCommand(TestCommand, "test", ["t"], "Updates, compiles and runs all targets from an hxml file", Resource.getString("help_test"));
		mapCommand(ConfigCommand, "config", ["c"], "Modify default project specific settings for munit", Resource.getString("help_config"));
		
		version = getVersion();
		config = new Config(console.dir, version);
		run();
	}
	
	override private function createCommandInstance(commandClass:Class<ICommand>):ICommand
	{
		
		
		var command:ICommand = super.createCommandInstance(commandClass);
		
		var className:String = Type.getClassName(commandClass);	
		Log.debug("Command: " + className);
	
		var cmd:MUnitCommand = cast(command, MUnitCommand);
		cmd.config = config;
			
		return cmd;
	}
	
	
	override public function printHeader():Void
	{	
		print("Massive Unit - Copyright " + Date.now().getFullYear() + " Massive Interactive. Version " + version);
	
	}
	
	override public function printUsage():Void
	{
		print("Usage: munit [subcommand] [options]");
	}
	
	override public function printHelp():Void
	{
		if(!config.exists)
		{
			print(Resource.getString("help"));
		}
		
	}
	
	
	private function getVersion():String
	{
		if (version == null)
		{

			var versionPath:String = console.originalDir.name;
			var a:Array<String> = versionPath.split(",");
			version = a.join(".");
		}

		return version;
	}
	

	



}