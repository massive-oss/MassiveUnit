/****
* Copyright 2012 Massive Interactive. All rights reserved.
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

class AbstractTestResultClient implements IAdvancedTestResultClient, implements ICoverageTestResultClient
{
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

	/*
	* String representation of print output
	*/
	public var output(get_output, null):String;
	function get_output():String
	{
		return output;
	}

	var passCount:Int;
	var failCount:Int;
	var errorCount:Int;
	var ignoreCount:Int;
	
	var currentTestClass:String;	
	var currentClassResults:Array<TestResult>;


	var currentCoverageResult:CoverageResult;
	
	static var traces:Array<String>;
	
	var totalResults:Array<TestResult>;

	var totalCoveragePercent:Float;
	var totalCoverageReport:String;
	var totalCoverageResults:Array<CoverageResult>;

	var originalTrace:Dynamic;

	var finalResult:Bool;

	public function new()
	{
		init();
	}

	function init():Void
	{
		currentTestClass = null;

		currentClassResults = [];
		traces = [];

		passCount = 0;
		failCount = 0;
		errorCount = 0;
		ignoreCount = 0;

		currentCoverageResult = null;

	
		totalResults = [];
		totalCoveragePercent = 0;
		totalCoverageReport = null;
		totalCoverageResults = null;
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
			finalizeTestClass();
		}
			
		currentTestClass = className;
		if(currentTestClass != null) initializeTestClass();
	}

	/**
	 * Called when a test passes.
	 *  
	 * @param	result			a passed test result
	 */
	public function addPass(result:TestResult):Void
	{
		passCount ++;
		updateTestClass(result);
	}
	
	/**
	 * Called when a test fails.
	 *  
	 * @param	result			a failed test result
	 */
	public function addFail(result:TestResult):Void
	{
		failCount ++;
		updateTestClass(result);
	}
	
	/**
	 * Called when a test triggers an unexpected exception.
	 *  
	 * @param	result			an erroneous test result
	 */
	public function addError(result:TestResult):Void
	{
		errorCount ++;
		updateTestClass(result);
	}

	/**
	 * Called when a test has been ignored.
	 *
	 * @param	result			an ignored test
	 */
	public function addIgnore(result:TestResult):Void
	{
		ignoreCount ++;
		updateTestClass(result);
	}

	public function setCurrentTestClassCoverage(result:CoverageResult):Void
	{
		currentCoverageResult = result;

	}

	////// FINAL REPORTS //////
	public function reportFinalCoverage(?percent:Float=0, missingCoverageResults:Array<CoverageResult>, summary:String,
		?classBreakdown:String=null,
		?packageBreakdown:String=null,
		?executionFrequency:String=null
	):Void
	{
		totalCoveragePercent = percent;
		totalCoverageResults = missingCoverageResults;
		totalCoverageReport = summary;
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
		finalResult = passCount == testCount;

		printReports();

		printFinalStatistics(finalResult, testCount, passCount, failCount, errorCount, ignoreCount, time);
		
		printOverallResult(finalResult);
		
		haxe.Log.trace = originalTrace;
		if (completionHandler != null) completionHandler(this); 
		return output;
	}


	////// TEST CLASS LIFECYCLE //////

	/**
	* Called when a new test class is about to execute tests
	*/
	function initializeTestClass()
	{
		currentClassResults = [];
		traces = [];
		passCount = 0;
		failCount = 0;
		errorCount = 0;
		ignoreCount = 0;
	}

	/**
	* Called after every test has executed
	*/
	function updateTestClass(result:TestResult)
	{
		currentClassResults.push(result);
		totalResults.push(result);
	}

	/**
	* Called when a test class has completed executing all tests
	*/
	function finalizeTestClass()
	{
		currentClassResults.sort(sortTestResults);
	}


	////// FINAL REPORTS //////

	/**
	* Override to print any additional reports (e.g. overall coverage)
	*/
	function printReports()
	{
		
	}

	/**
	* Override to print final summary 
	*/
	function printFinalStatistics(result:Bool, testCount:Int, passCount:Int, failCount:Int, errorCount:Int, ignoreCount:Int, time:Float)
	{
		
	}

	function printOverallResult(result:Bool)
	{
		
	}

	///////

	function addTrace(value:Dynamic, ?info:haxe.PosInfos)
	{
		var traceString = info.fileName + "|" + info.lineNumber + "| " + Std.string(value);
		traces.push(traceString);
	}

	/**
	* returns the current class trace statements
	*/
	function getTraces():Array<String>
	{
		return traces.concat([]);
	}

	function sortTestResults(a:TestResult, b:TestResult):Int
	{
		var aInt:Int = switch(a.type)
		{
			case ERROR: 2;
			case FAIL: 1;
			case IGNORE: 0;
			case PASS: -1;
			default:-2;
		}

		var bInt:Int = switch(b.type)
		{
			case ERROR: 2;
			case FAIL: 1;
			case IGNORE: 0;
			case PASS: -1;
			default:-2;
		}
		
		return aInt - bInt;
	}
}
