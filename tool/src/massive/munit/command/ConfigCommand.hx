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
package massive.munit.command;

import massive.neko.io.File;
import massive.neko.io.FileSys;
import massive.haxe.util.TemplateUtil;

/**
The ConfigCommand provides a number of ways to create and modify the configuration file (.munit) for a project.
Either from command line args, manual input into the console, or from an external file.
*/
class ConfigCommand extends MUnitCommand
{
	static inline var DEFAULT_SRC:String = "test";
	static inline var DEFAULT_BIN:String = "build";
	static inline var DEFAULT_REPORT:String = "report";
	static inline var DEFAULT_CLASSPATHS:String = "src";
	static inline var DEFAULT_HXML:String = "test.hxml";
		

	var file:File;//external file


	var useDefaultsIfMissing:Bool;
	var useConsoleInput:Bool;

	var src:File;
	var bin:File;
	var report:File;
	var hxml:File;
	var classPaths:Array<File>;

	var resources:File;
	var templates:File;

	var coveragePackages:Array<String>;
	var coverageIgnoredClasses:Array<String>;

	public function new():Void
	{
		super();
		useDefaultsIfMissing = false;
		useConsoleInput = false;
		addPostRequisite(GenerateCommand);
	}

	override public function initialise():Void
	{

		if(hasDeleteArg())
		{
			config.remove();
			exit(0);
		}
		else if(hasDefaultArg())
		{
			useDefaultsIfMissing = true;
		}
		else if(hasFileArg())
		{
			useDefaultsIfMissing = true;
			var filePath:String = console.getOption("file");
			parseFromFile(filePath);
		}
		else if(hasInlineArgs())
		{
			useDefaultsIfMissing = true;
			parseInlineArgs();
		}
		else if(hasResetArg())
		{
			config.remove();
			parseFromConsole();
		}
		else
		{
			parseFromConsole();
		}
	}

	override public function execute():Void
	{
		if(useDefaultsIfMissing)
		{
			setDefaultValuesForMissingProperties();
		}

		writeHxmlToFile(hxml);

		if(!config.exists)
		{
			config.createDefault(src, bin, report, hxml,classPaths,resources,templates,coveragePackages,coverageIgnoredClasses);
		}
		else
		{
			if(src != null) config.updateSrc(src);
			if(bin != null) config.updateBin(bin);
			if(report != null) config.updateReport(report);
			if(classPaths != null) config.updateClassPaths(classPaths);	
			if(hxml != null) config.updateHxml(hxml);
			if(resources != null) config.updateResources(resources);
			if(templates != null) config.updateTemplates(templates);
			if(coveragePackages != null) config.updateCoveragePackages(coveragePackages);
			if(coverageIgnoredClasses != null) config.updateCoverageIgnoredClasses(coverageIgnoredClasses);
		}
	}

	function hasDeleteArg():Bool
	{
		if(console.getOption("delete") != null) return true;
		return false;
	}

	function hasFileArg():Bool
	{
		if(console.getOption("file") != null) return true;
		return false;
	}

	function hasResetArg():Bool
	{
		if(console.getOption("reset") != null) return true;
		return false;
	}

	function hasDefaultArg():Bool
	{
		if(console.getOption("default") != null) return true;
		return false;
	}

	function hasInlineArgs():Bool
	{
		if(console.getOption("src") != null) return true;
		if(console.getOption("bin") != null) return true;
		if(console.getOption("report") != null) return true;
		if(console.getOption("hxml") != null) return true;
		if(console.getOption("classPaths") != null) return true;
		if(console.getOption("resources") != null) return true;
		if(console.getOption("templates") != null) return true;
		if(console.getOption("coveragePackages") != null) return true;
		if(console.getOption("coverageIgnoredClasses") != null) return true;
		return false;
	}
	
	function parseInlineArgs()
	{
		var srcArg = console.getOption("src");
		var binArg = console.getOption("bin");
		var reportArg = console.getOption("report");
		var classPathsArg = console.getOption("classPaths");
		var hxmlArg = console.getOption("hxml");

		var resourcesArg = console.getOption("resources");
		var templatesArg = console.getOption("templates");

		var coveragePackagesArg = console.getOption("coveragePackages");
		var coverageIgnoredClassesArg = console.getOption("coverageIgnoredClasses");

		src = convertToDirectory(srcArg, DEFAULT_SRC, "src");
		bin = convertToDirectory(binArg, DEFAULT_BIN, "build");
		report = convertToDirectory(reportArg, DEFAULT_REPORT, "report");
		classPaths = convertToDirectoryList(classPathsArg, DEFAULT_CLASSPATHS, "class");
		hxml = convertToFile(hxmlArg, DEFAULT_HXML, "hxml");

		resources = convertToDirectory(resourcesArg, null, "resources");
		templates = convertToDirectory(templatesArg, null, "templates");

		coveragePackages = coveragePackagesArg != null ?  coveragePackagesArg.split(",") : null;
		coverageIgnoredClasses = coverageIgnoredClassesArg != null ?  coverageIgnoredClassesArg.split(",") : null;
	}


