/****
* Copyright 2012 Massive Interactive. All rights reserved.
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
****/

package massive.munit;
import haxe.PosInfos;
import massive.haxe.util.ReflectUtil;
import haxe.Stack;

/**
 * Exception thrown when a test triggers an exception in code which was not captured.
 * 
 * @author Mike Stead
 */
class UnhandledException extends MUnitException
{
	/**
	 * @param source	exception which went unhandled
     * @param location 	test location which triggered exception
	 */
	public function new(source:Dynamic, testLocation:String) 
	{
		super(source.toString() + formatLocation(source, testLocation), null);
		type = ReflectUtil.here().className;
	}
	
	function formatLocation(source:Dynamic, testLocation:String):String
	{
		var stackTrace = " at " + testLocation;

		var stack = getStackTrace(source);

		if (stack !=  "")
			stackTrace += " " + stack.substr(1); // remove first "\t"

		return stackTrace;
	}
	
	function getStackTrace(source:Dynamic):String
	{
		var s = "";
		#if (flash && !flash8)
			if (Std.is(source, flash.errors.Error))
			{
				if(flash.system.Capabilities.isDebugger)
				{
					var lines = source.getStackTrace().split("\n");
					lines.shift(); // remove repeated error name
					s = lines.join("\n");
				}
			}
		#end
		if (s == "")
		{
			var stack:Array<haxe.StackItem> = Stack.exceptionStack();
			while (stack.length > 0)
			{
				switch(stack.shift()) 
				{
	         		case FilePos(item, file, line): s += "\tat " + file + " (" + line + ")\n";
	         		case Module(module):
	         		case Method(classname, method): s += "\tat " + classname + "#" + method + "\n";
	         		case Lambda(v):
	         		case CFunction:
	            }
	        }
		}
        return s;
	}
}
