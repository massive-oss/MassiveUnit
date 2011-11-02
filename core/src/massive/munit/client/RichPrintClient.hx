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
class RichPrintClient extends PrintClient
{
	/**
	 * Default id of this client.
	 */
	public static inline var DEFAULT_ID:String = "PrintClient";
	
	override function get_output():String
	{
		if(isRichClient) return helperRich.htmlOutput;
		else return helperRich.stringOutput;
	}

	var isRichClient:Bool;

	var currentTestResult:TestResultState;

	var helperRich:RichPrintClientHelper;

	public function new(?includeIgnoredReport:Bool = true)
	{
		super(includeIgnoredReport);
		id = DEFAULT_ID;
	}

	override function init():Void
	{
		#if (js || flash)
			isRichClient = true;
		#else
			isRichClient = false;
		#end

		super.init();
		helperRich = cast(helper, RichPrintClientHelper);
	}

	override function createHelper():PrintClientHelper
	{
		return new RichPrintClientHelper();
	}

	override function printNewTest()
	{
		super.printNewTest();

		if(isRichClient)
			helperRich.createTestClass(currentTestClass);	
	}

	/**
	 * Called when a test passes.
	 *  
	 * @param	result			a passed test result
	 */
	override public function addPass(result:TestResult):Void
	{
		super.addPass(result);

		if(isRichClient)
			helperRich.addTest(result);
	}
	
	/**
	 * Called when a test fails.
	 *  
	 * @param	result			a failed test result
	 */
	override public function addFail(result:TestResult):Void
	{
		super.addFail(result);

		if(isRichClient)
			helperRich.addTest(result);
	}
	
	/**
	 * Called when a test triggers an unexpected exception.
	 *  
	 * @param	result			an erroneous test result
	 */
	override public function addError(result:TestResult):Void
	{
		super.addFail(result);
		
		if(isRichClient)
			helperRich.addTest(result);
	}
	
	/**
	 * Called when a test has been ignored.
	 *
	 * @param	result			an ignored test
	 */
	override public function addIgnore(result:TestResult):Void
	{
		super.addFail(result);
		
		if(isRichClient)
			helperRich.addTest(result);
	}

	override function printFinalResult(resultString:String)
	{
		super.printFinalResult(resultString);

		if(isRichClient)
			helperRich.printSummary(resultString);
	}
	
	/**
	* summarises result for currently executing test class
	*/
	override function updateLastTestResult()
	{
		super.updateLastTestResult();

		currentTestResult = getLastTestResult();
		helperRich.setTestClassResult(currentTestResult);
	}


	
	override function printFinalReports()
	{
		if(!isRichClient)
			super.printFinalReports();
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


	override function customTrace(value, ?info:haxe.PosInfos)
	{
		super.customTrace(value, info);

		if(isRichClient)
		{
			helperRich.trace(traces[traces.length-1]);
		}
		
	}


	override function print(value)
	{
		if(!isRichClient)
			super.print(value);
	}

	override function printLine(value, ?indent:Int = 0)
	{
		if(!isRichClient)
			super.printLine(value, indent);
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

