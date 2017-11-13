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
import massive.haxe.util.ReflectUtil;
import massive.munit.ITestResultClient.CoverageResult;
import massive.munit.TestResult;
import massive.munit.util.MathUtil;

class PrintClientBase extends AbstractTestResultClient
{
	/**
	 * Default id of this client.
	 */
	public static inline var DEFAULT_ID:String = "simple";
	var divider1:String = "------------------------------";
	var divider2:String = "==============================";
	public var verbose:Bool;
	var includeIgnoredReport:Bool;

	public function new(includeIgnoredReport:Bool = true)
	{
		super();
		id = DEFAULT_ID;
		verbose = false;
		this.includeIgnoredReport = includeIgnoredReport;
		printLine("MUnit Results");
		printLine(divider1);
	}

	override function initializeTestClass()
	{
		super.initializeTestClass();
		printLine("Class: " + currentTestClass + " ");
	}

	override function updateTestClass(result:TestResult)
	{
		super.updateTestClass(result);
		if(verbose) printLine(" " + result.name + ": " + result.type +" ");
		else
		{
			switch(result.type)
			{
				case PASS: print(".");
				case FAIL: print("!");
				case ERROR: print ("x");
				case IGNORE: print(",");
				case UNKNOWN:
			}
		}
	}

	override function finalizeTestClass()
	{
		super.finalizeTestClass();

		for(item in getTraces())
		{
			printLine("TRACE: " + item, 1);
		}

		for(result in currentClassResults)
		{
			switch(result.type)
			{
				case ERROR: printLine("ERROR: " + Std.string(result.error), 1);
				case FAIL: printLine("FAIL: " + Std.string(result.failure), 1);
				case IGNORE:
					var ingoredString = result.location;
					if(result.description != null) ingoredString += " - " + result.description;
					printLine("IGNORE: " + ingoredString, 1);
				case PASS, UNKNOWN:
			}
		}
	}

	override public function setCurrentTestClassCoverage(result:CoverageResult)
	{
		super.setCurrentTestClassCoverage(result);
		print(" [" + result.percent + "%]");
	}
	
	override public function reportFinalCoverage(?percent:Float = 0, missingCoverageResults:Array<CoverageResult>, summary:String,
		?classBreakdown:String,
		?packageBreakdown:String,
		?executionFrequency:String
		)
	{
		super.reportFinalCoverage(percent, missingCoverageResults, summary, classBreakdown, packageBreakdown, executionFrequency);

		printLine("");
		printLine(divider1);
		printLine("COVERAGE REPORT");
		printLine(divider1);

		if(missingCoverageResults != null && missingCoverageResults.length > 0)
		{
			printLine("MISSING CODE BLOCKS:");
			for(result in missingCoverageResults)
			{
				printLine(result.className + " [" + result.percent + "%]", 1);
				for(item in result.blocks)
				{
					printIndentedLines(item, 2);
				}
				printLine("");
			}
		}

		if(executionFrequency != null)
		{
			printLine("CODE EXECUTION FREQUENCY:");
			printIndentedLines(executionFrequency, 1);
			printLine("");
		}

		if(classBreakdown != null) printIndentedLines(classBreakdown, 0);
		if(packageBreakdown != null) printIndentedLines(packageBreakdown, 0);
		if(summary != null) printIndentedLines(summary, 0);
	}

	function printIndentedLines(value:String, indent:Int = 1)
	{
		var lines = value.split("\n");
		for(line in lines)
		{
			printLine(line, indent);
		}
	}

	override function printReports()
	{
		printFinalIgnoredStatistics(ignoreCount);
	}

	function printFinalIgnoredStatistics(count:Int)
	{
		if (!includeIgnoredReport || count == 0) return;

		var items = Lambda.filter(totalResults, filterIngored); 
		
		if(items.length == 0) return;

		printLine("");
		printLine("Ignored (" + count + "):");
		printLine(divider1);

		for(result in items)
		{
			var ingoredString = result.location;
			if(result.description != null) ingoredString += " - " + result.description;
			printLine("IGNORE: " + ingoredString, 1);
		}
		printLine("");
	}

	function filterIngored(result:TestResult):Bool
	{
		return result.type == IGNORE;
	}

	override function printFinalStatistics(result:Bool, testCount:Int, passCount:Int, failCount:Int, errorCount:Int, ignoreCount:Int, time:Float)
	{
		printLine(divider2);
		var sb = new StringBuf();
		sb.add(result ? "PASSED" : "FAILED");
		sb.add("\nTests: "); sb.add(testCount);
		sb.add("  Passed: "); sb.add(passCount);
		sb.add("  Failed: "); sb.add(failCount);
		sb.add(" Errors: "); sb.add(errorCount);
		sb.add(" Ignored: "); sb.add(ignoreCount);
		sb.add(" Time: "); sb.add(MathUtil.round(time, 5));
		printLine(sb.toString());
		printLine("");
	}

	override function printOverallResult(result:Bool)
	{
		printLine("");
	}
	
	public function print(value:Dynamic)
	{
		output += Std.string(value);
	}

	public function printLine(value:Dynamic, ?indent:Int = 0)
	{
		value = Std.string(value);
		value = indentString(value, indent);
		print("\n" + value);
	}

	function indentString(value:String, ?indent:Int = 0):String
	{
		if(indent > 0) value = StringTools.lpad("", " ", indent * 4) + value;
		return value;
	}
}

