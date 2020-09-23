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

package massive.munit.client;
#if !hl
import haxe.Http;
#end
import haxe.ds.StringMap;
import massive.munit.ITestResultClient;
import massive.munit.TestResult;

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
	 * HTTP header key. Contains id of platform being tests (flash,js,neko,cpp,php).
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
	@:isVar public var completionHandler(get, set):ITestResultClient->Void;
	
	private function get_completionHandler():ITestResultClient->Void
	{
		return completionHandler;
	}
	private function set_completionHandler(value:ITestResultClient->Void):ITestResultClient->Void
	{
		return completionHandler = value;
	}

	private var client:ITestResultClient;
	private var url:String;
	private var request:URLRequest;
	private var queueRequest:Bool;

	/**
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
	public function setCurrentTestClass(className:String)
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
	public function addPass(result:TestResult)
	{
		client.addPass(result);
	}

	/**
	 * Called when a test fails.
	 *  
	 * @param	result			a failed test result
	 */
	public function addFail(result:TestResult)
	{
		client.addFail(result);
	}

	/**
	 * Called when a test triggers an unexpected exception.
	 *  
	 * @param	result			an erroneous test result
	 */
	public function addError(result:TestResult)
	{
		client.addError(result);
	}
	
	/**
	 * Called when a test has been ignored.
	 *
	 * @param	result			an ignored test
	 */
	public function addIgnore(result:TestResult)
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

	function sendResult(result:Dynamic)
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

	function platform():String
	{
		#if flash return "as3";
		#elseif js return "js";
		#elseif neko return "neko";
		#elseif cpp return "cpp";
		#elseif java return "java";
		#elseif cs return "cs";
		#elseif python return "python";
		#elseif php return "php";
		#elseif hl return "hl";
		#elseif eval return "eval";
		#elseif lua return "lua";
		#end
		return "unknown";
	}

	function onData(data:String)
	{
		if (queueRequest)
		{
			responsePending = false;
			dispatchNextRequest();
		}
		if (completionHandler != null)
			completionHandler(this);
	}

	function onError(msg:String)
	{
		if (queueRequest)
		{
			responsePending = false;
			dispatchNextRequest();
		}
		if (completionHandler != null)
			completionHandler(this);
	}

	static function dispatchNextRequest()
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
	public var onData:Dynamic->Void;
	public var onError:Dynamic->Void;
	public var data:Dynamic;

	var url:String;
	var headers:StringMap<String>;

	#if(js || neko || cpp || java || cs || python || php || hl || eval || lua)
	public var client:Http;
	#elseif flash
	public var client:flash.net.URLRequest;
	#end


	public function new(url:String)
	{
		this.url = url;
		createClient(url);
		setHeader("Content-Type", "text/plain");
	}

	function createClient(url:String)
	{
		#if(js || neko || cpp || java || cs || python || php || hl || eval || lua)
		client = new Http(url);
		#elseif flash
		client = new flash.net.URLRequest(url);
		#end
	}

	public function setHeader(name:String, value:String)
	{
		#if(js || neko || cpp || java || cs || python || php || hl || eval || lua)
		client.setHeader(name, value);
		#elseif flash
		client.requestHeaders.push(new flash.net.URLRequestHeader(name, value)); 
		#end
	}

	public function send()
	{
		var body = Std.string(data);
		#if(js || neko || cpp || java || cs || python || php || hl || eval || lua)
		client.onData = onData;
		client.onError = onError;
			#if js
				#if nodejs
				client.setHeader('Content-Length', Std.string(haxe.io.Bytes.ofString(body).length));
				#end
			client.setPostData(body);
			#else
			client.setParameter("data", body);
			#end
			#if hl
			client.cnxTimeout = 1;
			#end
		client.request(true);
		#elseif flash
		client.data = data;
		client.method = "POST";
		var loader = new flash.net.URLLoader();
		loader.addEventListener(flash.events.Event.COMPLETE, internalOnData);
		loader.addEventListener(flash.events.IOErrorEvent.IO_ERROR, internalOnError);
		loader.load(client); 
		#end
	}

	#if flash
	function internalOnData(event:flash.events.Event) 
	{
		onData(cast (event.target, flash.net.URLLoader).data);
	}
	function internalOnError(event:flash.events.Event)
	{
		onError("Invalid Server Response.");
	} 
	#end
}

