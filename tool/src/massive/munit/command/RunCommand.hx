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

import massive.munit.Config;
import haxe.Http;
import haxe.io.Eof;
import massive.neko.io.File;
import massive.neko.io.FileSys;
import massive.haxe.util.RegExpUtil;
import massive.munit.client.HTTPClient;
import neko.io.Process;
import neko.vm.Thread;
import neko.vm.Mutex;
import neko.Lib;
import neko.Sys;
import neko.io.Path;
import massive.haxe.log.Log;

class RunCommand extends MUnitCommand
{
	public static var SERVER_URL:String = "http://localhost:2000";
	
	private var files:Array<File>;
	
	private var browser:String;

	private var reportDir:File;
	private var reportRunnerDir:File;
	private var reportTestDir:File;
	
	private var tmpDir:File;
	private var tmpRunnerDir:File;
	
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
		
	
		
		var binPath:String = console.getNextArg();
		var file:File;
	
		if(binPath == null)
		{
			file = config.bin;
			
			if(file == null)
			{
				error("Default bin directory is not set. Please run munit config.");
			}
			if(!file.exists)
			{
				file.createDirectory();
				//error("Default bin directory does not exist (" + config.dir.getRelativePath(file) + "). Please run munit config.");
			}
			
		}
		else
		{
			file = File.create(binPath, console.dir);

			if(!file.exists)
			{
				file.createDirectory();
				//error("Path does not exist " + binPath);	
			}
		}
		
		Log.debug("binPath: " + file);
			
		if(file.isDirectory)
		{
			var reg:EReg = ~/_test\.(n|swf|js)$/;
			
			var tempFiles:Array<File> = file.getDirectoryListing(reg);
			
			files = []; 
	
			for(file in tempFiles)
			{
				//Log.debug("Matching file: " + file);
				for(type in targetTypes)
				{		
					if(type == TargetType.swf)
					{
						if(file.fileName.indexOf("8_test.swf") != -1)
						{
							files.push(file);
							break;
						}
					}
					else if(type == TargetType.swf9 && file.extension == "swf")
					{
						files.push(file);
						break;
					}
					else if(type == TargetType.js && file.extension == "js")
					{
						files.push(file);
						break;
					}
					else if(type == TargetType.neko && file.extension == "n")
					{
						files.push(file);
						break;
					}
				}
			}
			
			Log.debug(files.length + " targets");
			
			for(file in files)
			{
				Log.debug("   " + file);
			}	
		}
		else
		{
			files = [file];
		}

		var reportPath:String = console.getNextArg();
		
		if(reportPath == null)
		{
			reportDir = config.report;
			
			if(reportDir == null)
			{
				error("Default report directory is not set. Please run munit config.");
			}
			if(!reportDir.exists)
			{
				reportDir.createDirectory();
			//	error("Default report directory does not exist (" + config.dir.getRelativePath(reportDir) + "). Please run munit config.");
			}	
		}
		else
		{
			reportDir = File.create(reportPath, console.dir);
			
			if(!reportDir.exists)
			{
				reportDir.createDirectory();
				//error("Report directory path does not exist " + reportPath);	
			}
		}
		
		Log.debug("report: " + reportDir);
		
	
		reportRunnerDir = reportDir.resolveDirectory("test-runner");
		reportTestDir = reportDir.resolveDirectory("test");
		
		var b:String = console.getOption("browser");
		if (b != null && b != "true")
		{
			browser = b;
		}
		
