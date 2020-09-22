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
import massive.sys.io.File;
import massive.sys.io.FileSys;
import massive.haxe.util.RegExpUtil;
import massive.munit.client.HTTPClient;
import massive.munit.client.PrintClient;
import massive.munit.client.JUnitReportClient;
import massive.munit.client.SummaryReportClient;
import massive.munit.util.Timer;
#if (haxe_ver >= 4.0)
import sys.thread.Thread;
#else
import neko.vm.Thread;
#end

class ServerMain
{
	public static inline var PASSED:String = "PASSED";
	public static inline var FAILED:String = "FAILED";
	public static inline var ERROR:String = "ERROR";
	public static inline var END:String = "END";
	var tmpDir:File;
	
	static function main() new ServerMain();

	public function new()
	{
		try 
		{
			processData();
		}
		catch(e:Dynamic)
		{
			Sys.print("Error: Server terminated with fatal error. \n");
			recordResult(END + "\n");
			Sys.exit(-1);
		}
	}
		
	function processData()
	{
		var client:String = neko.Web.getClientHeader(HTTPClient.CLIENT_HEADER_KEY);
		var platform:String = neko.Web.getClientHeader(HTTPClient.PLATFORM_HEADER_KEY);
		tmpDir = File.current.resolveDirectory("tmp", true);
		tmpDir.createDirectory();
		if (client == BrowserTestsCompleteReporter.CLIENT_RUNNER_HOST)
		{
			recordResult(END + "\n");
			return;
		}
		if (client == null || platform == null) return;
		var hash = neko.Web.getParams();
		var data = hash.get("data"); // gets variable 'data' from posted data (as2 LoadVars)
		if (data == null) data = neko.Web.getPostData();
		if (data == null)
		{
			Sys.print("Error: Invalid content sent to server: \n" + data);
			recordResult(END + "\n");
			Sys.exit(-1);
		}
		
		var clientDir:File = tmpDir.resolveDirectory(client, true);
		clientDir.createDirectory();

		var platformDir:File = clientDir.resolveDirectory(platform, true);
		platformDir.createDirectory();

		var result:String = switch(client)
		{
			case JUnitReportClient.DEFAULT_ID: writeJUnitReportData(data, platformDir);
			case PrintClient.DEFAULT_ID: writePrintData(data, platformDir);
			case SummaryReportClient.DEFAULT_ID: writeSummaryReportData(data, platformDir);
			case _: writePrintData(data, platformDir);
		}
        recordResult('Tests ${result} under ${platform} using ${client} client\n');
	}
	
	function recordResult(result:String)
	{
		var MAX_WRITE_ATTEMPTS = 4;
		Sys.println(result);
		var writeAttempts = 0;
		var writeSuccess = false;
		
		do
		{
			var file:File = tmpDir.resolvePath("results.txt");
			var contents = file.readString();
			if (contents == null) contents = "";
			contents += result;
			
			try {
				file.writeString(contents, true);
				writeSuccess = true;
			}
			catch (e:Dynamic) {
				Sys.sleep(0.1);
			}
		} while(!writeSuccess && writeAttempts++ < MAX_WRITE_ATTEMPTS);
		if (writeAttempts >= MAX_WRITE_ATTEMPTS) neko.Web.logMessage("ERROR: Server could not write test result to results.txt file");
	}
	
	function writeJUnitReportData(data:String, dir:File):String
	{
		var xml:Xml = Xml.parse(data);
		var suites = xml.firstChild().elementsNamed("testsuite");
		var rawDir:File = dir.resolveDirectory("xml", true);
		rawDir.createDirectory();
		var result:String = "";
		var count = 0;
		for (test in suites)
		{
			var fileName:String = "TEST-" + test.get("name") + ".xml";
			var file:File = rawDir.resolvePath(fileName);
			file.writeString("<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n" + test.toString(), false);
			var failures:Int = Std.parseInt(test.get("failures"));
			var errors:Int = Std.parseInt(test.get("errors"));
			if (failures == null) failures = 0;
			if (errors == null) errors = 0;
			var failed:Bool = (failures > 0 || errors > 0);
			if (failed && result != FAILED) result = FAILED;
			else if (!failed && result == "") result = PASSED;
			count++;
		}
		if (count == 0) result = PASSED; // no tests run
		else if (result == "") result = ERROR;
		return result;
	}
	
	function writePrintData(data:String, dir:File):String
	{
		var file:File = dir.resolvePath("output.txt");
		file.writeString(data, false);
		var lines:Array<String> = data.split("\n");
		lines.reverse();
		for (line in lines)
		{	
			if (line.indexOf("PASSED") == 0) return PASSED;
			if (line.indexOf("FAILED") == 0) return FAILED;
		}
		return ERROR;
	}

	/**
	 *Parses a summary text report
	 */
	function writeSummaryReportData(data:String, dir:File):String
	{
		var file:File = dir.resolvePath("summary.txt");
		file.writeString(data, false);
		var exitCode = 0;
		var lines:Array<String> = data.split("\n");
		for (line in lines)
		{	
			if(line == "" || line.indexOf("#") == 0) continue;
			var tmp = line.split(":");
			if(tmp[0] == "result" && tmp[1] == "true") return PASSED;
			if(tmp[0] == "error" && tmp[1] != "0") return ERROR;
		}
		return FAILED;
	}
}
