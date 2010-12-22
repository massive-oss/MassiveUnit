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



package massive.munit.client;
import haxe.Http;
import massive.munit.ITestResultClient;
import massive.munit.TestResult;
import massive.munit.util.Timer;

/**
 * Decorates other ITestResultClient's, adding behavior to post test results to a specified url.
 * 
 * @author Mike Stead
 */
class HTTPClient implements ITestResultClient
{
	/**
	 * Default id of this client.
	 */
	public inline static var DEFAULT_ID:String = "HTTPClient";

	/**
	 * HTTP header key. Contains id of client the HTTPClient is decorating.
	 */
	public inline static var CLIENT_HEADER_KEY:String = "munit-clientId";
	
	/**
	 * HTTP header key. Contains id of platform being tests (flash9,flash,js,neko,cpp,php).
	 */
	public inline static var PLATFORM_HEADER_KEY:String = "munit-platformId";
	
	/**
	 * HTTP header key. If this HTTPClient is using the global queue for its requests
	 * then this header contains the position of the request in the queue.
	 */
	public inline static var REQUEST_ID_KEY:String = "munit-requestId";
	
	/* Global sequental (FIFO) http request queue */
	private static var queue:Array<Http> = [];
	private static var responsePending:Bool = false;
	
	/**
	 * The unique identifier for the client.
	 */
	public var id(default, null):String;
	
	/**
	 * Handler which if present, is called when the client has completed sending the test results to the specificied url. 
	 * This will be called once an HTTP response has been recieved.
	 */
	public var completionHandler(get_completeHandler, set_completeHandler):ITestResultClient -> Void;
	private function get_completeHandler():ITestResultClient -> Void 
	{
		return completionHandler;
	}
	private function set_completeHandler(value:ITestResultClient -> Void):ITestResultClient -> Void
	{
		return completionHandler = value;
	}

	private var client:ITestResultClient;
	private var url:String;
	private var httpRequest:Http;
	private var queueRequest:Bool;
	
	/**
	 * 
	 * @param	client				the test result client to decorate
	 * @param	url					the url to send test results to
	 * @param	?queueRequest		[optional] whether to add http requests to a global queue. Default is true.
	 * @param	?httpRequest		[optional] a custom http request to use to dispatch the result.
	 */
	public function new(client:ITestResultClient, url:String, ?queueRequest:Bool = true, ?httpRequest:Http) 
	{
		id = DEFAULT_ID;
		this.client = client;
		this.url = url;
		this.queueRequest = queueRequest;
		this.httpRequest = httpRequest;
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
	 * Called when all tests are complete.
	 *  
	 * @param	testCount		total number of tests run
	 * @param	passCount		total number of tests which passed
	 * @param	failCount		total number of tests which failed
	 * @param	errorCount		total number of tests which were erroneous
	 * @param	time			number of milliseconds taken for all tests to be executed
	 * @return	collated test result data if any
	 */
	public function reportFinalStatistics(testCount:Int, passCount:Int, failCount:Int, errorCount:Int, time:Float):Dynamic
	{
		var result = client.reportFinalStatistics(testCount, passCount, failCount, errorCount, time);
		sendResult(result);
		return result;
	}
	
	private function sendResult(result):Void
	{
		if (httpRequest == null) 
		{
			httpRequest = new Http(url);
			httpRequest.setHeader(CLIENT_HEADER_KEY, client.id);
			httpRequest.setHeader(PLATFORM_HEADER_KEY, platform());
			httpRequest.onData = onData;
			httpRequest.onError = onError;
		}
		
		httpRequest.setParameter("data", result);
		
		if (queueRequest)
		{
			queue.unshift(httpRequest);
			Timer.delay(dispatchNextRequest, 50); // simple invalidation to capture multiple reqests
		}
		else httpRequest.request(true);
	}
	
	private function platform():String
	{
		#if flash9 return "flash9";
		#elseif flash return "flash";
		#elseif js return "js";
		#elseif neko return "neko";
		#elseif cpp return "cpp";
		#elseif php return "php"
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
		if (completionHandler != null) completionHandler(this); 
	}
	
	private function onError(msg:String):Void
	{
//		trace("\n                                        HTTPClient.onError: " + msg);	
		if (queueRequest)
		{
			responsePending = false;
			dispatchNextRequest();
		}
		if (completionHandler != null) completionHandler(this); 
	}
	
	private static function dispatchNextRequest():Void
	{
		if (responsePending || queue.length == 0) return;
		responsePending = true;
		
		var httpRequest:Http = queue.pop();
		httpRequest.setHeader(REQUEST_ID_KEY, "" + queue.length);
		httpRequest.request(true);
	}
}
