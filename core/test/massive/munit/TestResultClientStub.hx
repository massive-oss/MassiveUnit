package massive.munit;

/**
 * ...
 * @author Mike Stead
 */

class TestResultClientStub implements ITestResultClient
{
	public static inline var DEFAULT_ID:String = "stub";

	public var id(default, null):String;
	
	public var testCount:Int;
	public var passCount:Int;
	public var failCount:Int;
	public var errorCount:Int;
	public var time:Float;
	
	public var finalTestCount:Int;
	public var finalPassCount:Int;
	public var finalFailCount:Int;
	public var finalErrorCount:Int;


	public var completionHandler(get_completeHandler, set_completeHandler):ITestResultClient -> Void;
	private function get_completeHandler():ITestResultClient -> Void 
	{
		return completionHandler;
	}
	
	private function set_completeHandler(value:ITestResultClient -> Void):ITestResultClient -> Void
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
		time = 0.0;
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

	public function reportFinalStatistics(testCount:Int, passCount:Int, failCount:Int, errorCount:Int, time:Float):Dynamic
	{
		finalTestCount = testCount;
		finalPassCount = passCount;
		finalFailCount = failCount;
		finalErrorCount = errorCount;
		this.time = time;
		if (completionHandler != null) completionHandler(this);
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