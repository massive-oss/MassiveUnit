package massive.munit.report;

import massive.munit.report.ReportType;
import massive.neko.io.File;

/**
Interface for any report formatter.
*/
interface ReportFormatter
{
	/**
	Indication if build was successful
	*/
	var result(default, null):Bool;

	/**
	report formatter type
	*/
	var type(default, null):ReportType;


	/**
	Formats an array of target summary files into a report for the specified format.
	Each concreate ReportFormatter should extend this method to serialize the data accordingly.

	@param files 		array of summary.txt files for each platform
	@param dest 		the output file or directory (defaults to project report dir)
	@param minCoverage 	specify a minimum coverage (0 to 100) for successful build
	*/
	function format(files:Array<File>, dest:File, ?minCoverage:Int=0):Bool;

}

class ReportFormatterBase implements ReportFormatter
{
	/**
	Indication if build was successful
	*/
	public var result(default, null):Bool;

	/**
	report formatter type
	*/
	public var type(default, null):ReportType;

	/**
	Array of summary.txt files for tested platforms
	*/
	var files:Array<File>;

	/**
	destination output directory or file
	*/
	var dest:File;

	/**
	minimum level of coverage required for successful build
	*/
	var minCoverage:Int;

	/**
	indicates summary files have test data
	*/
	var hasTestResults:Bool;


	/**
	indicates summary files have coverage data
	*/
	var hasCoverageResults:Bool;

	/**
	Array of test results for each individual platform
	*/
	var testResults:Array<TestResults>;

	/**
	Aggregate test result count across all platforms
	*/
	var testTotals:TestResults;

	/**
	Number of platforms passed/failed/ignored/etc
	*/
	var testPlatforms:TestResults;


	/**
	Array of coverage results for each individual platform
	*/
	var coverageResults:Array<CoverageResults>;
	
	/**
	Aggregate coverage result count across all platforms.
	Rounds down to the minimum coverage result for each value 
	*/
	var coverageTotals:CoverageResults;

	public function new()
	{

	}

	/**
	Formats an array of target summary files into a report for the specified format.
	Each concreate ReportFormatter should extend this method to serialize the data accordingly.

	@param files 		array of summary.txt files for each platform
	@param dest 		the output file or directory (defaults to project report dir)
	@param minCoverage 	specify a minimum coverage (0 to 100) for successful build
	*/
	public function format(files:Array<File>,  dest:File, ?minCoverage:Int=0):Bool
	{
		result = true;//defaults to true
		this.files = files;
		this.dest = dest;
		this.minCoverage = minCoverage;

		hasTestResults = false;
		hasCoverageResults = false;

		testResults = [];
		coverageResults = [];

		for (file in files)
		{	
			var properties:Array<Property> = [];

			if (file.exists)
			{
				properties = parseProperties(file);
			}

			if (hasTestResults)
			{	
				var tests = parseTestResults(properties);
				testResults.push(tests);
			}

			if (hasCoverageResults)
			{
				var coverage = parseCoverageResults(properties);
				coverageResults.push(coverage);
			}
		}

		calculateTestResultTotals();
		calculateCoverageResultTotals();

		return result;
	}

	/**
	Deserializes properties in a summary.txt file
	
	@param file 	summary file to parse
	@return array of Property name value pairs
	*/
	function parseProperties(file:File):Array<Property>
	{
		var data = file.readString();

		var properties:Array<Property> = [];

		var lines = data.split("\n");
		
		for (line in lines)
		{
			line = StringTools.trim(line);

			if (line == "" || line.indexOf("#") == 0) continue;

			var vals = line.split(":");

			if (vals[0] == "") continue;

			var property:Property = {name:vals[0], value:vals[1]};

			switch(property.name)
			{
				case "result":  hasTestResults = true;
				case "coverage": hasCoverageResults = true;
				default: null;
			}

			properties.push(property);
		}

		return properties;
	}


	/**
	Extracts test result properties into a TestResult object
	@param properties 	name value pairs
	@return TestResults containing count/pass/error/fail/etc
	*/
	function parseTestResults(properties:Array<Property>):TestResults
	{
		var result:TestResults = stubTestResults();

		for (property in properties)
		{
			switch(property.name)
			{
				case "result": result.result = property.value == "true";
				case "count": result.count = Std.parseInt(property.value);
				case "pass": result.pass = Std.parseInt(property.value);
				case "fail": result.fail = Std.parseInt(property.value);
				case "error": result.error = Std.parseInt(property.value);
				case "ignore": result.ignore = Std.parseInt(property.value);
				case "time": 
				{
					var a = property.value.split(".");
					result.time = Std.parseFloat(a[0]) + Std.parseFloat("0." + a[1].substr(0,4));
				}
				default: null;
			}

		}
		return result;
	}

	/**
	Utitlity to create an empty TestResult object
	*/
	function stubTestResults():TestResults
	{
		return  {result:true, count:0, pass:0, fail:0, error:0, ignore:0, time:0.0};
	}

