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


import haxe.Http;
import haxe.io.Eof;
import massive.haxe.util.RegExpUtil;
import massive.munit.client.HTTPClient;
import neko.io.Process;
import neko.FileSystem;
import neko.vm.Thread;
import neko.vm.Mutex;
import neko.Lib;
import neko.Sys;
import neko.io.Path;
import massive.neko.io.File;
import massive.neko.io.FileSys;
import neko.io.File;

 
 
/**
Don't ask - compiler always thinks it is massive.munit.TargetType enum 'neko'
*/
typedef NekoFile = neko.io.File;
typedef NekoSys = neko.Sys;

import massive.haxe.log.Log;
import massive.munit.ServerMain;
import massive.munit.util.MathUtil;
import massive.munit.Config;
import massive.munit.Target;


class RunCommand extends MUnitTargetCommandBase
{
	public static inline var DEFAULT_SERVER_TIMEOUT_SEC:Int = 30;

	var browser:String;

	var reportDir:File;
	var reportRunnerDir:File;
	var reportTestDir:File;

	var tmpDir:File;
	var tmpRunnerDir:File;
	var binDir:File;

	var killBrowser:Bool;
	var indexPage:File;

	var hasBrowserTests:Bool;
	
	var hasNekoTests:Bool;
	var hasCPPTests:Bool;

	var nekoFile:File;
	var cppFile:File;
	
	
	var serverTimeoutTimeSec:Int;

	var resultExitCode:Bool;

	public function new():Void
	{
		super();
		killBrowser = false;

		// TODO: Configure this through args to munit for CI. ms 4/8/11
		serverTimeoutTimeSec = DEFAULT_SERVER_TIMEOUT_SEC;
	}

	override public function initialise():Void
	{
		initialiseTargets(false);

		locateBinDir();
		gatherTestRunnerFiles();
		locateReportDir();
		checkForCustomBrowser();
		checkForBrowserKeepAliveFlag();
		resetOutputDirectories();
		generateTestRunnerPages();
		checkForExitOnFail();
	}

	function locateBinDir()
	{
		var binPath:String = console.getNextArg();

		if (binPath == null)
		{
			binDir = config.bin;

			if (binDir == null)
				error("Default bin directory is not set. Please run munit config.");

			if (!binDir.exists)
				binDir.createDirectory();
		}
		else
		{
			binDir = File.create(binPath, console.dir);

			if (!binDir.exists)
				binDir.createDirectory();
		}

		Log.debug("binPath: " + binDir);
	}


	function gatherTestRunnerFiles()
	{
		var tempTargets = [];

		if (!binDir.isDirectory)
			return;

		if (!binDir.resolveDirectory(".temp").exists)
			return;

		for(target in targets)
		{
			var type = target.type;

			var tmp = binDir.resolveFile(".temp/" + type + ".txt");

			if (!tmp.exists)
			{
				print("WARNING: Target type '" + type + "' not found in bin directory.");
				continue;
			}

			//update as this will be the actual executable for cpp/php targets
			target.file = File.current.resolveFile(tmp.readString());
			
			if (!target.file.exists)
			{
				print("WARNING: File for target type '" + target.type + "' not found: " + target.toString());
			}
			else
			{
				tempTargets.push(target);
				if (type == TargetType.neko)
				{
					hasNekoTests = true;
				}	
				if (type == TargetType.cpp)
				{
					hasCPPTests = true;
				}	
			}
			
		}

		targets = config.targets = tempTargets;

		Log.debug(targets.length + " targets");

		for (target in targets)
			Log.debug("   " + target.file);
	}

	function locateReportDir()
	{
		var reportPath:String = console.getNextArg();

		if (reportPath == null)
		{
			reportDir = config.report;

			if (reportDir == null)
				error("Default report directory is not set. Please run munit config.");
			if (!reportDir.exists)
				reportDir.createDirectory();
		}
		else
		{
			reportDir = File.create(reportPath, console.dir);

			if (!reportDir.exists)
				reportDir.createDirectory();
		}

		Log.debug("report: " + reportDir);
	}

