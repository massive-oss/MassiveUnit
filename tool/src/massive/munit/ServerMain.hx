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
import massive.neko.io.File;
import massive.neko.io.FileSys;
import massive.haxe.util.RegExpUtil;
import massive.munit.client.HTTPClient;
import massive.munit.client.PrintClient;
import massive.munit.client.JUnitReportClient;
import massive.munit.util.Timer;
import neko.Lib;
import neko.Sys;
import neko.vm.Thread;

class ServerMain
{
	public static inline var PASSED:String = "PASSED";
	public static inline var FAILED:String = "FAILED";
	public static inline var ERROR:String = "ERROR";

	static function main()
	{
		new ServerMain();
	}

	public function new():Void
	{
		processData();
	}
		
	private function processData():Void
	{
		var client:String = neko.Web.getClientHeader(HTTPClient.CLIENT_HEADER_KEY);
		var platform:String = neko.Web.getClientHeader(HTTPClient.PLATFORM_HEADER_KEY);		
		var requestId:String = neko.Web.getClientHeader(HTTPClient.REQUEST_ID_KEY);

		var hash:Hash<String> = neko.Web.getParams();
		var data:String = hash.get("data"); // gets variable 'data' from posted data

		if(data == null)
		{
			neko.Lib.print("Error: Invalid content sent to server: \n" + hash);
			neko.Sys.exit(-1);
		}

		var tmpDir:File = File.current.resolveDirectory("tmp", true);
		tmpDir.createDirectory();

		var clientDir:File = tmpDir.resolveDirectory(client, true);
		clientDir.createDirectory();

		var platformDir:File = clientDir.resolveDirectory(platform, true);
		platformDir.createDirectory();

		var result:String = ERROR;
		switch(client)
		{
			case JUnitReportClient.DEFAULT_ID: 
				result = writeJUnitReportData(data, platformDir);
			case PrintClient.DEFAULT_ID: 
				result = writePrintData(data, platformDir);
			default:
				result = writePrintData(data, platformDir);
		}

		var results:String = "Tests " + result + " under " + platform + " using " + client + " client";		
		// Send result back as response data to the client which sent the request
		trace(results);

		// Log our results. This is sent to stderr for process running this server to pick up
		neko.Web.logMessage(results);
		neko.Web.flush();
		
		if (requestId == "0") 
		{
			// Allow a short delay to give time to return the response
			Timer.delay(shutdownServer, 1);
		}
	}	
	
	//------------------------ Write JUnit Report Data
	
	private function writeJUnitReportData(data:String, dir:File):String
	{
		var xml:Xml = Xml.parse(data);
		
		var rawDir:File = dir.resolveDirectory("xml", true);
		rawDir.createDirectory();
		
		var result:String = "";
		for (test in xml.firstChild().elementsNamed("testsuite"))
		{
			var fileName:String = "TEST-" + test.get("name") + ".xml";
			var file:File = rawDir.resolvePath(fileName);
			file.writeString("<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n" + test.toString(), false);
			
			// determine the result
			
			var failures:Int = Std.parseInt(test.get("failures"));
			var errors:Int = Std.parseInt(test.get("errors"));
			
			if (failures == null) failures = 0;
			if (errors == null) errors = 0;
			var failed:Bool = (failures > 0 || errors > 0);
			
			if (failed && result != FAILED) result = FAILED;
			else if (!failed && result == "") result = PASSED;
		}
		if (result == "") result = ERROR;

		return result;
	}
	
	//------------------------ Write Print Data
	
	private function writePrintData(data:String, dir:File):String
	{
		var file:File = dir.resolvePath("output.txt");
		file.writeString(data, false);
		
		// determine the result
		
		var lines:Array<String> = data.split("\n");
		lines.reverse();

		for (line in lines)
		{	
			if (line.indexOf("PASSED") == 0) return PASSED;
			else if(line.indexOf("FAILED") == 0) return FAILED;
		}
		
		return ERROR;
	}
	
	private function shutdownServer():Void
	{
		Sys.exit(0);
	}
}