interface ExternalPrintClient
{
	function queue(methodName:String, ?args:Dynamic):Bool;
	function setResult(value:Bool):Void;
	function print(value:String):Void;
	function printLine(value:String):Void;
	function setResultBackground(value:Bool):Void;
	function createTestClass(className:String):Void;
	function printToTestClassSummary(value:String):Void;
	function setTestClassResult(resultType:Int):Void;
	function trace(value:Dynamic):Void;
	function addTestPass(value:String):Void;
	function addTestFail(value:String):Void;
	function addTestError(value:String):Void;
	function addTestIgnore(value:String):Void;
	function addTestClassCoverage(className:String, percent:Float = 0):Void;
	function addTestClassCoverageItem(value:String):Void;
	function createCoverageReport(percent:Float = 0):Void;
	function addMissingCoverageClass(className:String, percent:Float = 0):Void;
	function addCoverageReportSection(name:String, value:String):Void;
	function addCoverageSummary(value:String):Void;
	function printSummary(value:String):Void;
}

class ExternalPrintClientJS implements ExternalPrintClient
{
	public function new()
	{
		#if flash
			if(!flash.external.ExternalInterface.available)
			{
				throw new MUnitException("ExternalInterface not available");
			}

			if(!flashInitialised)
			{
				flashInitialised = true;
				flash.Lib.current.stage.addEventListener(flash.events.Event.ENTER_FRAME, enterFrameHandler);
			}

			if(!flash.system.Capabilities.isDebugger)
			{
				printLine("WARNING: Flash Debug Player not installed. May cause unexpected behaviour in MUnit when handling thrown exceptions.");
			}
		#elseif(js && !nodejs)
			var div = js.Browser.document.getElementById("haxe:trace");
			if (div == null) 
			{
				var positionInfo = ReflectUtil.here();
				var error:String = "MissingElementException: 'haxe:trace' element not found at " + positionInfo.className + "#" + positionInfo.methodName + "(" + positionInfo.lineNumber + ")";
				js.Browser.alert(error);
			}
		#end
	}

	#if flash
		static var externalInterfaceQueue:Array<String> = [];
		static var flashInitialised:Bool = false;
		static var externalInterfaceCounter:Int = 0;
		static var EXTERNAL_INTERFACE_FRAME_DELAY:Int = 20;

		static function enterFrameHandler(_)
		{
			if(externalInterfaceQueue.length == 0) return;
			if(externalInterfaceCounter ++ < EXTERNAL_INTERFACE_FRAME_DELAY) return;

			externalInterfaceCounter = 0;
			
			var tempArray = externalInterfaceQueue.copy();
			externalInterfaceQueue = [];

			for(jsCode in tempArray)
			{
				flash.external.ExternalInterface.call(jsCode);
			}
		}
	#end

	public function print(value:String)
	{
		queue("munitPrint", value);
	}

	public function printLine(value:String)
	{
		queue("munitPrintLine", value);
	}

	public function setResult(value:Bool)
	{
		queue("setResult", value);
	}

	public function setResultBackground(value:Bool)
	{
		queue("setResultBackground", value);
	}

	public function trace(value:Dynamic)
	{
		queue("munitTrace", value);
	}

	public function createTestClass(className:String)
	{
		queue("createTestClass", className);
	}

	public function printToTestClassSummary(value:String)
	{
		queue("updateTestSummary", value);
	}

	public function setTestClassResult(resultType:Int)
	{
		queue("setTestClassResult", resultType);
	}

	public function addTestPass(value:String)
	{
		if(value == null) return;
		queue("addTestPass", value);
	}

	public function addTestFail(value:String)
	{
		queue("addTestFail", value);
	}

	public function addTestError(value:String)
	{
		queue("addTestError", value);
	}

	public function addTestIgnore(value:String)
	{
		queue("addTestIgnore", value);
	}

	public function addTestClassCoverage(className:String, percent:Float = 0)
	{
		queue("addTestCoverageClass", [className, percent]);
	}

	public function addTestClassCoverageItem(value:String)
	{
		queue("addTestCoverageItem", value);
	}

	public function createCoverageReport(percent:Float = 0)
	{
		queue("createCoverageReport", percent);
	}

	public function addMissingCoverageClass(className:String, percent:Float = 0)
	{
		queue("addMissingCoverageClass", [className,percent]);
	}

	public function addCoverageReportSection(name:String, value:String)
	{
		queue("addCoverageReportSection", [name, value]);
	}
	
	public function addCoverageSummary(value:String)
	{
		queue("addCoverageSummary", value);
	}

	public function printSummary(value:String)
	{
		queue("printSummary", value);
	}

	public function queue(method:String, ?args:Dynamic):Bool
	{
		#if (!js && !flash || nodejs)
			//throw new MUnitException("Cannot call from non JS/Flash targets");
			return false;
		#end
		
		var a:Array<Dynamic> = [];
		if(Std.is(args, Array)) a = a.concat(cast(args, Array<Dynamic>));
		else a.push(args);
		var jsCode = convertToJavaScript(method, a);
		#if js
		return js.Lib.eval(jsCode);
		#elseif flash
		externalInterfaceQueue.push(jsCode);
		#end
		return false;
	}

	public function convertToJavaScript(method:String, ?args:Array<Dynamic>):String
	{
		var htmlArgs:Array<String> = args != null && args.length > 0 ? [for(arg in args) serialiseToHTML(Std.string(arg))] : null;
        if(htmlArgs == null) return "addToQueue(\"" + method + "\")";
        var result:String = "addToQueue(\"" + method + "\"";
        for(arg in htmlArgs) result += ",\"" + arg + "\"";
        result += ")";
        return result;
	}

	public function serialiseToHTML(value:Dynamic):String
	{
		#if js
		value = untyped js.Boot.__string_rec(value, "");
		#end
		var result:String = StringTools.htmlEscape(value);
		result = result.split("\n").join("<br/>");
		result = result.split(" ").join("&nbsp;");
		result = result.split("\"").join("\\\'");
		return result;
	}
}

