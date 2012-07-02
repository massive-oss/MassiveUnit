package massive.munit.report;

import massive.neko.io.File;
import massive.munit.report.ReportFormatter;
import massive.munit.report.ReportType;

/**
Converts result summary data into the teamcity-info.xml format.

This file should be generated in the root directory of the project (.)

	munit report teamcity . -coverage 50
*/
class TeamCityReportFormatter extends ReportFormatterBase
{
	static inline var DEFAULT_FILE_NAME:String = "teamcity-info.xml";

	var statusTexts:Array<String>;
	var statistics:Hash<Float>;
	
	public function new()
	{
		super();
		type = ReportType.teamcity;

	}

	override public function format(files:Array<File>, dest:File, ?minCoverage:Int=0):Bool
	{
		super.format(files, dest, minCoverage);

		statusTexts = [];
		statistics = new Hash();

		serializeTestResults();
		serializeCoverageResults();

		var xml = generateTeamcityXML();

		if(dest.isDirectory)
		{
			var file = dest.resolveFile(DEFAULT_FILE_NAME);
			file.writeString(Std.string(xml));
		}
		else
		{
			dest.writeString(Std.string(xml));
		}

		return result;
	}

	function serializeTestResults()
	{
		var multiPlatform = testResults.length > 1;

		if(testTotals.result == false) result = false;

		var statusText = "";

		if(multiPlatform)
		{
			statusText += "Platforms: " + testResults.length + ", ";
		}

		statusText += "Tests: " + testTotals.count +  ", ";


		statusText += "Failed: ";

		if(multiPlatform &&  testPlatforms.fail > 0)
		{
			statusText += testPlatforms.fail + "(" + testTotals.fail + ")";
		}
		else
		{
			statusText += testTotals.fail;
		}

		statusText += ", Errors: ";

		if(multiPlatform &&  testPlatforms.error > 0)
		{
			statusText += testPlatforms.error  + "(" + testTotals.error + ")";
		}
		else
		{
			statusText += testTotals.error;
		}

		if(testTotals.ignore > 0) 
		{
			statusText += ", Ignored: ";
			if(multiPlatform &&  testPlatforms.ignore > 0)
			{
				statusText += testPlatforms.ignore + "(" + testTotals.ignore + ")";
			}
			else
			{
				statusText += testTotals.ignore;
			}
		}
	
		statusTexts.push(statusText);


		//teamcity statistics
		statistics.set("IgnoredTestCount", testTotals.ignore);
		statistics.set("PassedTestCount", testTotals.pass);
		statistics.set("FailedTestCount", testTotals.fail + testTotals.error);
		statistics.set("ErroredTestCount", testTotals.error);//not supported by TC
	}

	function serializeCoverageResults()
	{
		var coverageStats:Array<CoverageStatistics> = [];

		var coverageStatus = "Coverage: " + coverageTotals.coverage + "%";

		if(Std.int(coverageTotals.coverage) < minCoverage)
		{
			result = false;
			coverageStatus += ", Minimum: " + minCoverage + "%";
		}

		statusTexts.push(coverageStatus);

		statistics.set("Coverage", coverageTotals.coverage);
		statistics.set("CoverageMax", 100);

		addTeamCityCoverageStat(coverageTotals.packages);
		addTeamCityCoverageStat(coverageTotals.files);
		addTeamCityCoverageStat(coverageTotals.classes);
		addTeamCityCoverageStat(coverageTotals.methods);
		addTeamCityCoverageStat(coverageTotals.statements);
		addTeamCityCoverageStat(coverageTotals.branches);
		addTeamCityCoverageStat(coverageTotals.lines);
			
	}

	function addTeamCityCoverageStat(stat:CoverageStatistics)
	{
		var key = stat.key;

		statistics.set("CodeCoverage" + key, stat.percent);
		statistics.set("CodeCoverageAbs" + key + "Covered", stat.count);
		statistics.set("CodeCoverageAbs" + key + "Total", stat.total);
	}


	function generateTeamcityXML():String
	{
		var xml = "<build number=\"{build.number}\">";

		//add summary info
		xml += "\n\t<statusInfo status=\"" +  (result ? "SUCCESS" : "FAILURE") + "\">";
		for(text in statusTexts)
		{
			xml += "\n\t\t <text action=\"append\">" + text + "</text>";
		}
		xml += "\n\t</statusInfo>";

		//add statistics
		var keys:Array<String> = [];

		for(key in statistics.keys())
		{
			keys.push(key);
		}

		keys.sort(sortString);

		for(key in keys)
		{
			xml += "\n\t<statisticValue key=\"" + key + "\" value=\"" + statistics.get(key) + "\"/>";
		}
	
		xml += "\n</build>";

		return xml;


		/*<build number="1.0.{build.number}">
	   <statusInfo status="FAILURE"> <!-- or SUCCESS -->
	      <text action="append"> fitnesse: 45</text>
	      <text action="append"> coverage: 54%</text>
	   </statusInfo>
	    <statisticValue key="chart1Key" value="342"/>
	</build>*/
	}



}
