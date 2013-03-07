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
package massive.munit;

import massive.munit.ITestResultClient;

/**
 * ...
 * @author Mike Stead
 */

class TestResultClientStub implements IAdvancedTestResultClient
{
	public static inline var DEFAULT_ID:String = "stub";

	public var id(default, null):String;
	
	public var testCount:Int;
	public var passCount:Int;
	public var failCount:Int;
	public var errorCount:Int;
	public var ignoreCount:Int;
	public var time:Float;
	
	public var finalTestCount:Int;
	public var finalPassCount:Int;
	public var finalFailCount:Int;
	public var finalErrorCount:Int;
	public var finalIgnoreCount:Int;

	public var currentTestClass:String;
	public var testClasses:Array<String>;

	@:isVar
	#if haxe3
	public var completionHandler(get, set):ITestResultClient -> Void;
	#else
	public var completionHandler(get_completionHandler, set_completionHandler):ITestResultClient -> Void;
	#end
	function get_completionHandler():ITestResultClient -> Void 
	{
		return completionHandler;
	}
	
	function set_completionHandler(value:ITestResultClient -> Void):ITestResultClient -> Void
	{
		return completionHandler = value;
	}

	public function new()
	{
		id = DEFAULT_ID;
		testCount = 0;
		passCount = 0;
		failCount = 0;
		errorCount = 0;
		ignoreCount = 0;
		time = 0.0;
		testClasses = [];
	}

	public function setCurrentTestClass(className:String):Void
	{
		if(currentTestClass == className) return;
		
		if(className != null) testClasses.push(className);
		currentTestClass = className;
	}

	public function addPass(result:TestResult):Void
	{
		testCount++;
		passCount++;
	}
	
	public function addFail(result:TestResult):Void
	{
		testCount++;
		failCount++;
	
	}

	public function addError(result:TestResult):Void
	{
		testCount++;
		errorCount++;
	}
	
	public function addIgnore(result:TestResult):Void
	{
		ignoreCount++;
	}

	public function reportFinalStatistics(testCount:Int, passCount:Int, failCount:Int, errorCount:Int, ignoreCount:Int, time:Float):Dynamic
	{
		finalTestCount = testCount;
		finalPassCount = passCount;
		finalFailCount = failCount;
		finalErrorCount = errorCount;
		finalIgnoreCount = ignoreCount;
		this.time = time;
		if (completionHandler != null) 
			completionHandler(this);

		return null;
	}
	
	public function toString():String
	{
		var str = "";
		str += "finalTestCount: " + finalTestCount + "\n";
		str += "testCount: " + testCount + "\n";
		str += "finalPassCount: " + finalPassCount + "\n";
		str += "passCount: " + passCount + "\n";
		str += "finalFailCount: " + finalFailCount + "\n";
		str += "failCount: " + failCount + "\n";
		str += "finalErrorCount: " + finalErrorCount + "\n";
		str += "errorCount: " + errorCount + "\n";
		return str;
	}

}
