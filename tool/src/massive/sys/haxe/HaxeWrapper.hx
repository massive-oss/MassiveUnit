/****
* Copyright 2013 Massive Interactive. All rights reserved.
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
* THIS SOFTWARE IS PROVIDED BY MASSIVE INTERACTIVE "AS IS" AND ANY EXPRESS OR IMPLIED
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
* 
****/

package massive.sys.haxe;

import massive.sys.Process;
import sys.FileSystem;
import sys.io.File;
import massive.sys.io.File;
import neko.vm.Thread;

/**
*  This is a simple wrapper for running haxe from within neko
*/
class HaxeWrapper
{
	/*
		Compiles a hxml string using haxe.
		Errors are printed the console.
		@return exit code from haxe compiler - 0 is success, >0 is a fail.
	*/
	static public function compile(hxml:String, ?silent:Bool=false):Int
	{
		var targets = splitHxmlIntoTargets(hxml);
		var exitCode = 0;

		for(target in targets)
		{
			exitCode = compileTarget(target,silent);
			if(exitCode != 0) break;
		}
		return exitCode;
	}
	
	static function compileTarget(hxml:String, ?silent:Bool=false):Int
	{
		var args = splitArguments(hxml);
		printIndented("haxe " + args.join(" "));

		return Process.run("haxe", args, getPrinter(silent));
	}
	
	static function getPrinter(silent:Bool):PrintStream 
	{
		var lineIn = silent 
			? function(line:String) { } 
			: function(line:String) { trace(line); };
		return { out:lineIn, err:lineIn };
	}
	
	static public function splitArguments(hxml:String):Array<String>
	{
		var lines = hxml.split("\n");
		var args:Array<String> = [];
		var reArg = ~/^(-[a-z0-9._-]+) (.*)/i;
		for (line in lines)
		{
			line = StringTools.trim(line);
			if (line.length == 0 || line.charAt(0) == "#") continue;
			if (reArg.match(line))
			{
				args.push(reArg.matched(1));
				args.push(escapeArgument(reArg.matched(2)));
			}
			else args.push(escapeArgument(line));
		}
		return args;
	}	
	
	static function escapeArgument(arg:String) 
	{
		if (arg.length == 0) return arg;
		if (arg.charAt(0) == '"') return arg;
		return arg.split(" ").join("\\ ");
	}

	static function printIndented(str:String, indent:String="   ")
	{
		str = StringTools.trim(str); 

		Sys.println(indent + str);	

		Sys.stdout().flush();
	}
	
	static public function convertHXMLStringToArgs(hxml:String):String
	{
		var lines:Array<String> = hxml.split("\n");
		var result:String = "";
		
		for(line in lines)
		{
			line = StringTools.trim(line);
			
			if(line != "" && line.indexOf("#") != 0)
			{
				if(result != "") result += " ";

				if(line.lastIndexOf(" ") != line.indexOf(" "))
				{
					var parts = line.split(" ");
					result += parts.shift() + " ";
					result += parts.join("\\ ");
				}
				else
				{
					result += line;
				}
				
			}	
		}
		return result;
	}
	
	static public function convertHxmlStringToArray(hxml:String):Array<String>
	{
		var lines = hxml.split("\n");
		var params:Array<String> = [];

		for (line in lines)
		{
			if (line.length > 0 && line.indexOf("#") != 0)
			{
				params.push(line);
			} 
		}
		
		return params;
	}

	static public function splitHxmlIntoTargets(hxml:String):Array<String>
	{
		return hxml.split("\n--next");
	}
	
}
