/****
* Copyright 2017 Massive Interactive. All rights reserved.
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
import massive.munit.ITestResultClient.CoverageResult;
import massive.munit.TestResult;
import massive.munit.client.PrintClientBase;
import massive.munit.util.MathUtil;

class RichPrintClient extends PrintClientBase
{
	/**
	 * Default id of this client.
	 */
	public static inline var DEFAULT_ID:String = "RichPrintClient";

	var testClassResultType:TestResultType;
	var external:ExternalPrintClient;
	
	public function new()
	{
		super();
		id = DEFAULT_ID;
	}

	override function init()
	{
		super.init();
		originalTrace = haxe.Log.trace;
		haxe.Log.trace = customTrace;
		external = new ExternalPrintClientJS();
	}

	override function initializeTestClass()
	{
		super.initializeTestClass();
		external.createTestClass(currentTestClass);
		external.printToTestClassSummary("Class: " + currentTestClass + " ");
	}

	override function updateTestClass(result:TestResult)
	{
		super.updateTestClass(result);

		var value = serializeTestResult(result);
		switch(result.type)
		{
			case PASS:
				external.printToTestClassSummary(".");
				external.addTestPass(value);
			case FAIL:
				external.printToTestClassSummary("!");
				external.addTestFail(value);
			case ERROR:
				external.printToTestClassSummary("x");
				external.addTestError(value);
			case IGNORE:
				external.printToTestClassSummary(",");
				external.addTestIgnore(value);
			case UNKNOWN:
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
		if(result.error != null) return "Error: " + summary + "\n" + Std.string(result.error);
		if(result.failure != null) return "Failure: " + summary +  "\n" + Std.string(result.failure);
		if(result.ignore) return "Ignore: " + summary;
		return null;
	}

	/**
	 * summarises result for currently executing test class
	 * and update visual state of test class
	 */
	override function finalizeTestClass()
	{
		super.finalizeTestClass();
		testClassResultType = getTestClassResultType();
		var code:Int = switch(testClassResultType)
		{
			case PASS: 0;
			case FAIL: 1;
			case ERROR: 2;
			case IGNORE: 3;
			default: -1;
		}
		if(code == -1) return;
		external.setTestClassResult(code);
	}

	// We print exceptions captured (failures or errors) after all tests 
	// have completed for a test class.
	function getTestClassResultType():TestResultType
	{
		if(errorCount > 0) return TestResultType.ERROR;
		if(failCount > 0) return TestResultType.FAIL;
		if(ignoreCount > 0) return TestResultType.IGNORE;
		return TestResultType.PASS;
	}

	override public function setCurrentTestClassCoverage(result:CoverageResult)
	{
		super.setCurrentTestClassCoverage(result);
		external.printToTestClassSummary(" [" + result.percent + "%]");
		if(result.percent == 100) return;
		external.addTestClassCoverage(result.className, result.percent);
		for(item in result.blocks)
		{
			external.addTestClassCoverageItem(item);
		}
	}
	
	override public function reportFinalCoverage(?percent:Float = 0, missingCoverageResults:Array<CoverageResult>, summary:String,
		?classBreakdown:String,
		?packageBreakdown:String,
		?executionFrequency:String
		)
	{
		super.reportFinalCoverage(percent, missingCoverageResults, summary, classBreakdown, packageBreakdown, executionFrequency);

		external.createCoverageReport(percent);
		printMissingCoverage(missingCoverageResults);

		if(executionFrequency != null)
		{
			external.addCoverageReportSection("Code Execution Frequency", trim(executionFrequency));
		}

		if(classBreakdown != null)
		{
			external.addCoverageReportSection("Class Breakdown", trim(classBreakdown));
		}

		if(packageBreakdown != null)
		{
			external.addCoverageReportSection("Package Breakdown", trim(packageBreakdown));
		}

		if(packageBreakdown != null)
		{
			external.addCoverageReportSection("Summary", trim(summary));
		}
	}

	function trim(output:String):String
	{
		while(output.indexOf("\n") == 0) output = output.substr(1);
		while(output.lastIndexOf("\n") == output.length - 2) output = output.substr(0, output.length - 2);
		return output;
	}

	function printMissingCoverage(missingCoverageResults:Array<CoverageResult>)
	{
		if(missingCoverageResults == null || missingCoverageResults.length == 0) return;

		for(result in missingCoverageResults)
		{
			external.addMissingCoverageClass(result.className, result.percent);
			for(item in result.blocks)
			{
				external.addTestClassCoverageItem(item);
			}
		}
	}

	override function printFinalStatistics(result:Bool, testCount:Int, passCount:Int, failCount:Int, errorCount:Int, ignoreCount:Int, time:Float)
	{
		super.printFinalStatistics(result, testCount, passCount, failCount, errorCount, ignoreCount, time);
		var sb = new StringBuf();
		sb.add(result ? "PASSED" : "FAILED");
		sb.add("\nTests: "); sb.add(testCount);
		sb.add("  Passed: "); sb.add(passCount);
		sb.add("  Failed: "); sb.add(failCount);
		sb.add(" Errors: "); sb.add(errorCount);
		sb.add(" Ignored: "); sb.add(ignoreCount);
		sb.add(" Time: "); sb.add(MathUtil.round(time, 5));
		external.printSummary(sb.toString());
	}

	override function printOverallResult(result:Bool)
	{
		super.printOverallResult(result);
		external.setResult(result);
	}

	function customTrace(value, ?info:haxe.PosInfos)
	{
		if(info != null && info.customParams != null) value = '${value}, ${info.customParams.join(", ")}';
		addTrace(value, info);
		var traces = getTraces();
		var t = traces[traces.length - 1];
		external.trace(t);
	}

	override public function print(value:Dynamic)
	{
		super.print(value);
		#if(neko || cpp || java || cs || python || php || hl || eval || lua)
		Sys.print(value);
		#elseif nodejs
		js.Node.process.stdout.write(Std.string(value));
		#end
	}
}