	function parseFromConsole()
	{
		if(config.exists)
		{
			print("Current munit settings\n--------------------");
			print(config.toString());
			print("--------------------");
			print("Please use '-reset' to overwrite all existing values\n");
		}
		else
		{
			print("Configure munit project settings\n--------------------");
		}

		if(config.src == null)
		{
			var arg = console.getNextArg("test src dir (defaults to '" + DEFAULT_SRC + "')");
			src = convertToDirectory(arg, DEFAULT_SRC, "src");
		}

		if(config.bin == null)
		{
			var arg = console.getNextArg("output build dir (defaults to '" + DEFAULT_BIN + "')");	
			bin = convertToDirectory(arg, DEFAULT_BIN, "build");
		}

		if(config.report == null)
		{
			var arg = console.getNextArg("report dir (defaults to '" + DEFAULT_REPORT + "')");
			report = convertToDirectory(arg, DEFAULT_REPORT, "report");
		}

		if(config.classPaths == null || config.classPaths.length == 0)
		{
			var arg = console.getNextArg("target class paths (comma delimitered, defaults to '" + DEFAULT_CLASSPATHS + "')");
			classPaths = convertToDirectoryList(arg, DEFAULT_CLASSPATHS, "class");
		}

		if(config.hxml == null)
		{
			var arg = console.getNextArg("hxml file (defaults to '" + DEFAULT_HXML + "')");
			hxml = convertToFile(arg, DEFAULT_HXML, "hxml");
		}

		if(config.resources == null)
		{
			var arg = console.getNextArg("resources dir (optional, defaults to '" + null + "')");
			resources = convertToDirectory(arg, null, "resources");
		}

		if(config.templates == null)
		{
			var arg = console.getNextArg("templates dir (optional, defaults to '" + null + "')");
			templates = convertToDirectory(arg, null, "templates");
		}

		if(config.coveragePackages == null)
		{
			var arg = console.getNextArg("coverage packages (optional, defaults to '" + null + "')");
			coveragePackages = arg != null ?  arg.split(",") : null;
		}

		if(config.coverageIgnoredClasses == null)
		{
			var arg = console.getNextArg("coverage ignored classes (optional, defaults to '" + null + "')");
			coverageIgnoredClasses = arg != null ?  arg.split(",") : null;
		}
	}

	function setDefaultValuesForMissingProperties()
	{
		var srcArg = DEFAULT_SRC;
		var binArg = DEFAULT_BIN;
		var reportArg = DEFAULT_REPORT;
		var classPathsArg = DEFAULT_CLASSPATHS;
		var hxmlArg = DEFAULT_HXML;
		
		if(src == null) src = convertToDirectory(srcArg, DEFAULT_SRC, "src");
		if(bin == null) bin = convertToDirectory(binArg, DEFAULT_BIN, "build");
		if(report == null) report = convertToDirectory(reportArg, DEFAULT_REPORT, "report");
		if(classPaths == null) classPaths = convertToDirectoryList(classPathsArg, DEFAULT_CLASSPATHS, "class");
		if(hxml == null) hxml = convertToFile(hxmlArg, DEFAULT_HXML, "hxml");
	}

	///////////


	function parseFromFile(filePath:String)
	{
		if(filePath == "true" || filePath == "")
		{
			error("Invalid argument. '-file' must be followed by a valid file path");
		}	
		
		file = File.create(filePath, config.dir);	
		
		var label = "file";
		if(file == null) error("invaid " + label + " path: " + filePath);
		if(file.isDirectory) error(label + "path should not be a directory: " + filePath);
		if(!file.exists)
		{
			error("invaid file path " + filePath);
		}

		var tempConfig = new Config(config.dir, config.currentVersion);
		tempConfig.load(file);

		src = tempConfig.src;
		bin = tempConfig.bin;
		report = tempConfig.report;
		hxml = tempConfig.hxml;
		classPaths = tempConfig.classPaths.concat([]);
		resources = tempConfig.resources;
		templates = tempConfig.templates;
		coveragePackages = tempConfig.coveragePackages;
		coverageIgnoredClasses = tempConfig.coverageIgnoredClasses;
	}


	
	function writeHxmlToFile(file:File, ?overwrite:Bool=false):Bool
	{
		if(file == null) return false;
		if(file.exists && !overwrite) return false;

		var src:String = src != null ? config.dir.getRelativePath(src) + "" : "";
		var bin:String = bin != null ? config.dir.getRelativePath(bin) + "": "";

		var clsPaths:Array<String> = [];

		for(path in classPaths)
		{
			clsPaths.push(config.dir.getRelativePath(path));
		}

		var content = TemplateUtil.getTemplate("test-hxml", {src:src, bin:bin, classPaths:clsPaths});
		file.writeString(content, true);
		return true;
		
	}

	///// utilities


	function convertToDirectory(arg:String, defaultValue:String, label:String):File
	{
		if(arg == null) arg = defaultValue;
		if(arg == null) return null;

		var file = File.create(arg, config.dir);

		if(file == null) error("invaid " + label + " path: " + arg);
		if(!file.exists) file.createDirectory();
		if(!file.isDirectory) error(label + "path is not a valid directory: " + arg);

		return file;
	}

	function convertToFile(arg:String, defaultValue:String, label:String):File
	{
		if(arg == null) arg = defaultValue;
		var file = File.create(arg, config.dir);
		if(file == null) error("invaid " + label + " path: " + arg);
		if(file.isDirectory) error(label + "path should not be a directory: " + arg);

		return file;
	}

	function convertToDirectoryList(arg:String, defaultValue:String, label:String):Array<File>
	{
		if(arg == null) arg = defaultValue;
		
		var paths = arg.split(",");
		
		if(paths == null) error("invaid target class paths: " + paths);

		var files:Array<File> = [];
		for(path in paths)
		{
			var file = File.create(path, config.dir);
			if(file == null) error("invaid " + label + " path: " + path);
			if(!file.exists) file.createDirectory();
			if(!file.isDirectory) error(label + "path is not a valid directory: " + path);
			files.push(file);
		}

		return files;
	}
}