#if hl
class Http extends haxe.Http {
	override function readHttpResponse(api:haxe.io.Output, sock:sys.net.Socket) {
		// READ the HTTP header (until \r\n\r\n)
		var b = new haxe.io.BytesBuffer();
		var k = 4;
		var s = haxe.io.Bytes.alloc(4);
		sock.setTimeout(cnxTimeout);
		while( true ) {
			var p = sock.input.readBytes(s,0,k);
			while( p != k )
				p += sock.input.readBytes(s,p,k - p);
			b.addBytes(s,0,k);
			switch( k ) {
			case 1:
				var c = s.get(0);
				if( c == 10 )
					break;
				if( c == 13 )
					k = 3;
				else
					k = 4;
			case 2:
				var c = s.get(1);
				if( c == 10 ) {
					if( s.get(0) == 13 )
						break;
					k = 4;
				} else if( c == 13 )
					k = 3;
				else
					k = 4;
			case 3:
				var c = s.get(2);
				if( c == 10 ) {
					if( s.get(1) != 13 )
						k = 4;
					else if( s.get(0) != 10 )
						k = 2;
					else
						break;
				} else if( c == 13 ) {
					if( s.get(1) != 10 || s.get(0) != 13 )
						k = 1;
					else
						k = 3;
				} else
					k = 4;
			case 4:
				var c = s.get(3);
				if( c == 10 ) {
					if( s.get(2) != 13 )
						continue;
					else if( s.get(1) != 10 || s.get(0) != 13 )
						k = 2;
					else
						break;
				} else if( c == 13 ) {
					if( s.get(2) != 10 || s.get(1) != 13 )
						k = 3;
					else
						k = 1;
				}
			}
		}
		#if neko
		var headers = neko.Lib.stringReference(b.getBytes()).split("\r\n");
		#else
		var headers = b.getBytes().toString().split("\r\n");
		#end
		var response = headers.shift();
		var rp = response.split(" ");
		var status = Std.parseInt(rp[1]);
		if( status == 0 || status == null )
			throw "Response status error";

		// remove the two lasts \r\n\r\n
		headers.pop();
		headers.pop();
		responseHeaders = new haxe.ds.StringMap();
		var size = null;
		var chunked = false;
		for( hline in headers ) {
			var a = hline.split(": ");
			var hname = a.shift();
			var hval = if( a.length == 1 ) a[0] else a.join(": ");
			hval = StringTools.ltrim( StringTools.rtrim( hval ) );
			responseHeaders.set(hname, hval);
			switch(hname.toLowerCase())
			{
				case "content-length":
					size = Std.parseInt(hval);
				case "transfer-encoding":
					chunked = (hval.toLowerCase() == "chunked");
			}
		}

		onStatus(status);

		var chunk_re = ~/^([0-9A-Fa-f]+)[ ]*\r\n/m;
		chunk_size = null;
		chunk_buf = null;

		var bufsize = 1024;
		var buf = haxe.io.Bytes.alloc(bufsize);

		if( chunked ) {
			try {
				while( true ) {
					var len = sock.input.readBytes(buf,0,bufsize);
					if( !readChunk(chunk_re,api,buf,len) )
						break;
				}
			} catch ( e : haxe.io.Eof ) {
				throw "Transfer aborted";
			}
		} else if( size == null ) {
			if( !noShutdown )
				sock.shutdown(false,true);
			try {
				while( true ) {
					var len = sock.input.readBytes(buf, 0, bufsize);
					//{XXX slavara: quickfix for https://github.com/HaxeFoundation/haxe/issues/6777
					if(len == 0) break;
					//}
					api.writeBytes(buf,0,len);
				}
			} catch( e : haxe.io.Eof ) {
			}
		} else {
			api.prepare(size);
			try {
				while( size > 0 ) {
					var len = sock.input.readBytes(buf,0,if( size > bufsize ) bufsize else size);
					api.writeBytes(buf,0,len);
					size -= len;
				}
			} catch( e : haxe.io.Eof ) {
				throw "Transfer aborted";
			}
		}
		if( chunked && (chunk_size != null || chunk_buf != null) )
			throw "Invalid chunk";
		if( status < 200 || status >= 400 )
			throw "Http Error #"+status;
		api.close();
	}
}
#end