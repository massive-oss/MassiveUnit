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
package massive.munit.command;

import massive.haxe.log.Log;
import massive.neko.haxe.HaxeWrapper;
import massive.neko.io.File;
import massive.neko.io.FileSys;
import massive.neko.util.PathUtil;
import massive.munit.Config;
import massive.munit.Target;
import neko.Lib;

class TestCommand extends MUnitCommand
{

	var hxml:File;
	var targets:Array<Target>;
	var targetTypes:Array<TargetType>;
	var testsAborted:Bool;
	var includeCoverage:Bool; 

	public function new():Void
	{
		super();
	}

	override public function initialise():Void
	{
		targetTypes = new Array();
		
		if(console.getOption("swf") == "true")
		{
			targetTypes.push(TargetType.as2);
			targetTypes.push(TargetType.as3);
		}

		if(console.getOption("as2") == "true")
			targetTypes.push(TargetType.as2);
		if(console.getOption("as3") == "true") 
			targetTypes.push(TargetType.as3);
		if(console.getOption("js") == "true") 
			targetTypes.push(TargetType.js);
		if(console.getOption("neko") == "true") 
			targetTypes.push(TargetType.neko);
		
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

		if (invalidHxmlFormat())
		{
			testsAborted = true;
			return;
		}
		
		//prevent generation from occuring
		var noGen:String  = console.getOption("-nogen");
		
		if(noGen != "true")
		{
			addPreRequisite(GenerateCommand);
		}
		
		//prevent generation from occuring
		var noRun:String  = console.getOption("-norun");
		
		if(noRun != "true")
		{
			addPostRequisite(RunCommand);
		}

		//append code coverage
		var coverage:String  = console.getOption("-coverage");
		
		includeCoverage = coverage == "true";

		if (missingClassPaths())
		{
			testsAborted = true;
			return;
		}
	}

	// In v0.9.0.3 we made a significant change to the required format of test.hxml. 
	// This ensures everything is in place
	function invalidHxmlFormat():Bool
	{
		var contents:String = hxml.readString();		
		var lines:Array<String> = contents.split("\n");
		var invalid = false;
		for (line in lines)
		{
			if (line.indexOf("main_test.") != -1)
			{
				Lib.println("Error: The naming convention main_test.<type> is deprecated. Please update your test.hxml file to generate the file(s) 'as2_test.swf', 'as3_test.swf', 'js_test.js', 'neko_test.n' respectively. [Cause: " + line + "]");
				invalid = true;
			}
		}
		return invalid;
	}

	//In v0.9.5.0 we added classpaths to .munit file to support mcover code coverage
	function missingClassPaths():Bool
	{
		if(includeCoverage && (config.classPaths == null || config.classPaths.length == 0))
		{
			error("This command requires an update to your munit project settings. Please re-run 'munit config' to set target class paths (i.e. 'src')");
			return true;
		}
		return false;
	}

	override public function execute():Void
	{
		if (testsAborted)
			return;
		
		var contents:String = hxml.readString();		
		var lines:Array<String> = contents.split("\n");
		var target:Target = new Target();
		
		var tempTargets:Array<Target> = [];
		
		for(line in lines)
		{
			if(line.indexOf("--next") == 0)
			{
				tempTargets.push(target);
				target = new Target();
				continue;
			}
			
			var mainReg:EReg = ~/^-main (.*)/;	
			if(mainReg.match(line))
			{
				target.main = config.src.resolveFile(mainReg.matched(1) + ".hx");
			}

			var flagReg:EReg = ~/^-D (.*)/;
			if(flagReg.match(line))
			{
				var flag = flagReg.matched(1).split(" ");
				target.flags.set(flag.shift(), flag.join(" "));
			}

			target.hxml += line + "\n";
			
			if(target.file == null)
			{
				for(type in targetTypes)
				{
					var s:String = null;
					switch(type)
					{
						case TargetType.as2: s = "swf";
						case TargetType.as3: s = "swf";
						default: s = Std.string(type);
					}
					var targetMatcher = new EReg("^-" + s + "\\s+", "");
					if(targetMatcher.match(line))
					{
						target.file = File.create(line.substr(s.length + 2), File.current);
						break;
					}
				}
			}

			if(target.type == null)
			{
				for(type in targetTypes)
				{
					var s:String = null;
					switch(type)
					{
						case TargetType.as2: s = "swf-version 8";
						case TargetType.as3: s = "swf-version [^8]";
						default: s = Std.string(type);
					}	
					var targetMatcher = new EReg("^-" + s, "");
					if(targetMatcher.match(line))
					{
						target.type = type;
						break;
					}
				}
			}
		}

		tempTargets.push(target);

		targets = [];


		var tempTargetTypes = [];

		for(target in tempTargets)
		{
			for(type in targetTypes)
			{
				if(target.type == type)
				{
					targets.push(target);
					tempTargetTypes.push(type);
					break;
				}
			}
		}


		targetTypes = config.targetTypes = tempTargetTypes;

		
		for(target in targets)
		{
			if(target.type == null && targetTypes.length < config.targetTypes.length ) 
				continue;

			

			if(includeCoverage && target.main != null)
			{

				var clsPaths:Array<String> = [];
				for(path in config.classPaths)
				{
					if(target.flags.exists("MCOVER_DEBUG"))
					{
						clsPaths.push(path.toString());
					}
					else
					{
						clsPaths.push(config.dir.getRelativePath(path));
					}
				}

				warnIfMissingMCoverConditionalFlagInTestMain(target);
				
				//ingore lib if testing MCOVER (causes compiler errors from dup src path)
				if(!target.flags.exists("MCOVER_DEBUG"))
				{
					target.hxml += "-lib mcover\n";	
				}
				
				target.hxml += "-D MCOVER\n";
				target.hxml += "--macro m.cover.MCover.coverage([''],['" + clsPaths.join("','") + "'])\n";	
			}
			
			if(target.type == TargetType.as2 || target.type == TargetType.as3)
			{
				target.hxml = updateSwfHeader(target.hxml);
			}
			
			if(console.getOption("debug") == "true")
			{
				target.hxml += "-D testDebug\n";
				target.hxml += "-D debug\n";				
			}

			Log.debug("Compile " + target.type + " -- " + target);

			if(HaxeWrapper.compile(target.hxml) > 0)
			{
				error("Error compiling hxml for " + target.type + "\n" + target);
			}	
		}
		
		Log.debug("All targets compiled successfully");
	}

	function updateSwfHeader(hxml:String):String
	{
		var result:String = "";
		var lines:Array<String> = hxml.split("\n");
		for(line in lines)
		{
			var headerMatcher = new EReg("^-swf-header", "");
			//200:300:40:FF0000
			if(headerMatcher.match(line))
			{
				line = "-swf-header 800:600:60:FFFFFF";
			}

			result += "\n" + line;
		}
		return result;
	}

	function warnIfMissingMCoverConditionalFlagInTestMain(target:Target)
	{
		var reg:EReg = ~/#if (!?)MCOVER/;
		var str = target.main.readString();

		if(str == null || !reg.match(str))
		{
			Lib.println("Warning: Compiling " + target.type + " for MCover may not execute coverage");

			Lib.println("   " + target.main.name + ".hx does not contain MCOVER conditional flag expected for code coverage.\n   Either delete " + target.main.name + " and re-run 'munit gen' or 'munit test' to regenerate class, or refer to online docs");
		}
	}
}
