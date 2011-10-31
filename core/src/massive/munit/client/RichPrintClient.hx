/****
* Copyright 2011 Massive Interactive. All rights reserved.
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
****/

package massive.munit.client;
import massive.munit.AssertionException;
import massive.munit.ITestResultClient;
import massive.munit.TestResult;
import massive.munit.util.MathUtil;
import massive.haxe.util.ReflectUtil;
import massive.munit.util.Timer;

import massive.munit.client.PrintClient;

/**
 * Generates rich html output for JS/Flash.
 * For other targets it prints out basic string output (neko, php, etc)
 */
class RichPrintClient implements IAdvancedTestResultClient
{
	/**
	 * Default id of this client.
	 */
	public static inline var DEFAULT_ID:String = "PrintClient";



	/**
	 * The unique identifier for the client.
	 */
	public var id(default, null):String;

	
	/**
	 * Handler which if present, is called when the client has completed generating its results.
	 */
	public var completionHandler(get_completeHandler, set_completeHandler):ITestResultClient -> Void;
	function get_completeHandler():ITestResultClient -> Void 
	{
		return completionHandler;
	}
	function set_completeHandler(value:ITestResultClient -> Void):ITestResultClient -> Void
	{
		return completionHandler = value;
	}

	public var output(get_output, null):String;
	function get_output():String
	{
		if(useHTML) return helper.htmlOutput;
		else return helper.stringOutput;
	}

	var useHTML:Bool;


	var failures:Array<Dynamic>;
	var errors:Array<Dynamic>;
	var ignored:Array<Dynamic>;
	var traces:Array<Dynamic>;
	
	var currentTestClass:String;	
	var currentTestResult:TestResultState;

	var originalTrace:Dynamic;
	var includeIgnoredReport:Bool;


	var helper:RichPrintClientHelper;	


	var divider:String;
	var divider2:String;

	


	public function new(?includeIgnoredReport:Bool = true)
	{
		id = DEFAULT_ID;
		#if (js || flash)
			useHTML = true;
		#else
			useHTML = false;
		#end
		
		this.includeIgnoredReport = includeIgnoredReport;
		init();

		if(!useHTML)
		{
			printLine("MUnit Results");
			printLine(divider);
		}
		
	}

	function init():Void
	{
		originalTrace = haxe.Log.trace;
		haxe.Log.trace = customTrace;

		failures = [];
		errors = [];
		ignored = [];
		traces = [];

		currentTestClass = null;
	
		helper = new RichPrintClientHelper();

		divider = "------------------------------";
		divider2 = "==============================\n";
	}


	/**
	* Classed when test class changes
	*
	* @param className		qualified name of current test class
	*/
	public function setCurrentTestClass(className:String):Void
	{
		if(currentTestClass == className) return;
		
		if(currentTestClass != null)
		{
			updateLastTestResult();
		}
		currentTestClass = className;

		errors = [];
		failures = [];
		traces = [];

		if(useHTML)
		{
			ignored = [];
		}

		

		if(useHTML)
		{
			helper.createTestClass(currentTestClass);
		}
		else
		{
			printLine("Class: " + currentTestClass + " ");
		}
	}

	/**
	 * Called when a test passes.
	 *  
	 * @param	result			a passed test result
	 */
	public function addPass(result:TestResult):Void
	{
		if(useHTML)
		{
			helper.addTest(result);
		}
		else
		{
			print(".");
		}
	}
	
	/**
	 * Called when a test fails.
	 *  
	 * @param	result			a failed test result
	 */
	public function addFail(result:TestResult):Void
	{
		failures.push(result.failure);

		if(useHTML)
		{
			helper.addTest(result);
		}
		else
		{
			print("!");
		}
	}
	
	/**
	 * Called when a test triggers an unexpected exception.
	 *  
	 * @param	result			an erroneous test result
	 */
	public function addError(result:TestResult):Void
	{
		helper.addTest(result);

		errors.push(result.error);

		if(useHTML)
		{
			helper.addTest(result);
		}
		else
		{
			print("!");
		}
	}
	
	/**
	 * Called when a test has been ignored.
	 *
	 * @param	result			an ignored test
	 */
	public function addIgnore(result:TestResult):Void
	{
		if (includeIgnoredReport)
		{
			var str = result.location;
			if(result.description != null) str == " - " + result.description;

			ignored.push(str);
	

			if(useHTML)
			{
				helper.addTest(result);
			}
			else
			{
				print(",");
			}
		}		
	}
	
	/**
	 * Called when all tests are complete.
	 *  
	 * @param	testCount		total number of tests run
	 * @param	passCount		total number of tests which passed
	 * @param	failCount		total number of tests which failed
	 * @param	errorCount		total number of tests which were erroneous
	 * @param	ignoreCount		total number of ignored tests
	 * @param	time			number of milliseconds taken for all tests to be executed
	 * @return	collated test result data
	 */
	public function reportFinalStatistics(testCount:Int, passCount:Int, failCount:Int, errorCount:Int, ignoreCount:Int, time:Float):Dynamic
	{
		updateLastTestResult();
	
		printFinalReports();
		

		var result = passCount == testCount;

		var str = result ? "PASSED" : "FAILED";
		str += "\n" + "Tests: " + testCount + "  Passed: " + passCount + "  Failed: " + failCount + " Errors: " + errorCount + " Ignored: " + ignoreCount + " Time: " + MathUtil.round(time, 5);

		if(useHTML)
		{
			helper.printSummary(str);
			helper.setResult(result);
		}
		else
		{
			printLine(divider2);
			printLine(str);
			printLine("");
			printLine("");
			
		}
		
		haxe.Log.trace = originalTrace;
		if (completionHandler != null) completionHandler(this); 
		
		return null;
		
	}

