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

package massive.munit;

/**
 * Interface which all test result clients should adhere to.
 * <p>
 * A test result client is responsible for interpreting the results of tests as
 * they are executed by a test runner.
 * </p>
 * 
 * @author Mike Stead
 * @see TestRunner
 */
interface ITestResultClient
{	
	/**
	 * Handler which if present, should be called when the client has completed its processing of the results.
	 */
	var completionHandler(get_completeHandler, set_completeHandler):ITestResultClient -> Void;
	
	/**
	 * The unique identifier for the client.
	 */
	var id(default, null):String;
	
	/**
	 * Called when a test passes.
	 *  
	 * @param	result			a passed test result
	 */
	function addPass(result:TestResult):Void;
	
	/**
	 * Called when a test fails.
	 *  
	 * @param	result			a failed test result
	 */
	function addFail(result:TestResult):Void;
	
	/**
	 * Called when a test triggers an unexpected exception.
	 *  
	 * @param	result			an erroneous test result
	 */
	function addError(result:TestResult):Void;
	
	/**
	 * Called when a test has been ignored.
	 *
	 * @param	result			an ignored test
	 */
	function addIgnore(result:TestResult):Void;
	
	/**
	 * Called when all tests are complete.
	 *  
	 * @param	testCount		total number of tests run
	 * @param	passCount		total number of tests which passed
	 * @param	failCount		total number of tests which failed
	 * @param	errorCount		total number of tests which were erroneous
	 * @param	ignoreCount		total number of ignored tests
	 * @param	time			number of milliseconds taken for all tests to be executed
	 * @return	collated test result data if any
	 */
	function reportFinalStatistics(testCount:Int, passCount:Int, failCount:Int, errorCount:Int, ignoreCount:Int, time:Float):Dynamic;
}

/**
 * Updated Interface which all test result clients should adhere to.
 * <p>
 * A test result client is responsible for interpreting the results of tests as
 * they are executed by a test runner.
 * </p>
 * 
 * @author Dominic De Lorenzo
 * @see TestRunner
 */
interface IAdvancedTestResultClient implements ITestResultClient
{	
	/**
	 * Called before a new test class in run.
	 *
	 * @param	result			a stub test result
	 */
	function setCurrentTestClass(className:String):Void;
}

/**
 * Interface for supporting test coverage
 * 
 * @author Dominic De Lorenzo
 * @see TestRunner
 */
interface ICoverageTestResultClient implements IAdvancedTestResultClient
{	
	/**
	 * Called after all tests have completed for current class
	 *
	 * @param	result			missing class coverage covered by tests
	 */
	function setCurrentTestClassCoverage(result:CoverageResult):Void;

	/**
	 * Called after all test classes have finished
	 *
	 * @param	percent					overall coverage percentage
	 * @param	coverageResults			missing coverage results
	 * @param	summary					high level coverage report
	 * @param	classBreakdown			results per class
 	 * @param	packageBreakdown		results per package
	 * @param	executionFrequency		statement/branch frequency	
	 */
	function reportFinalCoverage(?percent:Float=0, missingCoverageResults:Array<CoverageResult>, summary:String,
		?classBreakdown:String=null,
		?packageBreakdown:String=null,
		?executionFrequency:String=null
	):Void;

}


typedef CoverageResult = 
{
	className:String,
	percent:Float,
	blocks:Array<String>,
}