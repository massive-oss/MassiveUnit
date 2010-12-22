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

	public static inline var EXIT:String = "EXIT";

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

		var results:String = "Tests " + result + " under " + platform + " using client " + client;		
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
