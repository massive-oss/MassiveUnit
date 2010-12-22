package ;
import massive.munit.async.AsyncDelegate;
import haxe.PosInfos;

/**
 * ...
 * @author Mike Stead
 */
class TestRunnerAsyncDelegate extends AsyncDelegate
{
	/**
	 * Class constructor.
	 * 
	 * @param	testCase			@inheritDoc
	 * @param	handler				@inheritDoc
	 * @param	?timeout			@inheritDoc
	 * @param	?info				@inheritDoc
	 */
	public function new(testCase:Dynamic, handler:Dynamic, ?timeout:Int, ?info:PosInfos) 
	{
		super(testCase, handler, asyncHanlder, timeout, info);
	}

	private function asyncHanlder(isSuccessful:Bool):Void
	{
		responseHandler([isSuccessful]);
	}
}