	function checkForCustomBrowser()
	{
		reportRunnerDir = reportDir.resolveDirectory("test-runner");
		reportTestDir = reportDir.resolveDirectory("test");

		var b:String = console.getOption("browser");
		if (b != null && b != "true")
			browser = b;

		Log.debug("browser: " + browser);
	}

	function checkForBrowserKeepAliveFlag()
	{
		if (console.getOption("kill-browser") != null)
		{
			killBrowser = true;
			Log.debug("killBrowser? " + killBrowser);
		}
	}

	function checkForExitOnFail()
	{
		if (console.getOption("result-exit-code") != null)
		{
			resultExitCode = true;
			Log.debug("resultExitCode? " + resultExitCode);
		}
	}

	function resetOutputDirectories():Void
	{
		if (!reportRunnerDir.exists)
			reportRunnerDir.createDirectory();
		else
			reportRunnerDir.deleteDirectoryContents(RegExpUtil.SVN_REGEX, true);

		if (!reportTestDir.exists)
			reportTestDir.createDirectory();
		else
			reportTestDir.deleteDirectoryContents(RegExpUtil.SVN_REGEX, true);
	}

	function generateTestRunnerPages()
	{
		var pageNames = [];
		for (target in targets)
		{
			var file = target.file;

			switch(target.type)
			{
				case neko:
					hasNekoTests = true;
					nekoFile = file;
				case cpp:
					hasCPPTests = true;
					cppFile = file;
				default:

					hasBrowserTests = true;

					var pageName = Std.string(target.type);
					var templateName = file.extension + "_runner-html";
					var pageContent = getTemplateContent(templateName, {runnerName:file.fileName});
					
					var runnerPage = reportRunnerDir.resolvePath(pageName + ".html");

					runnerPage.writeString(pageContent);
					pageNames.push(pageName);
			}
		}

		var frameCols = "";
		var frames = "";
		var frameTitles = "";
		var colCount = Math.round(100 / pageNames.length);
		for (pageName in pageNames)
		{
			frameCols += "*,";
			frameTitles += '<td width="' + colCount + '%" title="Double click to maximise"><div>' + pageName.toUpperCase() + '<a href="#" title="Click to maximise">expand toggle</a></div></td>';
			frames += '<frame src="' + pageName + ".html" + '" scrolling="auto" noresize="noresize"/>\n';
		}

		frameCols = frameCols.substr(0, -1);

		var headerContent = getTemplateContent("target-headers-html", {targetHeaderTitles:frameTitles});
		var headerPage = reportRunnerDir.resolvePath("target_headers.html");
		headerPage.writeString(headerContent, true);

		var pageContent = getTemplateContent("runner-html", {killBrowser:killBrowser, testCount:pageNames.length, frames:frames, frameCols:frameCols});

		indexPage = reportRunnerDir.resolvePath("index.html");
		indexPage.writeString(pageContent, true);

		var commonResourceDir:File = console.originalDir.resolveDirectory("resource");
		commonResourceDir.copyTo(reportRunnerDir);

		if (config.resources != null)
		{
			config.resources.copyTo(reportRunnerDir);
		}

		for (target in targets)
		{
			var file = target.file;
			file.copyTo(reportRunnerDir.resolveFile(file.fileName));
		}
	}

	/**
	Returns content from a html template.
	Checks for local template before using default template
	*/
	function getTemplateContent(templateName:String, properties:Dynamic)
	{
		var content:String = null;
		var resource:String;
		if (config.templates != null && config.templates.resolveFile(templateName + ".mtt").exists)
		{
			resource = config.templates.resolveFile(templateName + ".mtt").readString();
		}
		else
		{
			resource = haxe.Resource.getString(templateName);
		}

		var template = new haxe.Template(resource);
		return template.execute(properties);
	}

