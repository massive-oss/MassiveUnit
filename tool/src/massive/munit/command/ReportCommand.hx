package massive.munit.command;

import massive.munit.report.ReportType;
import massive.munit.report.ReportFormatter;
import massive.munit.Config;
import massive.munit.Target;
import massive.sys.io.File;
import massive.haxe.log.Log;

/**
The ReportCommand converts raw report data into a specific format for a 3rd party tool or CI platform
*/
class ReportCommand extends MUnitTargetCommandBase
{
	var reportType:ReportType;
	var minCoverage:Int = 0;
	var reportDir:File;
	var destDir:File;

	override public function initialise()
	{
		reportDir = config.report;

		if (reportDir == null)
			error("Default report directory is not set. Please run munit config.");
		if (!reportDir.exists)
			reportDir.createDirectory();

		getTargetTypes();
		getReportFormatType();
		getDestinationDir();
		getMinCoverage();
	}

	function getTargetTypes()
	{
		//first get from console
		targetTypes = getTargetsFromConsole();
		if (targetTypes.length == 0)
		{
			//look up generated results summary
			var file =  reportDir.resolveFile("test/results.txt");
			if (file.exists)
			{
				var contents = file.readString();
				var lines = contents.split("\n");
				var reg:EReg = new EReg("under (.*) using", "g");
				for(line in lines)
				{ 
					line = StringTools.trim(line);
					if (reg.match(line))
					{
						switch(reg.matched(1))
						{
							case TargetType.js: targetTypes.push(TargetType.js);
							case TargetType.as3: targetTypes.push(TargetType.as3);
							case TargetType.neko: targetTypes.push(TargetType.neko);
							case TargetType.cpp: targetTypes.push(TargetType.cpp);
							case TargetType.java: targetTypes.push(TargetType.java);
							case TargetType.cs: targetTypes.push(TargetType.cs);
						}
					}
				}
			}
		}
		//last option is to get from default target types
		if (targetTypes.length == 0) targetTypes = config.targetTypes.copy();
	}

	function getReportFormatType()
	{
		var format:String = console.getNextArg();
		if (format == null)
		{
			error("Please specify one of the following report types: " + Std.string(Type.allEnums(ReportType)));
		}
		else
		{
			try
			{
				format = StringTools.trim(format);
				reportType = Type.createEnum(ReportType, format.toLowerCase());
			}
			catch(e:Dynamic)
			{
				print("Error: invalid report type: " + format);
				error("Please specify one of the following report types: " + Std.string(Type.allEnums(ReportType)));
			}
		}

		Log.debug("reportType: " + reportType);
	}

	function getDestinationDir()
	{
		var dest:String = console.getNextArg();

		if (dest != null)
		{
			destDir = config.dir.resolveDirectory(dest);

		}
		else
		{
			destDir =  config.report;
		}

		Log.debug("destDir: " + destDir);
	}

	function getMinCoverage()
	{
		var coverage:String = console.getOption("coverage");
		if (coverage != null)
		{
			minCoverage = Std.parseInt(coverage);
			Log.debug("minCoverage " + coverage);
		}
	}

	////// EXECUTION PHASE ////////

	override public function execute()
	{
		var files = getSummaryFiles();
		var formatter = getReportFormatterForType(reportType);
		formatter.format(files, destDir, minCoverage);
	}

	function getSummaryFiles():Array<File>
	{
		var files:Array<File> = [];
		for(target in targetTypes)
		{
			var file = reportDir.resolveFile("test/summary/" + Std.string(target) + "/summary.txt");
			if (!file.exists)
			{
				print("Warning: Report summary file does not exist for target (" + Std.string(target) + "): " + file);
			}
			files.push(file);
		}
		return files;
	}

	function getReportFormatterForType(type:ReportType):ReportFormatter
	{
		return switch(type)
		{
			case teamcity: new massive.munit.report.TeamCityReportFormatter();
			case _: null;
		}
	}
}