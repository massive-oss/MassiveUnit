package massive.munit.client;

import massive.munit.util.MathUtil;

class RichPrintClientHelper extends PrintClientHelper
{
	public function new()
	{
		super();
	}

	override public function setResult(value:Bool)
	{
		addToQueue("setResult",[value]);
	}

	///////// TEST APIS /////////

	public function createTestClass(currentTestClass:String)
	{
		addToQueue("createTestClass",[currentTestClass]);	
		updateTestSummary("Class: " + currentTestClass + " ");
	}

	public function addTest(result:TestResult)
	{
		var value = serializeTestResult(result);

		if(result.error != null)
		{
			updateTestSummary("!");
			addToQueue("addTestError", [value]);
		}
		else if(result.failure != null)
		{
			updateTestSummary("!");
			addToQueue("addTestFail", [value]);
		}
		else if(result.ignore)
		{
			updateTestSummary(",");
			addToQueue("addTestIgnore", [value]);
		}
		else if(result.passed)
		{
			updateTestSummary(".");
			//addToQueue("addTestPass", value);
		}
	}

	function serializeTestResult(result:TestResult):String
	{
		var summary = result.name;

		if(result.description != null && result.description != "")
		{
			summary += " - " + result.description + " -";
		}

		summary += " (" + MathUtil.round(result.executionTime, 4) + "s)";

		var str = "";
		if(result.error != null)
		{
			str = "Error: " + summary + "\n" + Std.string(result.error);
		}
		else if(result.failure != null)
		{
			str = "Failure: " + summary +  "\n" + Std.string(result.failure);
		}
		else if(result.ignore)
		{
			str = "Ignore: " + summary;
		}
		else if(result.passed)
		{
			//str = str;
		}

		return str;
	}

	public function updateTestSummary(value:String)
	{
		addToQueue("updateTestSummary", [value]);
	}

	public function addTestCoverageClass(value:String, percent:Float)
	{
		addToQueue("addTestCoverageClass", [value, percent]);
	}

	public function addTestCoverageItem(value:String)
	{
		addToQueue("addTestCoverageItem", [value]);
	}

	public function setTestClassResult(value:TestResultState)
	{
		if(value == null) value = NONE;
		
		var code:Int =
		
		switch(value)
		{
			case PASSED: 0;
			case FAILED: 1;
			case ERROR: 2;
			case WARNING: 3;
			default: -1;
			
		}

		if(code == -1) return;

		addToQueue("setTestClassResult", [code]);
	}

	///////// REPORTS //////////
	
	public function createCoverageReport(value:Float)
	{
		addToQueue("createCoverageReport", [value]);
	}

	public function addMissingCoverageClass(coverageClass:String, percent:Float)
	{
		addToQueue("addMissingCoverageClass", [coverageClass, percent]);
	}

	public function addCoverageSummary(value:String)
	{
		addToQueue("addCoverageSummary", [value]);
	}

	//////////// FINAL RESULTS ////////////

	public function printSummary(value:String)
	{
		addToQueue("printSummary", [value]);
	}

}


enum TestResultState
{
	NONE;
	PASSED;
	FAILED;
	ERROR;
	WARNING;
}