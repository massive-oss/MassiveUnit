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
	 * Called when all tests are complete.
	 *  
	 * @param	testCount		total number of tests run
	 * @param	passCount		total number of tests which passed
	 * @param	failCount		total number of tests which failed
	 * @param	errorCount		total number of tests which were erroneous
	 * @param	time			number of milliseconds taken for all tests to be executed
	 * @return	collated test result data if any
	 */
	function reportFinalStatistics(testCount:Int, passCount:Int, failCount:Int, errorCount:Int, time:Float):Dynamic;
}