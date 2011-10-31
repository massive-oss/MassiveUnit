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

class ConfigCommand extends MUnitCommand
{
	var src:File;
	var bin:File;
	var report:File;
	var hxml:File;
	var classPaths:Array<File>;

	public function new():Void
	{
		super();
		addPostRequisite(GenerateCommand);
	}

	override public function initialise():Void
	{
		var del:String = console.getOption("delete");
		
		if(del != null)
		{
			config.remove();
			exit(0);
		}
		
		var reset:Bool = console.getOption("reset") != null;
		
		if(reset)
		{
			config.remove();
		}
		else if(config.exists)
		{
			print("Current munit settings\n--------------------");
			print(config.toString());
			print("--------------------");
			print("Please use '-reset' to overwrite all existing values\n");
		}
		
		if(reset || config.src == null)
		{
			configureTestSrcDirectory();
		}

		if(reset || config.bin == null)
		{
			configureBuildDirectory();
		}

		if(reset || config.report == null)
		{
			configureReportDirectory();
		}

		if(reset || config.classPaths == null)
		{
			configureClassPaths();
		}

		if(reset || config.hxml == null)
		{
			configureHxml();
		}
	}

	override public function execute():Void
	{
		if(!config.exists)
		{
			config.createDefault(src, bin, report, hxml,classPaths);
		}
		else
		{
			if(src != null) config.updateSrc(src);
			if(bin != null) config.updateBin(bin);
			if(report != null) config.updateReport(report);
			if(hxml != null) config.updateHxml(hxml);
			if(classPaths != null) config.updateClassPaths(classPaths);	
		}
	}

	function configureTestSrcDirectory()
	{
		var arg = console.getNextArg("test src dir (defaults to 'test')");
		
		if(arg == null) arg = "test";
		
		src = File.create(arg, config.dir);
		
		if(src == null) throw "invaid src path" + arg;
		if(!src.exists) src.createDirectory();
		if(!src.isDirectory) throw "src path is not a valid directory " + arg;
	}

	function configureBuildDirectory()
	{
		var arg = console.getNextArg("output build dir (defaults to 'build')");
		
		if(arg == null) arg = "build";
		
		bin = File.create(arg, config.dir);
		
		if(bin == null) throw "invaid output path " + arg;
		if(!bin.exists) bin.createDirectory();
		if(!bin.isDirectory) throw "output path is not a valid directory " + arg;
	}

	function configureReportDirectory()
	{
		var arg = console.getNextArg("report dir (defaults to 'report')");
		
		if(arg == null) arg = "report";
		
		report = File.create(arg, config.dir);
		
		if(report == null) throw "invaid report path " + arg;
		if(!report.exists) report.createDirectory();
		if(!report.isDirectory) throw "report path is not a valid directory " + arg;
	}

	function configureClassPaths()
	{
		var arg = console.getNextArg("target class paths (comma delimitered, defaults to 'src')");
		
		if(arg == null) arg = "src";
		
		var paths = arg.split(",");

		if(paths == null) throw "invaid target class paths" + paths;

		classPaths = [];
		for(path in paths)
		{
			var file = File.create(path, config.dir);
			if(!file.exists) file.createDirectory();
			if(!file.isDirectory) throw "class path is not a valid directory " + path;

			classPaths.push(file);
		}
	}

	function configureHxml()
	{
		var arg = console.getNextArg("hxml file (defaults to test.hxml)");
		
		if (arg == null) arg = "test.hxml";
		
		hxml = File.create(arg, config.dir);
		
		if(hxml == null) throw "invaid hxml path" + arg;
		if(hxml.isDirectory) throw "hxml path is a directory " + arg;

		if(!hxml.exists)
		{
			var src:String = src != null ? config.dir.getRelativePath(src) + "" : "";
			var bin:String = bin != null ? config.dir.getRelativePath(bin) + "": "";

			var clsPaths:Array<String> = [];
			for(path in classPaths)
			{
				clsPaths.push(config.dir.getRelativePath(path));
			}

			var content = TemplateUtil.getTemplate("test-hxml", {src:src, bin:bin, classPaths:clsPaths});
			hxml.writeString(content, true);
		}
	}


}
