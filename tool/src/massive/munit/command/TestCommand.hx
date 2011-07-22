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

import massive.neko.haxe.HaxeWrapper;
import massive.neko.io.File;
import massive.neko.io.FileSys;
import massive.neko.util.PathUtil;
import massive.munit.Config;
import massive.haxe.log.Log;

class TestCommand extends MUnitCommand
{

	private var hxml:File;
	private var targets:Array<Target>;
	private var targetTypes:Array<TargetType>;

	public function new():Void
	{
		super();
	}

	override public function initialise():Void
	{
		targetTypes = new Array();
		
		if(console.getOption("swf") == "true")
		{
			targetTypes.push(TargetType.swf);
			targetTypes.push(TargetType.swf9);
		}
		if(console.getOption("as2") == "true")	targetTypes.push(TargetType.swf);
		if(console.getOption("as3") == "true") targetTypes.push(TargetType.swf9);
		if(console.getOption("js") == "true") targetTypes.push(TargetType.js);
		if(console.getOption("neko") == "true") targetTypes.push(TargetType.neko);
		
		if(targetTypes.length == 0)
		{
			targetTypes = config.targetTypes.concat([]);
		}

		//hxml
		var hxmlPath =  console.getNextArg();

		if(hxmlPath == null)
		{
			hxml = config.hxml;
			
			if(hxml == null)
			{
				error("Default hxml file path is not set. Please run munit config.");
			}
			if(!hxml.exists)
			{
				error("Default hxml file path does not exist. Please run munit config.");
			}
		}
		else
		{
			hxml = File.create(hxmlPath, console.dir);

			if(!hxml.exists)
			{
				error("Cannot locate hxml file: " + hxmlPath);
			}
		}
		
		//prevent generation from occuring
		var noGen:String  = console.getOption("-nogen");
		
		if(noGen != "true")
		{
			addPreRequisite(GenerateCommand);
		}
		
		//prevent generation from occuring
		var noRun:String  = console.getOption("-norun");
		
		if(noRun != "true")
		{
			addPostRequisite(RunCommand);
		}
	}

	override public function execute():Void
	{
		var contents:String = hxml.readString();		
		var lines:Array<String> = contents.split("\n");
		var target:Target = new Target();
		
		targets = [];
		
		for(line in lines)
		{
			if(line.indexOf("--next") == 0)
			{
				targets.push(target);
				target = new Target();
				continue;
			}
						
			target.hxml += line + "\n";
			
			if(target.type == null)
			{
				for(type in targetTypes)
				{
					var s:String = Std.string(type);
				
					var targetMatcher = new EReg("^-" + s + "\\s+", "");
					if(targetMatcher.match(line)/*line.indexOf("-" + s) == 0*/ && target.type == null)
					{
						target.type = type;
						target.file = File.create(line.substr(s.length + 2), File.current);
					}
				}
			}
		}

		targets.push(target);
		
		for(target in targets)
		{
			if(target.type == null && targetTypes.length < config.targetTypes.length ) continue;
			
			Log.debug("Compile " + target.type + " -- " + target);
			if(HaxeWrapper.compile(target.hxml) > 0)
			{
				error("Error compiling hxml for " + target.type + "\n" + target);
			}	
		}
		
		Log.debug("All targets compiled successfully");
	}
}
