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
	private var ignored:String;
	private var output(default, null):String;
	private var currentTestClass:String;
	private var originalTrace:Dynamic;
	private var includeIgnoredReport:Bool;


	
	#if flash9
		private var textField:flash.text.TextField;
	#elseif flash
		private var textField:flash.TextField;
	#elseif js
		private var textArea:Dynamic;
	#end


	var helper:PrintClientHelper;	

	public function new(?includeIgnoredReport:Bool = true)
	{
		id = DEFAULT_ID;
		this.includeIgnoredReport = includeIgnoredReport;
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
		ignored = "";
		currentTestClass = null;
		newline = "\n";

		helper = new PrintClientHelper();

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
	/**
	* Classed when test class changes
	*
	* @param className		qualified name of current test class
	*/
	public function setCurrentTestClass(className:String):Void
	{
		if (className != currentTestClass)
		{
			if(currentTestClass != null)
				updateLastTestResult();
			currentTestClass = className;
			print(newline + "Class: " + currentTestClass + " ");
		}
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
		print("!");
		failures += newline + result.failure;		
	}
	
	/**
	 * Called when a test triggers an unexpected exception.
	 *  
	 * @param	result			an erroneous test result
	 */
	public function addError(result:TestResult):Void
	{
		print("!");
		errors += newline + result.error;
	}
	
	/**
	 * Called when a test has been ignored.
	 *
	 * @param	result			an ignored test
	 */
	public function addIgnore(result:TestResult):Void
	{
		print(",");
		if (includeIgnoredReport)
			ignored += newline + result.location + " - " + result.description;
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
		
		print((passCount == testCount) ? "PASSED" : "FAILED");
		print(newline + "Tests: " + testCount + "  Passed: " + passCount + "  Failed: " + failCount + " Errors: " + errorCount + " Ignored: " + ignoreCount + " Time: " + MathUtil.round(time, 5) + newline);
		print("==============================" + newline);
		
		helper.setResult(passCount == testCount);

		haxe.Log.trace = originalTrace;
		if (completionHandler != null) completionHandler(this); 
		return output;
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
		if (errors != "") 
		{
			print(errors + newline, ERROR);
			errors = "";
		}
		if (failures != "")
		{
			print(failures + newline, FAILURE);
			failures = "";
		}
	}


	function printFinalReports()
	{
		print(newline + newline);
		if (includeIgnoredReport && ignored != "")
		{
			print("Ignored:" + newline);
			print("------------------------------");
			print(ignored);
			print(newline + newline);
		}
	}

	function print(value:Dynamic, ?level:PrintLevel=null):Void
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

	function customTrace(value, ?info:haxe.PosInfos)
	{
		print(newline + "TRACE: " + info.fileName + "|" + info.lineNumber + "| " + Std.string(value));
	}
}

enum PrintLevel
{
	NONE;
	FAILURE;
	ERROR;

}