	override public function execute():Void
	{
		if (FileSys.isWindows)
		{
			//Windows has issue releasing port registries reliably.
			//To prevent possibility of nekotools server failing, on
			//windows the tmp directory is always located inside the munit install
			FileSys.setCwd(console.originalDir.nativePath);
		}
		else
		{
			//for mac and linux we create a tmp directory locally within the bin
			FileSys.setCwd(binDir.nativePath);
		}

		var serverFile:File = createServerAlias();

		var errors:Array<String> = new Array();

		
		var serverExitCode:Int = 0;

		tmpDir = File.current.resolveDirectory("tmp");

		if (tmpDir.exists)
			tmpDir.deleteDirectoryContents(RegExpUtil.SVN_REGEX, true);

		tmpRunnerDir = tmpDir.resolveDirectory("runner");
		reportRunnerDir.copyTo(tmpRunnerDir);


		var serverProcess:Process = null;

		try
		{
			serverProcess = new Process("nekotools", ["server"]);
		}
		catch(e:Dynamic)
		{
			error("Unable to launch nekotools server. Please kill existing process and try again.", 1);
		}
		
		
		var resultMonitor = Thread.create(monitorResults);
		resultMonitor.sendMessage(Thread.current());
		resultMonitor.sendMessage(serverProcess);
		resultMonitor.sendMessage(serverTimeoutTimeSec);

		if (hasNekoTests)
			launchNeko(nekoFile);

		if (hasCPPTests)
			launchCPP(cppFile);

		if (hasBrowserTests)
			launchFile(indexPage);
		else
			resultMonitor.sendMessage("quit");

		var platformResults:Bool = Thread.readMessage(true);

		serverProcess.kill();

		if (reportTestDir.exists)
			reportTestDir.deleteDirectoryContents();
		
		if (!FileSys.isWindows)
		{
			serverFile.deleteFile();
		}

		tmpRunnerDir.deleteDirectory();
		tmpDir.copyTo(reportTestDir);
		tmpDir.deleteDirectory(true);
		FileSys.setCwd(console.dir.nativePath);

		if (platformResults == false && resultExitCode)
		{
			//print("TESTS FAILED");

			#if haxe_209
			Sys.stderr().writeString("TESTS FAILED\n");
			Sys.stderr().flush();
			#else

			NekoFile.stderr().writeString("TESTS FAILED\n");
			NekoFile.stderr().flush();
			#end
			
			exit(1);
		}
	}

	/**
	Generates an alias to the nekotools server file on osx/linux
	*/
	function createServerAlias():File
	{
		var serverFile = console.originalDir.resolveFile("index.n");

		if (FileSys.isWindows) return serverFile;
		
		var copy = File.current.resolveFile("index.n");

		serverFile.copyTo(copy);
		return copy;
	}


	private function monitorResults():Void
	{
		var mainThread = Thread.readMessage(true);
		var serverProcess = Thread.readMessage(true);
		var serverTimeoutTimeSec = Thread.readMessage(true);
		var testRunCount = 0;
		var testPassCount = 0;
		var testFailCount = 0;
		var testErrorCount = 0;

		var startTime = Sys.time();
		var lastResultTime = startTime;
		var serverHung = false;

		if (serverTimeoutTimeSec == null || serverTimeoutTimeSec < 10)
			serverTimeoutTimeSec = DEFAULT_SERVER_TIMEOUT_SEC;

		// Note: Tried using FileSystem.stat mod date to see changes in results.txt but
		//       writes are too quick so using line count instead.
		var fileName = tmpDir.nativePath + "results.txt";
		var file = null;
		var lineCount = 0;
		var platformMap = new Hash<Bool>();
		do
		{
			if ((Sys.time() - lastResultTime) > serverTimeoutTimeSec)
			{
				serverHung = true;
				break;
			}
			if (Thread.readMessage(false) == "quit")
				break;

			if (!FileSystem.exists(fileName))
				continue;

			if (file == null)
				file = tmpDir.resolvePath("results.txt");

			var contents = "";
			try {
				contents = file.readString();
			}
			catch (e:Dynamic) {
				Sys.sleep(0.1);
				continue;
			}

			var lines = contents.split("\n");
			lines.pop();

			if (lines.length > lineCount)
			{
				var i = lineCount;
				lineCount = lines.length;

				if ( i < lineCount)
					lastResultTime = Sys.time();

				while (i < lineCount)
				{
					var line = lines[i++];

					if (line != ServerMain.END)
					{
						if (checkIfTestPassed(line))
							testPassCount++;
						else if (checkIfTestFailed(line))
							testFailCount++;
						else
							testErrorCount++;

						var parts = line.split("under ");
						if (parts.length > 1)
						{
							var platform = parts[1].split(" ")[0];
							platformMap.set(platform, true);

							print(line);
						}
					}
				}

				if (lines[lineCount - 1] == ServerMain.END)
				{
					lineCount--;
					break;
				}
			}
		}
		while (true);

		var platformCount = Lambda.count(platformMap);


		if (platformCount > 0)
		{
			print("------------------------------");
			print("PLATFORMS TESTED: " + platformCount + ", PASSED: " + testPassCount + ", FAILED: " + testFailCount + ", ERRORS: " + testErrorCount + ", TIME: " + MathUtil.round(Sys.time() - startTime, 5));
		}

		if (serverHung)
		{
			print("------------------------------");
			print("ERROR: Local results server appeared to hang so test reporting was cancelled.");
		}
		
		var platformResult:Bool = platformCount > 0 && testFailCount == 0 && testErrorCount == 0 && !serverHung;

		mainThread.sendMessage(platformResult);
	}