	/**
	* Stub method to add any additional reports prior to printing final result summary
	*/
	function printFinalReports()
	{
		if(!useHTML)
		{
			if(!includeIgnoredReport || ignored.length == 0) return;

			printLine("");
			printLine("Ignored " + ignored.length + " Tests:");
			printLine(divider);
			for(ign in ignored)
			{
				printLine(ign, 1);
			}

			ignored = [];
		}
	}


	/**
	* summarises result for currently executing test class
	*/
	function updateLastTestResult()
	{
		currentTestResult = getLastTestResult();

		if(useHTML)
		{
			helper.setTestClassResult(currentTestResult);
		}
		else
		{
			for(trc in traces)
			{
				printLine(Std.string(trc), 1);
			}
			for(error in errors)
			{
				printLine("ERROR: " + Std.string(errors), 1);
			}

			for(failure in failures)
			{
				printLine("FAIL: " + Std.string(failure), 1);
			}
			

		}
		
	}


	
	// We print exceptions captured (failures or errors) after all tests 
	// have completed for a test class.
	function getLastTestResult():TestResultState
	{
		if(errors.length > 0)
		{
			return TestResultState.ERROR;
		}
		else if(failures.length > 0)
		{
			return TestResultState.FAILED;
		}
		else
		{
			return TestResultState.PASSED; 
		}
	}


	function customTrace(value, ?info:haxe.PosInfos)
	{
		var str =  "TRACE: " + info.fileName + "|" + info.lineNumber + "| " + Std.string(value);
		if(useHTML)
		{
			helper.trace(str);
		}
		else
		{
			traces.push(str);
		}
		
	}


	function print(value)
	{
		helper.print(value);
	}

	function printLine(value, ?indent:Int = 0)
	{
		if(indent > 0)
		{
			value = StringTools.lpad("", " ", indent*4) + value;
		}
		helper.printLine(value);
	}
}

enum TestResultState
{
	NONE;
	PASSED;
	FAILED;
	ERROR;
	WARNING;
}

class RichPrintClientHelper extends PrintClientHelper
{
	public function new()
	{
		super();
	}

	override public function setResult(value:Bool)
	{
		addToQueue("setResult",[value]);
	}

	///////// TEST APIS /////////

	public function createTestClass(currentTestClass:String)
	{
		addToQueue("createTestClass",[currentTestClass]);	
		updateTestSummary("Class: " + currentTestClass + " ");
	}

	public function addTest(result:TestResult)
	{
		var value = serializeTestResult(result);

		if(result.error != null)
		{
			updateTestSummary("!");
			addToQueue("addTestError", [value]);
		}
		else if(result.failure != null)
		{
			updateTestSummary("!");
			addToQueue("addTestFail", [value]);
		}
		else if(result.ignore)
		{
			updateTestSummary(",");
			addToQueue("addTestIgnore", [value]);
		}
		else if(result.passed)
		{
			updateTestSummary(".");
			//addToQueue("addTestPass", value);
		}
	}

	function serializeTestResult(result:TestResult):String
	{
		var summary = result.name;

		if(result.description != null && result.description != "")
		{
			summary += " - " + result.description + " -";
		}

		summary += " (" + MathUtil.round(result.executionTime, 4) + "s)";

		var str = "";
		if(result.error != null)
		{
			str = "Error: " + summary + "\n" + Std.string(result.error);
		}
		else if(result.failure != null)
		{
			str = "Failure: " + summary +  "\n" + Std.string(result.failure);
		}
		else if(result.ignore)
		{
			str = "Ignore: " + summary;
		}
		else if(result.passed)
		{
			//str = str;
		}

		return str;
	}

	public function updateTestSummary(value:String)
	{
		addToQueue("updateTestSummary", [value]);
	}

	public function addTestCoverageClass(value:String, percent:Float)
	{
		addToQueue("addTestCoverageClass", [value, percent]);
	}

	public function addTestCoverageItem(value:String)
	{
		addToQueue("addTestCoverageItem", [value]);
	}

	public function setTestClassResult(value:TestResultState)
	{
		if(value == null) value = NONE;
		
		var code:Int =
		
		switch(value)
		{
			case PASSED: 0;
			case FAILED: 1;
			case ERROR: 2;
			case WARNING: 3;
			default: -1;
			
		}

		if(code == -1) return;

		addToQueue("setTestClassResult", [code]);
	}

	///////// REPORTS //////////
	
	public function createCoverageReport(value:Float)
	{
		addToQueue("createCoverageReport", [value]);
	}

	public function addMissingCoverageClass(coverageClass:String, percent:Float)
	{
		addToQueue("addMissingCoverageClass", [coverageClass, percent]);
	}

	public function addCoverageSummary(value:String)
	{
		addToQueue("addCoverageSummary", [value]);
	}

	//////////// FINAL RESULTS ////////////

	public function printSummary(value:String)
	{
		addToQueue("printSummary", [value]);
	}

}

