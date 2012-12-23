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
import massive.haxe.log.Log;
import massive.neko.cmd.CommandLineRunner;
import massive.neko.cmd.ICommand;
import haxe.Resource;

import massive.munit.command.GenerateCommand;
import massive.munit.command.RunCommand;
import massive.munit.command.TestCommand;
import massive.munit.command.ConfigCommand;
import massive.munit.command.CreateTestCommand;
import massive.munit.command.MUnitCommand;
import massive.munit.command.ReportCommand;

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
		mapCommand(CreateTestCommand, "create", ["ct"], "Create test class", Resource.getString("help_create"));
		mapCommand(ConfigCommand, "config", ["c"], "Modify default project specific settings for munit", Resource.getString("help_config"));

		mapCommand(ReportCommand, "report", ["re"], "Generate reports for CI environments and 3rd party tools", Resource.getString("help_report"));
		
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
