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

import haxe.io.Eof;
import haxe.io.Path;
import massive.haxe.log.Log;
import massive.haxe.util.RegExpUtil;
import massive.munit.ServerMain;
import massive.munit.client.HTTPClient;
import massive.munit.util.MathUtil;
import massive.sys.io.File;
import massive.sys.io.FileSys;
import neko.vm.Thread;
import sys.FileSystem;
import sys.io.Process;
import sys.net.Host;
import sys.net.Socket;


import haxe.ds.StringMap;
 
/**
Don't ask - compiler always thinks it is massive.munit.TargetType enum 'neko'
*/
typedef SysFile = sys.io.File;

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
	var hasCPPTests:Bool;
	var hasJavaTests:Bool;
	var hasCSTests:Bool;
	var nekoFile:File;
	var cppFile:File;
	var javaFile:File;
	var csFile:File;
	var pythonFile:File;
	var serverTimeoutTimeSec:Int;
	var resultExitCode:Bool;
	
	public function new()
	{
		super();
		killBrowser = false;
	}

	override public function initialise()
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
			if (binDir == null) error("Default bin directory is not set. Please run munit config.");
			if (!binDir.exists) binDir.createDirectory();
		}
		else
		{
			binDir = File.create(binPath, console.dir);
			if (!binDir.exists) binDir.createDirectory();
		}
		Log.debug("binPath: " + binDir);
	}

	function gatherTestRunnerFiles()
	{
		if (!binDir.isDirectory || !binDir.resolveDirectory(".temp").exists) return;
		
		var tempTargets = [];
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
			}
		}
		targets = config.targets = tempTargets;
		Log.debug(targets.length + " targets");
		for (target in targets) Log.debug("   " + target.file);
	}

	function locateReportDir()
	{
		var reportPath:String = console.getNextArg();
		if (reportPath == null)
		{
			reportDir = config.report;
			if (reportDir == null) error("Default report directory is not set. Please run munit config.");
			if (!reportDir.exists) reportDir.createDirectory();
		}
		else
		{
			reportDir = File.create(reportPath, console.dir);
			if (!reportDir.exists) reportDir.createDirectory();
		}
		Log.debug("report: " + reportDir);
	}

	function checkForCustomBrowser()
	{
		reportRunnerDir = reportDir.resolveDirectory("test-runner");
		reportTestDir = reportDir.resolveDirectory("test");
		var b:String = console.getOption("browser");
		if (b != null && b != "true") browser = b;
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

	function resetOutputDirectories()
	{
		if (!reportRunnerDir.exists) reportRunnerDir.createDirectory();
		else reportRunnerDir.deleteDirectoryContents(RegExpUtil.SVN_REGEX, true);
		if (!reportTestDir.exists) reportTestDir.createDirectory();
		else reportTestDir.deleteDirectoryContents(RegExpUtil.SVN_REGEX, true);
	}

	function generateTestRunnerPages()
	{
		var pageNames = [];
		for (target in targets)
		{
			var file = target.file;

			switch(target.type)
			{
				case neko: nekoFile = file;
				case cpp: cppFile = file;
				case java: javaFile = file;
				case cs: csFile = file;
				case python: pythonFile = file;
				case _:
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
		if (config.resources != null) config.resources.copyTo(reportRunnerDir);
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

	override public function execute()
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
		tmpDir = File.current.resolveDirectory("tmp");
		if (tmpDir.exists) tmpDir.deleteDirectoryContents(RegExpUtil.SVN_REGEX, true);
		tmpRunnerDir = tmpDir.resolveDirectory("runner");
		reportRunnerDir.copyTo(tmpRunnerDir);
		var userTimeout = console.getOption("timeout");
		if (userTimeout != null) serverTimeoutTimeSec = Std.parseInt(userTimeout);
		if (serverTimeoutTimeSec == null) serverTimeoutTimeSec = DEFAULT_SERVER_TIMEOUT_SEC;
		else print('Running tests with $serverTimeoutTimeSec seconds timeout');
		var serverProcess:Process = null;
		try
		{
			serverProcess = new Process("nekotools", ["server"]);
		}
		catch(e:Dynamic)
		{
			error("Unable to launch nekotools server. Please kill existing process and try again.", 1);
		}
		
		var serverMonitor = Thread.create(readServerOutput);
		serverMonitor.sendMessage(serverProcess);
		
		var resultMonitor = Thread.create(monitorResults);
		resultMonitor.sendMessage(Thread.current());
		resultMonitor.sendMessage(serverProcess);
		resultMonitor.sendMessage(serverTimeoutTimeSec);
		
		if(nekoFile != null) launchNeko(nekoFile);
		if(cppFile != null) launchCPP(cppFile);
		if(javaFile != null) launchJava(javaFile);
		if(csFile != null) launchCS(csFile);
		if(pythonFile != null) launchPython(pythonFile);
		if(hasBrowserTests) launchFile(indexPage);
		else resultMonitor.sendMessage("quit");
		var platformResults:Bool = Thread.readMessage(true);
		serverProcess.kill();
		if(reportTestDir.exists) reportTestDir.deleteDirectoryContents();
		if(!FileSys.isWindows) serverFile.deleteFile();
		tmpRunnerDir.deleteDirectory();
		tmpDir.copyTo(reportTestDir);
		tmpDir.deleteDirectory(true);
		FileSys.setCwd(console.dir.nativePath);
		if (!platformResults && resultExitCode)
		{
			//print("TESTS FAILED");
			Sys.stderr().writeString("TESTS FAILED\n");
			Sys.stderr().flush();
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

	function readServerOutput()
	{
		// just consume server output
		var serverProcess:Process = Thread.readMessage(true);
		try
		{
			while (true)
			{
				serverProcess.stdout.readLine();
			}
		}
		catch (e:haxe.io.Eof) {}
	}

	function monitorResults()
	{
		var mainThread = Thread.readMessage(true);
		var serverProcess = Thread.readMessage(true);
		var serverTimeoutTimeSec = Thread.readMessage(true);
		var testPassCount = 0;
		var testFailCount = 0;
		var testErrorCount = 0;
		var startTime = Sys.time();
		var lastResultTime = startTime;
		var serverHung = false;
		if (serverTimeoutTimeSec == null || serverTimeoutTimeSec < 10) serverTimeoutTimeSec = DEFAULT_SERVER_TIMEOUT_SEC;
		// Note: Tried using FileSystem.stat mod date to see changes in results.txt but
		//       writes are too quick so using line count instead.
		var fileName = tmpDir.nativePath + "results.txt";
		var file = null;
		var lineCount = 0;
		var platformMap = new StringMap<Bool>();
		do
		{
			if ((Sys.time() - lastResultTime) > serverTimeoutTimeSec)
			{
				serverHung = true;
				break;
			}
			if(Thread.readMessage(false) == "quit") break;
			if(!FileSystem.exists(fileName)) continue;
			if(file == null) file = tmpDir.resolvePath("results.txt");

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
				if (i < lineCount) lastResultTime = Sys.time();
				while (i < lineCount)
				{
					var line = lines[i++];
					if (line != ServerMain.END)
					{
						if (checkIfTestPassed(line)) testPassCount++;
						else if (checkIfTestFailed(line)) testFailCount++;
						else testErrorCount++;
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
		} while (true);
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

	function getTargetName(result:String):String
	{
		return result.split("under ")[1].split(" using")[0];
	}

	function checkIfTestPassed(result:String):Bool
	{
		return result.indexOf(ServerMain.PASSED) != -1;
	}

	function checkIfTestFailed(result:String):Bool
	{
		return result.indexOf(ServerMain.FAILED) != -1;
	}

	function launchFile(file:File):Int
	{
		var targetLocation:String  = HTTPClient.DEFAULT_SERVER_URL + "/tmp/runner/" + file.fileName;
		var parameters:Array<String> = [];

		// See http://www.dwheeler.com/essays/open-files-urls.html
		if (FileSys.isWindows)
		{
			parameters.push("start");
			if (browser != null)
			{
				if (browser.substr(0, 12) == "flashdevelop") 
				{
					return sendFlashDevelopCommand(browser, "Browse", targetLocation);
				}
				parameters.push(browser);
			}
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
	
	function sendFlashDevelopCommand(args:String, cmd:String, data:String) 
	{
		var port = 1978;
		var parts = args.split(':');
		if (parts.length > 1) port = Std.parseInt(parts[1]);
		
		try {
			var conn = new Socket();
			conn.connect(new Host("localhost"), port);
			conn.write('<flashconnect><message cmd="call" command="' + cmd + '">' + data + '</message></flashconnect>');
			conn.output.writeByte(0);
			conn.close(); 
		}
		catch (ex:Dynamic) {
			print("ERROR: Failed to connect to FlashDevelop socket server");
			return 1;
		}
		return 0;
	}

	inline function launchNeko(file:File):Int return launch(file, 'neko', [file.nativePath]);
	
	inline function launchCPP(file:File):Int return launch(file, file.nativePath);
	
	inline function launchJava(file:File):Int return launch(file, 'java', ['-jar', file.nativePath]);
	
	inline function launchCS(file:File):Int return FileSys.isWindows ? launch(file, file.nativePath) : launch(file, 'mono', [file.nativePath]);
	
	inline function launchPython(file:File):Int return launch(file, FileSys.isWindows ? 'python' : 'python3', [file.nativePath]);
	
	function launch(file:File, executor:String, ?args:Array<String>):Int {
		file.copyTo(reportRunnerDir.resolvePath(file.fileName));
		FileSys.setCwd(config.dir.nativePath);
		var exitCode = runProgram(executor, args);
		FileSys.setCwd(console.originalDir.nativePath);
		if(exitCode > 0) error('Error ($exitCode) running $file', exitCode);
		return exitCode;
	}
	
	function runProgram(name:String, ?args:Array<String>)
	{
		var process = new Process(name, args);

		try
		{
			while (true)
			{
				Sys.sleep(0.01);
				var output = process.stdout.readLine();
				Sys.println(output);
			}
		}
		catch (e:haxe.io.Eof) {}

		var exitCode:Int = 0;
		var error:String = null;

		try
		{
			exitCode = process.exitCode();
			if(exitCode > 0) {
				var sb = new StringBuf();
				try {
					while(true) {
						sb.add(process.stderr.readLine());
						sb.add("\n");
					}
				} catch(e:haxe.io.Eof) {}
				error = sb.toString();
			}
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
			Sys.println("Error running '" + name + "'\n\t" + error);
		}

		return exitCode;
	}
}
