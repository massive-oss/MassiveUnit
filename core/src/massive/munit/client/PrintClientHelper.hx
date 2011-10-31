/****
* Copyright 2011 Massive Interactive. All rights reserved.
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

package massive.munit.client;

import massive.munit.util.MathUtil;
import massive.haxe.util.ReflectUtil;
import massive.munit.TestResult;

import massive.munit.MUnitException;

class PrintClientHelper
{

	public var stringOutput(default, null):String;
	public var htmlOutput(default, null):String;


	public function new()
	{
		stringOutput = "";
		htmlOutput = "";
		#if js

			var div = js.Lib.document.getElementById("haxe:trace");
			
			if (div == null) 
			{
				var positionInfo = ReflectUtil.here();
				var error:String = "MissingElementException: 'haxe:trace' element not found at " + positionInfo.className + "#" + positionInfo.methodName + "(" + positionInfo.lineNumber + ")";
				js.Lib.alert(error);
			}
		#elseif flash

			if(!flash.external.ExternalInterface.available)
			{
				throw new MUnitException("ExternalInterface not available");
			}
		#end
	}

////////////////////// BASIC PRINT API ////////////////
	
	public function print(value:String)
	{
		#if (js || flash)
			addToQueue("munitPrint", [value]);
			return;
		#elseif neko
			neko.Lib.print(value);
		#elseif cpp
			cpp.Lib.print(value);
		#elseif php
			php.Lib.print(value);
		#end

		stringOutput += value;
	}

	public function printLine(value:String)
	{
		#if (js || flash)
			addToQueue("munitPrintLine", [value]);
		#else
			print("\n" + value);
		#end
		
	}

//////////// HTML PRINT API /////////////

	public function trace(value:String)
	{
		addToQueue("munitTrace", [value]);
	}

	public function setResult(value:Bool)
	{
		addToQueue("setResult",[value]);
		addToQueue("setResultBackground",[value]);
	}

	//////////// INTERNAL METHODS /////////////

	function addToQueue(method:String, ?args:Array<Dynamic>):Bool
	{

		#if (!js && !flash)
			//throw new MUnitException("Cannot call from non JS/Flash targets");
			return false;
		#end

		var htmlArgs:Array<String> = [];

		for(arg in args)
		{
			stringOutput += args;

			var html = serialiseToHTML(Std.string(arg));
			htmlArgs.push(html);
			
			htmlOutput += html;
		}
		var jsCode:String;

		if(htmlArgs == null || htmlArgs.length == 0)
		{
			jsCode = "addToQueue(\"" + method + "\")";
		}
		else
		{
			jsCode = "addToQueue(\"" + method + "\"";

			for(arg in htmlArgs)
			{
				jsCode += ",\"" + arg + "\"";
			}
			jsCode += ")";
		}

		#if js	
			
			return js.Lib.eval(jsCode);
		#elseif flash
			return flash.external.ExternalInterface.call(jsCode);
		#end

		return false;
	}

	function serialiseToHTML(value:Dynamic):String
	{
		#if js
		value = untyped js.Boot.__string_rec(value, "");
		#end

		var v:String = StringTools.htmlEscape(value);
		v = v.split("\n").join("<br/>");
		v = v.split(" ").join("&nbsp;");

		return v;
	}
}
