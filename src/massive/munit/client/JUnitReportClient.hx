/****
* Copyright 2013 Massive Interactive. All rights reserved.
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
import massive.munit.ITestResultClient;
import massive.munit.TestResult;
import massive.munit.util.MathUtil;
import massive.munit.util.Timer;

/**
 * Generates xml formatted tests results compliant for processing by the JUnitReport 
 * Apache Ant task (http://ant.apache.org/manual/Tasks/junitreport.html).
 * 
 * @author Mike Stead
 */
class JUnitReportClient implements IAdvancedTestResultClient
{
	/**
	 * Default id of this client.
	 */
	public static inline var DEFAULT_ID:String = "junit";

	/**
	 * The unique identifier for the client.
	 */
	public var id(default, null):String;
	
	/**
	 * Handler which if present, is called when the client has completed generating its results.
	 */
	@:isVar
	#if haxe3
	public var completionHandler(get, set):ITestResultClient -> Void;
	#else
	public var completionHandler(get_completionHandler, set_completionHandler):ITestResultClient -> Void;
	#end
	
	private function get_completionHandler():ITestResultClient -> Void 
	{
		return completionHandler;
	}
	private function set_completionHandler(value:ITestResultClient -> Void):ITestResultClient -> Void
	{
		return completionHandler = value;
	}

	/**
	 * Newline delimiter. Defaults to '\n'.
	 * 
	 * <p>
	 * Should be set before the client is passed to a test runner.
	 * </p>
	 */
	public var newline:String;
	
	private var xml:StringBuf;
	private var testSuiteXML:StringBuf;
	private var currentTestClass:String;
	private var suitePassCount:Int;
	private var suiteFailCount:Int;
	private var suiteErrorCount:Int;
	private var suiteExecutionTime:Float;

	/**
	 * Class constructor.
	 */
	public function new()
	{
		id = DEFAULT_ID;
		xml = new StringBuf();
		currentTestClass = "";		
		newline = "\n";
		testSuiteXML = null;
		xml.add("<testsuites>" + newline);
	}
	

	/**
	* Classed when test class changes
	*
	* @param className		qualified name of current test class
	*/
	public function setCurrentTestClass(className:String):Void
	{
		if(currentTestClass == className) return;
		if(currentTestClass != null) endTestSuite();
	
		currentTestClass = className;

		if(currentTestClass != null) startTestSuite();
	}


	/**
	 * Called when a test passes.
	 *  
	 * @param	result			a passed test result
	 */
	public function addPass(result:TestResult):Void
	{
		suitePassCount++;
		
		testSuiteXML.add("<testcase classname=\"" + result.className + "\" name=\"" + result.name + "\" time=\"" + MathUtil.round(result.executionTime, 5) + "\" />" + newline);
	}
	
	/**
	 * Called when a test fails.
	 *  
	 * @param	result			a failed test result
	 */
	public function addFail(result:TestResult):Void
	{
		suiteFailCount++;
		
		testSuiteXML.add( "<testcase classname=\"" + result.className + "\" name=\"" + result.name + "\" time=\"" + MathUtil.round(result.executionTime, 5) + "\" >" + newline);
		testSuiteXML.add("<failure message=\"" + result.failure.message + "\" type=\"" + result.failure.type + "\">");
		testSuiteXML.add(result.failure);
		testSuiteXML.add("</failure>" + newline);
		testSuiteXML.add("</testcase>" + newline);
	}
	
	/**
	 * Called when a test triggers an unexpected exception.
	 *  
	 * @param	result			an erroneous test result
	 */
	public function addError(result:TestResult):Void
	{
		suiteErrorCount++;

		testSuiteXML.add("<testcase classname=\"" + result.className + "\" name=\"" + result.name + "\" time=\"" + MathUtil.round(result.executionTime, 5) + "\" >" + newline);
		testSuiteXML.add("<error message=\"" + result.error.message + "\" type=\"" + result.error.type + "\">");
		testSuiteXML.add(result.error);
		testSuiteXML.add("</error>" + newline);
		testSuiteXML.add("</testcase>" + newline);
	}
	
	/**
	 * Called when a test has been ignored.
	 *
	 * @param	result			an ignored test
	 */
	public function addIgnore(result:TestResult):Void
	{
		// TODO: Looks like the "skipped" element is not in the official junit report schema
		//       so ignoring the reporting of this for now. 
		//       https://issues.apache.org/bugzilla/show_bug.cgi?id=43969
		//
		//       ms 4.9.2011
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

		xml.add("</testsuites>");
		if (completionHandler != null) completionHandler(this);
		return xml.toString();
	}
	
	private function endTestSuite():Void
	{
		if (testSuiteXML == null) return;

		var suiteTestCount:Int = suitePassCount + suiteFailCount + suiteErrorCount;
		suiteExecutionTime = Timer.stamp() - suiteExecutionTime;

		var header:String = "<testsuite errors=\"" + suiteErrorCount + "\" failures=\"" + suiteFailCount + "\" hostname=\"\" name=\"" + currentTestClass + "\" tests=\"" + suiteTestCount + "\" time=\"" +MathUtil.round(suiteExecutionTime, 5) + "\" timestamp=\"" + Date.now() + "\">" + newline;
		var footer:String = "</testsuite>" + newline;

		testSuiteXML.add("<system-out></system-out>" + newline);
		testSuiteXML.add("<system-err></system-err>" + newline);
		
		xml.add(header);
		xml.add(testSuiteXML.toString());
		xml.add(footer);
	}
	
	private function startTestSuite():Void
	{
		suitePassCount = 0;
		suiteFailCount = 0;
		suiteErrorCount = 0;
		suiteExecutionTime = Timer.stamp();
		testSuiteXML = new StringBuf();
	}
}