	/**
	Aggrigates all platform test results (test counts, and platform counts)
	*/
	function calculateTestResultTotals()
	{
		testTotals = stubTestResults();
		testPlatforms = stubTestResults();

		for (results in testResults)
		{
			if (results.result == false) testTotals.result = false;

			testTotals.count += results.count;
			testTotals.pass += results.pass;
			testTotals.fail += results.fail;
			testTotals.error += results.error;
			testTotals.ignore += results.ignore;

			if (results.fail > 0) testPlatforms.fail ++;
			if (results.error > 0) testPlatforms.error ++;
			if (results.ignore > 0) testPlatforms.ignore ++;

			if (results.time > testTotals.time) testTotals.time = results.time;
		}

		if(testTotals.fail > 0 || testTotals.error > 0) result = false;
	}

	/**
	Extracts coverage result properties into a CoverageResults object
	
	@param properties 	name value pairs
	@return CoverageResults containing coverage stats.
	*/
	function parseCoverageResults(properties:Array<Property>):CoverageResults
	{
		var results:CoverageResults = stubCoverageResults();
		
		for (property in properties)
		{
			switch(property.name)
			{
				case "coverage": results.coverage = parsePercentage(property.value);
				case "packages": results.packages = parseCoverageStats(property, "P");
				case "files": results.files = parseCoverageStats(property, "F");
				case "classes": results.classes = parseCoverageStats(property, "C");
				case "methods": results.methods = parseCoverageStats(property, "M");
				case "statements": results.statements = parseCoverageStats(property, "B");
				case "branches": results.branches = parseCoverageStats(property, "Z");
				case "lines": results.lines = parseCoverageStats(property, "L");
				default: null;
			}
		}

		return results;

	}


	/**
	Utitlity to create an empty CoverageResults object
	Note: starts coverage percentage at 100
	*/
	function stubCoverageResults():CoverageResults
	{
		var stub = {key:"", name:"", percent:100.0, count:0, total:0};
		return {coverage:100.0, packages:stub, files:stub, classes:stub, methods:stub, statements:stub, branches:stub, lines:stub};
	}

	/**
	Aggrigates all platform coverage results, selecting the smallest coverage result for each result type
	*/
	function calculateCoverageResultTotals()
	{
		var totals = stubCoverageResults();
		totals.coverage = coverageResults.length > 0 ? 100 : 0;

		for (results in coverageResults)
		{
			if (results.coverage < totals.coverage) totals.coverage = results.coverage;

			if (totals.packages == null || totals.packages.percent > results.packages.percent) totals.packages = results.packages;
			if (totals.files == null || totals.files.percent > results.files.percent) totals.files = results.files;
			if (totals.classes == null || totals.classes.percent > results.classes.percent) totals.classes = results.classes;
			if (totals.methods == null || totals.methods.percent > results.methods.percent) totals.methods = results.methods;
			if (totals.statements == null || totals.statements.percent > results.statements.percent) totals.statements = results.statements;
			if (totals.branches == null || totals.branches.percent > results.branches.percent) totals.branches = results.branches;
			if (totals.lines == null || totals.lines.percent > results.lines.percent) totals.lines = results.lines;

		}
		coverageTotals = totals;

	}

	/**
	converts string '12.45%' to '12.45'

	@param percent 	string representation of value
	@return percentage as float (0 - 100)
	*/
	function parsePercentage(percent:String):Float
	{
		var s = percent.substr(0, percent.length-1);
		return Std.parseFloat(s);
	}

	/**
	parses a coverage string of format type:percent%,count/total
	e.g. packages:34.04%,16/47

	@param p 	Propery name/value pair
	@param key 	The type of coverage stat
	@return a CoverageStatistics object based on the property and key
	*/	
	function parseCoverageStats(p:Property, key:String):CoverageStatistics
	{

		var name = p.name.substr(0,1).toUpperCase() + p.name.substr(1, p.name.length-1);//e.g. packages > Packages
		var a:Array<String> = p.value.split(",");
		
		var percent = parsePercentage(a[0]);

		var b:Array<String> = a[1].split("/");

		var count = Std.parseInt(b[0]);
		var total = Std.parseInt(b[1]);

		return {key:key, name:name, percent:percent, count:count, total:total};
	}


	/**
	Simple utility for sorting strings alphabetically
	*/
	function sortString(a : String, b : String) : Int 
    {
        return if ( a < b ) -1 else if ( a > b ) 1 else 0;
    } 

}

typedef Property =
{
	name:String,
	value:String,
}


typedef TestResults = 
{
	result:Bool,
	count:Int,
	pass:Int,
	fail:Int,
	error:Int,
	ignore:Int,
	time:Float,
}


typedef CoverageResults = 
{
	coverage:Float,
	packages:CoverageStatistics,
	files:CoverageStatistics,
	classes:CoverageStatistics,
	methods:CoverageStatistics,
	statements:CoverageStatistics,
	branches:CoverageStatistics,
	lines:CoverageStatistics,
}

typedef CoverageStatistics =
{
	key:String,
	name:String,
	percent:Float,
	count:Int,
	total:Int

}
