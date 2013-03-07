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

import massive.sys.io.File;
import massive.haxe.util.TemplateUtil;
import massive.munit.client.HTTPClient;

class GenerateCommand extends MUnitCommand
{
	private var dir:File;
	private var hxmlOutput:File;
	private var includeHxml:Bool;
	private var testFilter:String;
	
	public function new():Void
	{
		super();
		testFilter = null;
		includeHxml = true;
	}
	
	override public function initialise():Void
	{
		var testSrcPath = console.getNextArg();
		dir = initialiseTestSourceDirectory(testSrcPath);
		
		includeHxml = console.getOption("nohxml") != "true";
		
		if(!includeHxml)
		{
			var hxmlPath  = console.getNextArg();
			hxmlOutput = initialiseHxmlOutputFile(hxmlPath);
		}
	
		
		
		testFilter = console.getOption("-filter");
	}

	
	private function initialiseTestSourceDirectory(?testSrcPath:String=null):File
	{
		var dir:File;
		
		if(testSrcPath == null)
		{
			dir = config.src;
			if(dir == null)
			{
				error("Default test src directory is not set. Please run munit config.");
			}
			
			
			if(!dir.exists)
			{
				error("Default test src directory does not exist (" + config.dir.getRelativePath(dir) + ").\nPlease run munit config or specify a <src> and <hxml> path");
			}
		}
		
		else
		{
			dir = File.create(testSrcPath, console.dir);
			if (!dir.exists)
			{
				try
				{
					dir.createDirectory();
				}
				catch(e:Dynamic)
				{
					error("Could not create test directory: " + e);
				}
			}
		}
		
		return dir;
	}

	
	private function initialiseHxmlOutputFile(?hxmlPath:String=null):File
	{
		var hxmlOutput:File = null;
		
		if(hxmlPath == null) 
		{
			if( config.hxml == null)	error("Default hxml path is not set. Please run munit config or specify a hxml file path.");
			else hxmlOutput =  config.hxml;
		}
		else
		{
			hxmlOutput = File.create(hxmlPath, config.dir); 
		}
		
		
		
		if(hxmlOutput == null || !hxmlOutput.isFile) error("Invalid hxml path " + hxmlPath);
		
		
		return hxmlOutput;
	}
	

	override public function execute():Void
	{
		if(!hasTestMain())
		{
			creatTestMainClass();
			createExampleTestClass();
			
			if(includeHxml) createTestHxmlFile();
		
		}
		
		createTestSuiteClass();
	}
	
	
	private function hasTestMain():Bool
	{
		var testMain:File = dir.resolvePath("TestMain.hx");
		return testMain.exists;
	}

	
	private function creatTestMainClass():Void
	{
		var testMain:File = dir.resolvePath("TestMain.hx");
		var content = TemplateUtil.getTemplate("test-main", {url:HTTPClient.DEFAULT_SERVER_URL});
		testMain.writeString(content, true);
	}
	
	private function createExampleTestClass():Void
	{
		//create an example test class for reference
		var testExample:File = dir.resolvePath("ExampleTest.hx");
		var content = TemplateUtil.getTemplate("test-example");
		testExample.writeString(content, true);
	}
	
	private function createTestHxmlFile():Void
	{
		if(hxmlOutput == null) return;
		if(hxmlOutput.exists) return;
			
		var src:String = config.src != null ? config.dir.getRelativePath(config.src) + "" : "";
		var bin:String = config.bin != null ? config.dir.getRelativePath(config.bin) + "": "";

		//write out stub hxml file
		var content = TemplateUtil.getTemplate("test-hxml", {src:src, bin:bin});
		hxmlOutput.writeString(content, true);
		
	}
	
	
	private function createTestSuiteClass():Void
	{
		var classes:Array<String> = getFilteredClassesInDirectory(dir);
		var content:String = generateTestSuiteClassFromClasses(classes);

		var testSuite:File = dir.resolvePath("TestSuite.hx");
		testSuite.writeString(content, true);
	}	
	
	private function getFilteredClassesInDirectory(dir:File):Array<String>
	{
	
		var files:Array<File> = dir.getRecursiveDirectoryListing(~/.*Test\.hx$/);
	
		var classes:Array<String> = [];
		var clasz:String;

		for(file in files)
		{
			clasz = dir.getRelativePath(file).substr(0, -3);
			clasz = clasz.split("/").join(".");
			if(clasz == "TestMain") continue;
			if(testFilter != null && clasz.indexOf(testFilter) == -1) continue;
			
			classes.push(clasz);
			
		}	
		
		return classes;
	}
	
	private function generateTestSuiteClassFromClasses(classes:Array<String>):String
	{
		var imports:String = "";
		var tests:String = "";
		
		for(clasz in classes)
		{
			imports += "\nimport " + clasz + ";";
			tests += "\n		add(" + clasz + ");";
		}
		
		return TemplateUtil.getTemplate("test-suite", {imports:imports,tests:tests});
	}
	

}
