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

import haxe.Http;
import massive.munit.ITestResultClient;
import massive.munit.TestResult;
import massive.munit.util.Timer;

#if haxe3
import haxe.ds.StringMap;
#else
private typedef StringMap<T> = Hash<T>
#end

/**
 * Decorates other ITestResultClient's, adding behavior to post test results to a specified url.
 * 
 * @author Mike Stead
 */
class HTTPClient implements IAdvancedTestResultClient
{
	@:extern public inline static var DEFAULT_SERVER_URL:String = "http://localhost:2000";
	/**
	 * Default id of this client.
	 */
	@:extern public inline static var DEFAULT_ID:String = "HTTPClient";

	/**
	 * HTTP header key. Contains id of client the HTTPClient is decorating.
	 */
	@:extern public inline static var CLIENT_HEADER_KEY:String = "munit-clientId";

	/**
	 * HTTP header key. Contains id of platform being tests (flash9,flash,js,neko,cpp,php).
	 */
	@:extern public inline static var PLATFORM_HEADER_KEY:String = "munit-platformId";

	/* Global sequental (FIFO) http request queue */
	private static var queue:Array<URLRequest> = [];
	private static var responsePending:Bool = false;

	/**
	 * The unique identifier for the client.
	 */
	public var id(default, null):String;

	/**
	 * Handler which if present, is called when the client has completed sending the test results to the specificied url. 
	 * This will be called once an HTTP response has been recieved.
	 */
	@:isVar
	#if haxe3
	public var completionHandler(get, set):ITestResultClient -> Void;
	#else
	public var completionHandler(get_completionHandler, set_completionHandler):ITestResultClient -> Void;
	#end
	private function get_completionHandler():ITestResultClient -> Void 
	{
		return completionHandler;
	}
	private function set_completionHandler(value:ITestResultClient -> Void):ITestResultClient -> Void
	{
		return completionHandler = value;
	}

	private var client:ITestResultClient;
	private var url:String;
	private var request:URLRequest;
	private var queueRequest:Bool;

	/**
	 * 
	 * @param	client				the test result client to decorate
	 * @param	url					the url to send test results to
	 * @param	?queueRequest		[optional] whether to add http requests to a global queue. Default is true.
	 * @param	?httpRequest		[optional] a custom http request to use to dispatch the result.
	 */
	public function new(client:ITestResultClient, ?url:String = DEFAULT_SERVER_URL, ?queueRequest:Bool = true) 
	{
		id = DEFAULT_ID;
		this.client = client;
		this.url = url;
		this.queueRequest = queueRequest;
	}

	/**
	* Classed when test class changes
	*
	* @param className		qualified name of current test class
	*/
	public function setCurrentTestClass(className:String):Void
	{
		if(Std.is(client, IAdvancedTestResultClient))
		{
			cast(client, IAdvancedTestResultClient).setCurrentTestClass(className);
		}
	}

	/**
	 * Called when a test passes.
	 *  
	 * @param	result			a passed test result
	 */
	public function addPass(result:TestResult):Void
	{
		client.addPass(result);
	}

	/**
	 * Called when a test fails.
	 *  
	 * @param	result			a failed test result
	 */
	public function addFail(result:TestResult):Void
	{
		client.addFail(result);
	}

	/**
	 * Called when a test triggers an unexpected exception.
	 *  
	 * @param	result			an erroneous test result
	 */
	public function addError(result:TestResult):Void
	{
		client.addError(result);
	}
	
	/**
	 * Called when a test has been ignored.
	 *
	 * @param	result			an ignored test
	 */
	public function addIgnore(result:TestResult):Void
	{
		client.addIgnore(result);	
	}