	private function getTargetName(result:String):String
	{
		return result.split("under ")[1].split(" using")[0];
	}

	private function checkIfTestPassed(result:String):Bool
	{
		return result.indexOf(ServerMain.PASSED) != -1;
	}

	private function checkIfTestFailed(result:String):Bool
	{
		return result.indexOf(ServerMain.FAILED) != -1;
	}

	private function launchFile(file:File):Int
	{
		var targetLocation:String  = HTTPClient.DEFAULT_SERVER_URL + "/tmp/runner/" + file.fileName;
		var parameters:Array<String> = [];

		// See http://www.dwheeler.com/essays/open-files-urls.html
		if (FileSys.isWindows)
		{
			parameters.push("start");
			if (browser != null)
				parameters.push(browser);
		}
		else if (FileSys.isMac)
		{
			parameters.push("open");
			if (browser != null)
				parameters.push("-a " + browser);
		}
		else if (FileSys.isLinux)
		{
			if (browser != null)
				parameters.push(browser);
			else 
				parameters.push("xdg-open");
		}

		parameters.push(targetLocation);

		var exitCode:Int = Sys.command(parameters.join(" "));
		
		if (exitCode > 0)
			error("Error running " + targetLocation, exitCode);
  
		return exitCode;
	}

	private function launchNeko(file:File):Int
	{
		var reportRunnerFile:File = reportRunnerDir.resolvePath(file.fileName);
		file.copyTo(reportRunnerFile);

		FileSys.setCwd(config.dir.nativePath);
  
		var exitCode = runCommand("neko " + reportRunnerFile.nativePath);

		FileSys.setCwd(console.originalDir.nativePath);
		
		if (exitCode > 0)
			error("Error (" + exitCode + ") running " + file, exitCode);
		
		return exitCode;
	}

	private function launchCPP(file:File):Int
	{
		var tmpFile = reportRunnerDir.resolveFile(file.fileName);

		file.copyTo(tmpFile);

		FileSys.setCwd(config.dir.nativePath);
  
		var exitCode = runCommand(file.nativePath);

		FileSys.setCwd(console.originalDir.nativePath);
		
		if (exitCode > 0)
			error("Error (" + exitCode + ") running " + file, exitCode);
		
		return exitCode;
	}

	function runCommand(command:String):Int
	{
		Lib.println(command);

		var args = command.split(" ");
		var name = args.shift();

		var process = new Process(name, args);

		try
		{
			while (true)
			{
				Sys.sleep(0.01);
				var output = process.stdout.readLine();
				Lib.println(output);
			}
		}
		catch (e:haxe.io.Eof) {}

		var exitCode:Int = 0;
		var error:String = null;

		try
		{
			exitCode = process.exitCode();
		}
		catch(e:Dynamic)
		{
			exitCode = 1;
			error = Std.string(e).split("\n").join("\n\t");
		}

		var stfErrString = process.stderr.readAll().toString().split("\n").join("\n\t");

		if(stfErrString == null) stfErrString = "";

		if (exitCode > 0 || stfErrString.length > 0)
		{
			if(error != null) error += "\n\t";
			Lib.println("Error running '" + command + "'\n\t" + error);
		}

		return exitCode;
	}
}
