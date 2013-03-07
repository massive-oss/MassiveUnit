package ;
import haxe.Http;
import massive.munit.client.HTTPClient;

/**
 * ...
 * @author Mike Stead
 */

@:expose class BrowserTestsCompleteReporter
{
	public static inline var CLIENT_RUNNER_HOST = "munit-tool-host";

	public static function main() 
	{}
	
	public function new() 
	{}
	
	public static function sendReport(onData, onError)
	{
		var httpRequest = new Http(HTTPClient.DEFAULT_SERVER_URL);
		httpRequest.setHeader(HTTPClient.CLIENT_HEADER_KEY, CLIENT_RUNNER_HOST);
		httpRequest.setHeader(HTTPClient.PLATFORM_HEADER_KEY, "-");
		httpRequest.setParameter("data", "COMPLETE");
		httpRequest.onData = onData;
		httpRequest.onError = onError;
		httpRequest.request(true);		
	}
}
