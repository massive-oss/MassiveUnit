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
 * Tests: 5  Passed: 5  Failed: 0 Errors: 0 Time: 0.202
 * ==============================
 * </pre>
 * 
 * @author Mike Stead
 */
class PrintClient implements ITestResultClient
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
	private function get_completeHandler():ITestResultClient -> Void 
	{
		return completionHandler;
	}
	private function set_completeHandler(value:ITestResultClient -> Void):ITestResultClient -> Void
	{
		return completionHandler = value;
	}
	
	/**
	 * Newline delimiter. Defaults to '\n' for all platforms except 'js' where it defaults to '<br/>'.
	 * 
	 * <p>
	 * Should be set before the client is passed to a test runner.
	 * </p>
	 */
	public var newline:String;
	
	private var failures:String;
	private var errors:String;
	private var output:String;
	private var currentTestClass:String;
	private var originalTrace:Dynamic;
	
	#if flash9
		private var textField:flash.text.TextField;
	#elseif flash
		private var textField:flash.TextField;
	#elseif js
		private var textArea:Dynamic;
	#end

	/**
	 * Class constructor.
	 */
	public function new()
	{
		id = DEFAULT_ID;
		init();
		print("MUnit Results" + newline);
		print("------------------------------" + newline);
	}
	
	private function init():Void
	{
		originalTrace = haxe.Log.trace;
		haxe.Log.trace = customTrace;
		output = "";
		failures = "";
		errors = "";
		currentTestClass = "";
		newline = "\n";

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
		#elseif js
			textArea = js.Lib.document.getElementById("haxe:trace");
			if (textArea == null) 
			{
				var positionInfo = ReflectUtil.here();
				var error:String = "MissingElementException: 'haxe:trace' element not found at " + positionInfo.className + "#" + positionInfo.methodName + "(" + positionInfo.lineNumber + ")";
				js.Lib.alert(error);
			}
		#end
	}
	
	/**
	 * Called when a test passes.
	 *  
	 * @param	result			a passed test result
	 */
	public function addPass(result:TestResult):Void
	{
		checkForNewTestClass(result);
		print(".");
	}
	
	/**
	 * Called when a test fails.
	 *  
	 * @param	result			a failed test result
	 */
	public function addFail(result:TestResult):Void
	{
		checkForNewTestClass(result);
		failures += newline + result.failure;		
	}
	
	/**
	 * Called when a test triggers an unexpected exception.
	 *  
	 * @param	result			an erroneous test result
	 */
	public function addError(result:TestResult):Void
	{
		checkForNewTestClass(result);
		errors += newline + result.error;
	}
	
	/**
	 * Called when all tests are complete.
	 *  
	 * @param	testCount		total number of tests run
	 * @param	passCount		total number of tests which passed
	 * @param	failCount		total number of tests which failed
	 * @param	errorCount		total number of tests which were erroneous
	 * @param	time			number of milliseconds taken for all tests to be executed
	 * @return	collated test result data
	 */
	public function reportFinalStatistics(testCount:Int, passCount:Int, failCount:Int, errorCount:Int, time:Float):Dynamic
	{
		printExceptions();
		print(newline + newline);
		print((passCount == testCount) ? "PASSED" : "FAILED");
		print(newline + "Tests: " + testCount + "  Passed: " + passCount + "  Failed: " + failCount + " Errors: " + errorCount + " Time: " + MathUtil.round(time, 5) + newline);
		print("==============================" + newline);
		haxe.Log.trace = originalTrace;
		if (completionHandler != null) completionHandler(this); 
		return output;
	}
	
	private function checkForNewTestClass(result:TestResult):Void
	{
		if (result.className != currentTestClass)
		{
			printExceptions();
			currentTestClass = result.className;
			print(newline + "Class: " + currentTestClass + " ");
		}
	}
	
	// We print exceptions captured (failures or errors) after all tests 
	// have completed for a test class.
	private function printExceptions():Void
	{
		if (errors != "") 
		{
			print(errors + newline);
			errors = "";
		}
		if (failures != "")
		{
			print(failures + newline);
			failures = "";
		}
	}
	
	private function print(value:Dynamic):Void
	{
		#if flash9
			textField.appendText(value);
			textField.scrollV = textField.maxScrollV;
		#elseif flash
			value = untyped flash.Boot.__string_rec(value, "");
			textField.text += value;
			textField.scroll = textField.maxscroll;
		#elseif js
			value = untyped js.Boot.__string_rec(value, "");
			var v:String = StringTools.htmlEscape(value);
			v = v.split(newline).join("<br/>");
			if (textArea != null) textArea.innerHTML += v;
		#elseif neko
			neko.Lib.print(value);
		#elseif cpp
			cpp.Lib.print(value);
		#elseif php
			php.Lib.print(value);
		#end
		
		output += value;
	}

	private function customTrace(value, ?info:haxe.PosInfos)
	{
		print("TRACE: " + info.fileName + "|" + info.lineNumber + "| " + Std.string(value) + newline);
	}
}