import massive.munit.client.PrintClient;
import massive.munit.client.RichPrintClient;
import massive.munit.client.HTTPClient;
import massive.munit.client.JUnitReportClient;
import massive.munit.client.SummaryReportClient;
import massive.munit.TestRunner;

#if js
import js.Lib;
#end

#if nodejs
import js.Node;
#end

/**
 * Auto generated Test Application.	
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestMain 
{		
	static function main(){
		new TestMain();
	}

	public function new()
	{
		//js.Node.child_process.
		var suites = new Array<Class<massive.munit.TestSuite>>();
		suites.push(TestSuite);

		#if nodejs
			//#if MCOVER
			//	var client = new mcover.coverage.client.MCoverPrintClient();
			//	var httpClient = new HTTPClient(new mcover.coverage.munit.client.MCoverSummaryReportClient());
			//#else
				var client = new RichPrintClient();
				var httpClient = new HTTPClient(new SummaryReportClient());
			//#end
		#else
			#if MCOVER
				var client = new mcover.coverage.munit.client.MCoverPrintClient();
				var httpClient = new HTTPClient(new mcover.coverage.munit.client.MCoverSummaryReportClient());
			#else
				var client = new RichPrintClient();
				var httpClient = new HTTPClient(new SummaryReportClient());
			#end
		#end

		var runner:TestRunner = new TestRunner(client);
		//#if (!nodejs)
		runner.addResultClient(httpClient);
		//#end
		//runner.addResultClient(new TestRunner(new HTTPClient(new JUnitReportClient(), "http://localhost:2000")));
		runner.completionHandler = completionHandler;
		runner.run(suites);
	}
	
	/*
		updates the background color and closes the current browser
		for flash and html targets (useful for continous integration servers)
	*/
	private function completionHandler(successful:Bool):Void
	{
		try
		{
			#if flash
				flash.external.ExternalInterface.call("testResult", successful);	
			#elseif flash9
				flash.external.ExternalInterface.call("testResult", successful);
			#elseif nodejs
				Node.process.exit(successful ? 0 : 1);
			#elseif (js && !nodejs)
				js.Lib.eval("testResult(" + successful + ");");
			#elseif sys
				Sys.exit(0);
			#end
		}
		// if run from outside browser can get error which we can ignore
		catch (e:Dynamic)
		{
		}
	}
}