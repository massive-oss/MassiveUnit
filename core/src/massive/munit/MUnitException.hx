/****
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
* 
****/

package massive.munit;
import haxe.PosInfos;

/**
 * Base exception type for all exceptions raised by munit.
 * 
 * @author Mike Stead
 */
class MUnitException 
{
	/**
	 * The exception type.
	 */
	public var type(default, null):String;
	
	/**
	 * The message describing the exception.
	 */
	public var message(default, null):String;
	
	/**
	 * The pos infos from where the exception was thrown.
	 */
	public var info(default, null):PosInfos;
	
	/**
	 * Class constructor.
	 * 
	 * @param	message			a description of the exception
	 * @param	info			pos infos from where the exception was thrown
	 */
	public function new(message:String, ?info:PosInfos) 
	{
		type = here.className;
		this.message = message;
		this.info = info;
	}
	
	/**
	 * Returns a string representation of this exception.
	 * 
	 * @return a string representation of this exception
	 */
	public function toString():String
	{
		var str:String = type + ": ";
		if (info == null) str += message;
		else str += message + " at " + info.className + "#" + info.methodName + " (" + info.lineNumber + ")";
		return str;
	}
}