		Log.debug("browser: " + browser);
	}

	override public function execute():Void
	{
		var testRunCount = 0;
		var testPassCount = 0;
		var testFailCount = 0;
		var testErrorCount = 0;
		var errors:Array<String> = new Array();
		
		FileSys.setCwd(console.originalDir.nativePath);
		
		resetOutputDirectories();
		var serverExitCode:Int = 0;
		
		for (file in files)
		{

			Log.debug("Running '" + file.fileName + "' ...");
			
			testRunCount ++;

			tmpDir = File.current.resolveDirectory("tmp");
			tmpRunnerDir = tmpDir.resolveDirectory("runner");

			var serverThread:Thread = Thread.create(runServer);
			serverThread.sendMessage(Thread.current());
			
			

			var launchExitCode:Int;
			if (file.extension == "n") launchExitCode = launchNeko(file);
			else launchExitCode = launchFile(file);

			if (launchExitCode > 0)
			{
				errors.push("Problem launching a target application " + file + " (" + launchExitCode + ")");
				continue;
			}
			serverExitCode = Thread.readMessage(true);

			tmpRunnerDir.deleteDirectory();

			// copy the tmp over to our results folder
			if (tmpDir.exists)
			{
				tmpDir.copyTo(reportTestDir);
				tmpDir.deleteDirectory(true);
			}
		
			var forceExit:Bool = false;
			
			switch(serverExitCode)
			{
				case 0: testPassCount ++;
				case -1: testFailCount ++;
				case -2: testErrorCount ++;
				default: forceExit = true;
			}
			
			
			if(forceExit == true)
			{
				errors.push("Problem running munit server for " + file + " (" + serverExitCode + ")");
				
				if(serverExitCode == 255)
				{
					//this is server exception - so skip other files
					break;
				}	
			}
		}


		FileSys.setCwd(console.dir.nativePath);

		print("------------------------------");
		print("PLATFORMS TESTED: " + testRunCount + ", PASSED: " + testPassCount + ", FAILED: " + testFailCount + ", ERRORS: " + (testErrorCount + errors.length));


		if(errors.length > 0)
		{
			for(e in errors)
			{
				print(e);
			}
			
			if(serverExitCode > 0)
			{
				exit(serverExitCode);
			}
			else
			{
				exit(1);
			}
		}

		exit(0);
		
	}

	private function resetOutputDirectories():Void
	{
		if (!reportRunnerDir.exists) reportRunnerDir.createDirectory();
		else reportRunnerDir.deleteDirectoryContents(RegExpUtil.SVN_REGEX, true);

		if (!reportTestDir.exists) reportTestDir.createDirectory();
		else reportTestDir.deleteDirectoryContents(RegExpUtil.SVN_REGEX, true);			
	}
		
	private function runServer():Void
	{
		var main:Thread = Thread.readMessage(true);

		var process:Process = new Process("nekotools", ["server"]);		
		var exitCode:Int = process.exitCode();

		var log:String = process.stderr.readAll().toString();		
		
		var code:Int = exitCode;
		
		if (log != null && log != "")
		{
			log = "\n"+log.split("[log] ").join("");
			var lines = log.split("\n");

			for(line in lines)
			{
				line = StringTools.trim(line);
				if(line.length == 0) continue;
				
				if(line.indexOf("FAILED") != -1 && code == 0)
				{
					code = -1;
				}
				else if(line.indexOf("ERROR") != -1)
				{
					code = -2;
				}
				
				Lib.println(line);
				
			}
		}
		main.sendMessage(code);	
	}
	
	private function launchFile(file:File):Int
	{
		var resourceDir:File = console.originalDir.resolveDirectory("resource");

		//copy test runner files
		resourceDir.copyTo(reportRunnerDir);

		//copy the application to test_runner/test.*
		file.copyTo(reportRunnerDir.resolvePath("test." + file.extension));

		var jsFile:File = reportRunnerDir.resolvePath("loader.js");

		if (file.extension == "swf")
		
		{
			reportRunnerDir.resolvePath("loader-swf.js").copyTo(jsFile);	
		}
		else
		{
			reportRunnerDir.resolvePath("loader-js.js").copyTo(jsFile);	
		}
		
		reportRunnerDir.copyTo(tmpRunnerDir);
	
		var targetLocation:String  = SERVER_URL + "/tmp/runner/index.html";
		
		
		var parameters:Array<String> = [];

		if (FileSys.isWindows) 
		{
			parameters.push("start");
			if (browser != null) parameters.push(browser);
		}
		else
		{
			parameters.push("open");
			if (browser != null) parameters.push("-a " + browser);
			//parameters.push("-g");
		}
		
		parameters.push(targetLocation);
		
		var exitCode:Int = neko.Sys.command(parameters.join(" "));
		if (exitCode > 0)
		{
			neko.Lib.println("Error running " + targetLocation);
		}

		return exitCode;
	}
	
	private function launchNeko(file:File):Int
	{
		var parameters:Array<String> = [];
		parameters.push("neko");
		parameters.push(file.nativePath);
		
		neko.Lib.println(parameters.join(" "));
		
		var exitCode:Int = neko.Sys.command(parameters.join(" "));
		if (exitCode > 0)
		{
			neko.Lib.println("Error running " + file);
		}
		return exitCode;
	}
}
