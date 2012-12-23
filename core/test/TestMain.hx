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

import massive.munit.client.PrintClient;
import massive.munit.client.RichPrintClient;
import massive.munit.client.HTTPClient;
import massive.munit.client.JUnitReportClient;
import massive.munit.client.SummaryReportClient;
import massive.munit.TestRunner;
#if js
import js.Lib;
import js.Dom;
#end

#if (haxe_208 && !haxe_209)
	#if neko
		import neko.Sys;
	#elseif cpp
		import cpp.Sys;
	#elseif php
		import php.Sys
	#end
#end


/**
 * Auto generated Test Application.	
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestMain 
{		
	static function main(){	new TestMain();}

	public function new()
	{		
		var suites = new Array<Class<massive.munit.TestSuite>>();
		suites.push(TestSuite);

		#if MCOVER
			var client = new mcover.coverage.munit.client.MCoverPrintClient();
			var httpClient = new HTTPClient(new mcover.coverage.munit.client.MCoverSummaryReportClient());
		#else
			var client = new RichPrintClient();
			var httpClient = new HTTPClient(new SummaryReportClient());
		#end

		var runner:TestRunner = new TestRunner(client);	
		runner.addResultClient(httpClient);
		//runner.addResultClient(new HTTPClient(new JUnitReportClient()));	
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
			#elseif js
				js.Lib.eval("testResult(" + successful + ");");
			#elseif (neko || cpp || php)
				Sys.exit(0);
			#end
		}
		// if run from outside browser can get error which we can ignore
		catch (e:Dynamic)
		{
		}
	}
}