	/**
	 * Called when all tests are complete.
	 *  
	 * @param	testCount		total number of tests run
	 * @param	passCount		total number of tests which passed
	 * @param	failCount		total number of tests which failed
	 * @param	errorCount		total number of tests which were erroneous
	 * @param	ignoreCount		total number of ignored tests
	 * @param	time			number of milliseconds taken for all tests to be executed
	 * @return	collated test result data if any
	 */
	public function reportFinalStatistics(testCount:Int, passCount:Int, failCount:Int, errorCount:Int, ignoreCount:Int, time:Float):Dynamic
	{
		var result = client.reportFinalStatistics(testCount, passCount, failCount, errorCount, ignoreCount, time);
		sendResult(result);
		return result;
	}

	private function sendResult(result):Void
	{
		request = new URLRequest(url);
		request.setHeader(CLIENT_HEADER_KEY, client.id);
		request.setHeader(PLATFORM_HEADER_KEY, platform());
		request.onData = onData;
		request.onError = onError;
		request.data = result;

		if (queueRequest)
		{
			queue.unshift(request);
			dispatchNextRequest();
		}
		else 
		{
			request.send();
		}
	}

	private function platform():String
	{
		#if (flash8 || flash7 || flash6) return "as2";
		#elseif flash return "as3";
		#elseif js return "js";
		#elseif neko return "neko";
		#elseif cpp return "cpp";
		#elseif php return "php";
		#end
		return "unknown";
	}

	private function onData(data:String):Void
	{
		if (queueRequest)
		{
			responsePending = false;
			dispatchNextRequest();
		}
		if (completionHandler != null)
			completionHandler(this); 
	}

	private function onError(msg:String):Void
	{
		if (queueRequest)
		{
			responsePending = false;
			dispatchNextRequest();
		}
		if (completionHandler != null) 
			completionHandler(this); 
	}

	private static function dispatchNextRequest():Void
	{
		if (responsePending || queue.length == 0) 
			return;
		
		responsePending = true;

		var request = queue.pop();
		request.send();
	}
}

// TODO This is a simple wrapper so we can post data. Should get propper one into mlib.

class URLRequest
{
	public var onData:Dynamic -> Void;
	public var onError:Dynamic ->Void;
	public var data:Dynamic;

	var url:String;
	var headers:StringMap<String>;

	#if (js || neko || cpp)
		public var client:Http;
	#elseif flash9
		public var client:flash.net.URLRequest;
	#elseif flash
		public var client:flash.LoadVars;
	#end


	public function new(url:String)
	{
		this.url = url;
		createClient(url);
		setHeader("Content-Type", "text/plain");
	}

	function createClient(url:String)
	{
		#if (js || neko || cpp)
			client = new Http(url);
		#elseif flash9
			client = new flash.net.URLRequest(url);
		#elseif flash			
			client = new flash.LoadVars();
		#end		
	}

	public function setHeader(name:String, value:String)
	{
		#if (js || neko || cpp)
			client.setHeader(name, value);
		#elseif flash9
			client.requestHeaders.push(new flash.net.URLRequestHeader(name, value));
		#elseif flash
			client.addRequestHeader(name, value);
		#end
	}

	public function send()
	{
		#if (js || neko || cpp)
			client.onData = onData;
			client.onError = onError;
			#if js
				client.setPostData(data);
			#else
				client.setParameter("data", data);
			#end
			client.request(true);
		#elseif flash9
			client.data = data;
			client.method = "POST";
			var loader = new flash.net.URLLoader();
			loader.addEventListener(flash.events.Event.COMPLETE, internalOnData);
			loader.addEventListener(flash.events.IOErrorEvent.IO_ERROR, internalOnError);

			loader.load(client);
		#elseif flash
			var result = new flash.LoadVars();
			result.onData = internalOnData;

			client.data = data;
			client.sendAndLoad(url, result, "POST");
		#end		
	}

	#if flash9
		function internalOnData(event:flash.events.Event) 
		{
			onData(event.target.data);
		}

		function internalOnError(event:flash.events.Event)
		{
			onError("Invalid Server Response.");
		}
	#elseif flash
		function internalOnData(value:String)
		{
			if (value == null)
				onError("Invalid Server Response.");
			else
				onData(value);
		}
	#end
}
