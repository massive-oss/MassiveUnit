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
class JUnitReportClient implements ITestResultClient
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
	 * Called when a test passes.
	 *  
	 * @param	result			a passed test result
	 */
	public function addPass(result:TestResult):Void
	{
		checkForNewTestClass(result);
		
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
		checkForNewTestClass(result);

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
		checkForNewTestClass(result);

		suiteErrorCount++;

		testSuiteXML.add("<testcase classname=\"" + result.className + "\" name=\"" + result.name + "\" time=\"" + MathUtil.round(result.executionTime, 5) + "\" >" + newline);
		testSuiteXML.add("<error message=\"" + result.error.message + "\" type=\"" + result.error.type + "\">");
		testSuiteXML.add(result.error);
		testSuiteXML.add("</error>" + newline);
		testSuiteXML.add("</testcase>" + newline);
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
		endTestSuite();
		xml.add("</testsuites>");
		if (completionHandler != null) completionHandler(this);
		return xml.toString();
	}
	
	private function checkForNewTestClass(result:TestResult):Void
	{
		if (result.className != currentTestClass)
		{
			endTestSuite();
			currentTestClass = result.className;
			startTestSuite();
		}
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
