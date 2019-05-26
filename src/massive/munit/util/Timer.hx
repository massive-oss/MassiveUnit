/****
* Copyright 2017 Massive Interactive. All rights reserved.
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

/*
 * Copyright (c) 2005, The haXe Project Contributors
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE HAXE PROJECT CONTRIBUTORS "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE HAXE PROJECT CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 */
package massive.munit.util;

#if ((haxe_ver >= 4.0) && (neko || cpp || java || hl || eval))
import sys.thread.Thread;
#elseif neko
import neko.vm.Thread;
#elseif cpp
import cpp.vm.Thread;
#elseif java
import java.vm.Thread;
#end

#if(cs || python || php || nodejs || hl || eval)
typedef Timer = haxe.Timer;
#else
@:expose('massive.munit.util.Timer')
class Timer 
{
	var id:Null<Int>;

	#if js
	static var arr = new Array<Timer>();
	var timerId:Int;
	#elseif (neko || cpp || java)
	var runThread:Thread;
	#end

	public function new(time_ms:Int)
	{
		#if flash
			var me = this;
			id = untyped __global__["flash.utils.setInterval"](function() { me.run(); },time_ms);
		#elseif js
			id = arr.length;
			arr[id] = this;
			timerId = untyped window.setInterval("massive.munit.util.Timer.arr[" + id + "].run();", time_ms);
		#elseif (neko || cpp || java)
			var me = this;
			runThread = Thread.create(me.runLoop.bind(time_ms));
		#end
	}

	public function stop()
	{
		#if(flash || js)
			if (id == null) return;
		#end
		#if flash
			untyped __global__["flash.utils.clearInterval"](id);
		#elseif js
			untyped window.clearInterval(timerId);
			arr[id] = null;
			if (id > 100 && id == arr.length - 1) 
			{
				// compact array
				var p = id - 1;
				while(p >= 0 && arr[p] == null) p--;
				arr = arr.slice(0, p + 1);
			}
		#elseif (neko || cpp || java)
			run = function() {};
			runThread.sendMessage("stop");
		#end
		id = null;
	}

	public dynamic function run() {}

	#if (neko || cpp || java || hl || eval)
	function runLoop(time_ms:Int)
	{
		var shouldStop = false;
		while(!shouldStop)
		{
			Sys.sleep(time_ms / 1000);
			try
			{
				run();
			}
			catch(ex:Dynamic)
			{
				trace(ex);
			}

			var msg = Thread.readMessage(false);
			if(msg == "stop") shouldStop = true;
		}
	}
	#end

	public static function delay(f:Void->Void, time_ms:Int):Timer
	{
		var t = new Timer(time_ms);
		t.run = function()
		{
			t.stop();
			f();
		};
		return t;
	}

	/**
		Returns a timestamp, in seconds with fractions.
		The value itself might differ depending on platforms, only differences
		between two values make sense.
	**/
	public static function stamp():Float
	{
		return haxe.Timer.stamp();
	}
}
#end