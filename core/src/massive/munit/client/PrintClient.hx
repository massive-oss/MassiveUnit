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

/**
 * Generates basic text formatted test result output.
 * 
 * <p>
 * Example output:
 * </p>
 * <pre>
 * MUnit Results
 * ------------------------------
 * 
 * Class: SampleTest ...
 * Class: sub.ItemTest ..
 * 
 * PASSED
 * Tests: 5  Passed: 5  Failed: 0 Errors: 0 Ignored: 0 Time: 0.202
 * ==============================
 * </pre>
 * 
 * @author Mike Stead
 */
class PrintClient implements IAdvancedTestResultClient
{
	/**
	 * Default id of this client.
	 */
	public static inline var DEFAULT_ID:String = "print";

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
		return output;
	}

	var failures:Array<String>;
	var errors:Array<String>;
	var ignored:Array<String>;
	var traces:Array<String>;

	var totalIgnored:Array<String>;
	
	var currentTestClass:String;	

	var originalTrace:Dynamic;
	
	var includeIgnoredReport:Bool;

	#if flash9
		var textField:flash.text.TextField;
	#elseif flash
		var textField:flash.TextField;
	#elseif js
		var textArea:Dynamic;
	#end


	var helper:PrintClientHelper;
	
	var newLline:String;
	var divider:String;
	var divider2:String;

	public function new(?includeIgnoredReport:Bool = true)
	{
		id = DEFAULT_ID;
		this.includeIgnoredReport = includeIgnoredReport;
		init();
		printHeader();
	}

	function init():Void
	{
		originalTrace = haxe.Log.trace;
		haxe.Log.trace = customTrace;

		
		divider = "------------------------------";
		divider2 = "==============================";

		currentTestClass = null;

		failures = [];
		errors = [];
		ignored = [];
		traces = [];

		totalIgnored = [];

		helper = createHelper();

		#if flash9
			textField = new flash.text.TextField();
			textField.selectable = true;
			textField.width = flash.Lib.current.stage.stageWidth;
			textField.height = flash.Lib.current.stage.stageHeight;
			flash.Lib.current.addChild(textField);
		#elseif flash
			textField = flash.Lib.current.createTextField("__munitOutput", 20000, 0, 0, flash.Stage.width, flash.Stage.height);
			textField.wordWrap = true;
			textField.selectable = true;
		#end
	}

	function createHelper():PrintClientHelper
	{
		return new PrintClientHelper();
	}

	function printHeader()
	{
		printLine("MUnit Results");
		printLine(divider);
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
			totalIgnored = totalIgnored.concat(ignored);
			updateLastTestResult();
		}
			
		currentTestClass = className;
		failures = [];
		errors = [];
		ignored = [];
		traces = [];

		if(currentTestClass != null) printNewTest();
	}

	function printNewTest()
	{
		printLine("Class: " + currentTestClass + " ");
	}

	/**
	 * Called when a test passes.
	 *  
	 * @param	result			a passed test result
	 */
	public function addPass(result:TestResult):Void
	{
		print(".");
	}
	
	/**
	 * Called when a test fails.
	 *  
	 * @param	result			a failed test result
	 */
	public function addFail(result:TestResult):Void
	{
		failures.push(Std.string(result.failure));	
		print("!");
	}
	
	/**
	 * Called when a test triggers an unexpected exception.
	 *  
	 * @param	result			an erroneous test result
	 */
	public function addError(result:TestResult):Void
	{
		errors.push(Std.string(result.error));
		print("x");
	}
	
	/**
	 * Called when a test has been ignored.
	 *
	 * @param	result			an ignored test
	 */
	public function addIgnore(result:TestResult):Void
	{
		var ingoredString = result.location;
		if(result.description != null) ingoredString += " - " + result.description;

		ignored.push(ingoredString);
		print(",");
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
		printFinalReports();

		var result = passCount == testCount;
		
		var resultString = result ? "PASSED" : "FAILED";
		resultString += "\n" + "Tests: " + testCount + "  Passed: " + passCount + "  Failed: " + failCount + " Errors: " + errorCount + " Ignored: " + ignoreCount + " Time: " + MathUtil.round(time, 5);

		printFinalResult(resultString);
		helper.setResult(result);

		haxe.Log.trace = originalTrace;
		if (completionHandler != null) completionHandler(this); 
		return output;
	}
	
	function printFinalResult(resultString:String)
	{
		printLine(divider2);
		printLine(resultString);
		printLine("");
		printLine("");
	}

	/**
	* summarises result for currently executing test class
	*/
	function updateLastTestResult()
	{
		printExceptions();
	}

	// We print exceptions captured (failures or errors) after all tests 
	// have completed for a test class.
	function printExceptions():Void
	{
		for(item in traces)
		{
			printLine("TRACE: " + item, 1);
		}
		for(item in errors)
		{
			printLine("ERROR: " + item, 1);
		}

		for(item in failures)
		{
			printLine("FAIL: " + item, 1);
		}
	}


	function printFinalReports()
	{
		printLine("");

		if (includeIgnoredReport && totalIgnored.length > 0)
		{
			printLine("Ignored:");
			printLine(divider);
			for(item in totalIgnored)
			{
				printLine(item);	
			}
			printLine("");
		}
	}

	
	function customTrace(value, ?info:haxe.PosInfos)
	{
		var traceString = info.fileName + "|" + info.lineNumber + "| " + Std.string(value);

		traces.push(traceString);
	}

	function print(value)
	{
		helper.print(value);

		#if flash9
			textField.appendText(value);
			textField.scrollV = textField.maxScrollV;
		#elseif flash
			value = untyped flash.Boot.__string_rec(value, "");
			textField.text += value;
			textField.scroll = textField.maxscroll;
		#end
		output += value;
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

enum PrintLevel
{
	NONE;
	FAILURE;
	ERROR;

}

class PrintClientHelper
{

	public var stringOutput(default, null):String;
	public var htmlOutput(default, null):String;


	public function new()
	{
		stringOutput = "";
		htmlOutput = "";
		#if js

			var div = js.Lib.document.getElementById("haxe:trace");
			
			if (div == null) 
			{
				var positionInfo = ReflectUtil.here();
				var error:String = "MissingElementException: 'haxe:trace' element not found at " + positionInfo.className + "#" + positionInfo.methodName + "(" + positionInfo.lineNumber + ")";
				js.Lib.alert(error);
			}
		#elseif flash

			if(!flash.external.ExternalInterface.available)
			{
				throw new MUnitException("ExternalInterface not available");
			}
		#end
	}

////////////////////// BASIC PRINT API ////////////////
	
	public function print(value:String)
	{
		#if (js || flash)
			addToQueue("munitPrint", [value]);
			return;
		#elseif neko
			neko.Lib.print(value);
		#elseif cpp
			cpp.Lib.print(value);
		#elseif php
			php.Lib.print(value);
		#end

		stringOutput += value;
	}

	public function printLine(value:String)
	{
		if(value == "") value = " ";
		#if (js || flash)
			addToQueue("munitPrintLine", [value]);
		#else
			print("\n" + value);
		#end
		
	}

//////////// HTML PRINT API /////////////

	public function trace(value:String)
	{
		addToQueue("munitTrace", [value]);
	}

	public function setResult(value:Bool)
	{
		addToQueue("setResult",[value]);
		addToQueue("setResultBackground",[value]);
	}

	//////////// INTERNAL METHODS /////////////

	function addToQueue(method:String, ?args:Array<Dynamic>):Bool
	{
		#if (!js && !flash)
			//throw new MUnitException("Cannot call from non JS/Flash targets");
			return false;
		#end

		var jsCode = convertToJavaScript(method, args);

		#if js	
			
			return js.Lib.eval(jsCode);
		#elseif flash
			return flash.external.ExternalInterface.call(jsCode);
		#end

		return false;
	}

	function convertToJavaScript(method:String, ?args:Array<Dynamic>):String
	{
		var htmlArgs:Array<String> = [];

		for(arg in args)
		{
			stringOutput += args;

			var html = serialiseToHTML(Std.string(arg));
			htmlArgs.push(html);
			
			htmlOutput += html;
		}
		var jsCode:String;

		if(htmlArgs == null || htmlArgs.length == 0)
		{
			jsCode = "addToQueue(\"" + method + "\")";
		}
		else
		{
			jsCode = "addToQueue(\"" + method + "\"";

			for(arg in htmlArgs)
			{
				jsCode += ",\"" + arg + "\"";
			}
			jsCode += ")";
		}

		return jsCode;

	}

	function serialiseToHTML(value:Dynamic):String
	{
		

		#if js
		value = untyped js.Boot.__string_rec(value, "");
		#end

		var v:String = StringTools.htmlEscape(value);
		v = v.split("\n").join("<br/>");
		v = v.split(" ").join("&nbsp;");

		return v;
	}
}