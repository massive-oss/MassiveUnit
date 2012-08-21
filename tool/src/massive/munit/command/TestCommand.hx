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

import neko.Sys;

import massive.haxe.log.Log;
import massive.neko.haxe.HaxeWrapper;
import massive.neko.io.File;
import massive.neko.io.FileSys;
import massive.neko.util.PathUtil;
import massive.munit.Config;
import massive.munit.Target;

import neko.Lib;

class TestCommand extends MUnitTargetCommandBase
{
	var testsAborted:Bool;
	

	public function new():Void
	{
		super();
	}

	override public function initialise():Void
	{
		super.initialise();

		initialiseTargets(true);

		if (invalidHxmlFormat())
		{
			testsAborted = true;
			return;
		}

		//prevent generation from occuring
		var noGen:String  = console.getOption("-nogen");
		
		if (noGen != "true")
		{
			addPreRequisite(GenerateCommand);
		}
		
		//prevent generation from occuring
		var noRun:String  = console.getOption("-norun");
		
		if (noRun != "true")
		{
			addPostRequisite(RunCommand);
		}

		//append code coverage

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
		var contents:String = config.hxml.readString();		
		var lines:Array<String> = contents.split("\n");
		var invalid = false;
		for (line in lines)
		{
			if (line.indexOf("main_test.") != -1)
			{
				Lib.println("Error: The naming convention main_test.<type> is deprecated. Please update your test.hxml file to generate the file(s) 'as2_test.swf', 'as3_test.swf', 'js_test.js', 'neko_test.n', 'cpp_test' respectively. [Cause: " + line + "]");
				invalid = true;
			}
		}
		return invalid;
	}

	//In v0.9.5.0 we added classpaths to .munit file to support mcover code coverage
	function missingClassPaths():Bool
	{
		if (includeCoverage && (config.classPaths == null || config.classPaths.length == 0))
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

		var targets = config.targets;

		for(target in targets)
		{
			if (target.type == null && targetTypes.length < config.targetTypes.length ) 
				continue;

			if (includeCoverage && target.main != null)
			{
				var clsPaths:Array<String> = [];

				for(path in config.classPaths)
				{
					if (target.flags.exists("MCOVER_DEBUG") && Sys.systemName() != "Windows")
					{
						clsPaths.push(path.toString());
					}
					else
					{
						clsPaths.push(config.dir.getRelativePath(path));
					}
				}
				validateTestMainCoverageConfiguration(target);
				
				//ingore lib if testing MCOVER (causes compiler errors from dup src path)
				if (!target.flags.exists("MCOVER_DEBUG"))
				{
					target.hxml += "-lib mcover\n";	
				}
				
				target.hxml += "-D MCOVER\n";

				var coverPackages = config.coveragePackages != null ? config.coveragePackages.join("','") : "";
				var coverIgnoredClasses = config.coverageIgnoredClasses != null ? config.coverageIgnoredClasses.join("','") : "";
				target.hxml += "--macro mcover.MCover.coverage(['" + coverPackages + "'],['" + clsPaths.join("','") + "'],['" + coverIgnoredClasses + "'])\n";	
			}
			
			if (target.type == TargetType.as2 || target.type == TargetType.as3)
			{
				target.hxml = updateSwfHeader(target.hxml);
			}
			
			if (console.getOption("debug") == "true")
			{
				target.hxml += "-D testDebug\n";
				target.hxml += "-D debug\n";				
			}

			

			if(target.type == TargetType.cpp)
			{
				target.executableFile.deleteFile();
			}

			Log.debug("Compile " + target.type + " -- " + target);

			if (HaxeWrapper.compile(target.hxml) > 0)
			{
				error("Error compiling hxml for " + target.type + "\n" + target);
			}	

			var tmp = config.bin.resolveFile(".temp/" + target.type + ".txt");
			if (target.type == cpp)
			{
				tmp.writeString(target.executableFile, false);
			}
			else
			{
				tmp.writeString(target.file, false);
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
			if (headerMatcher.match(line))
			{
				line = "-swf-header 800:600:60:FFFFFF";
			}

			result += "\n" + line;
		}
		return result;
	}

	/**
	Checks the contents of the test main to ensure it is correctly configured for mcover.
	Prints a warning (or error) if not correctly set up.
	*/
	function validateTestMainCoverageConfiguration(target:Target)
	{
		var reg:EReg = ~/#if (!?)(MCOVER)/;
		var str = target.main.readString();

		if (str == null || !reg.match(str))
		{
			Lib.println("");
			Lib.println("WARNING:");
			Lib.println("");
			Lib.println("   Compiling " + target.type + " for MCover may not execute coverage");
			Lib.println("   " + target.main.name + ".hx does not contain 'MCOVER' conditional flag expected for code coverage.");
			Lib.println("   Either update manually, or delete '" + target.main.name + ".hx' and re-run 'munit gen'");
			Lib.println("   or 'munit test' to regenerate class from template.");
			Lib.println("");
			Lib.println("   Location: " + target.main);
			Lib.println("");
		}

		var outdatedRef:EReg = ~/(m\.cover|massive\.cover)(.*)/;

		if (outdatedRef.match(str))
		{
			Lib.println("");
			Lib.println("ERROR:");
			Lib.println("");
			Lib.println("   Some references in this project's '" + target.main.name + ".hx' are out of date.");
			Lib.println("   Please replace all references to '" + outdatedRef.matched(1) + ".*' with 'mcover.*', or");
			Lib.println("   delete '" + target.main.name + ".hx' and re-run 'munit test' to regenerate class");
			Lib.println("   from template.");
			Lib.println("");
			Lib.println("   Location: " + target.main);
			Lib.println("");
			Sys.exit(1);
		}
	}

}
