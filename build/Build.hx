/*
Copyright (c) 2012 Massive Interactive

Permission is hereby granted, free of charge, to any person obtaining a copy of 
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.
*/

import mtask.target.HaxeLib;
import mtask.target.Neko;

class Build extends mtask.core.BuildBase
{
	public function new()
	{
		super();
	}

	@task function compile()
	{
		mkdir("bin");
		
		msys.FS.cd("core", function(path){
			trace("testing core...");
			msys.Process.run("haxe", ["build.hxml"]);
		});

		msys.FS.cd("tool", function(path){
			trace("building tool...");
			msys.Process.run("haxe", ["build.hxml"]);
		});
	}

	@target function haxelib(t:HaxeLib)
	{
		t.name = build.project.id;
		
		t.version = build.project.version;
		t.versionDescription = "Added support for c++ targets (Haxe 2.09+), Compatible with Haxe 2.10. Added project configurable mcover settings. See CHANGES.txt for full change list.";

		t.url = "http://github.com/massiveinteractive/MassiveUnit";
		t.license.organization = "Massive Interactive";
		t.username = "massive";
		t.description = "A cross platform unit testing framework for Haxe with metadata test markup and tools for generating, compiling and running tests from the command line.";
		
		t.addTag("cross");
		t.addTag("utility");
		t.addTag("unittest");
		t.addTag("testing");
		t.addTag("massive");
		
		t.addDependency("hamcrest");
		t.addDependency("mlib");
		t.addDependency("mcover");

		t.afterCompile = function()
		{
			cp("src/*", t.path);
			cp("bin/munit.n", t.path + "/run.n");
			cp("tool/resource", t.path);
			cp("bin/index.n", t.path);
			cp("bin/haxedoc.xml", t.path);
		}
	}

	@task function test()
	{
		msys.Process.run("haxelib", ["run", "munit", "test", "-neko"]);
	}
	
	@task function release()
	{
		require("clean");
		require("compile");
		require("build haxelib");
	}
}
