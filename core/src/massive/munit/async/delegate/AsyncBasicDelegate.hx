package massive.munit.async.delegate;

import haxe.PosInfos;
import massive.munit.async.AsyncDelegate;

/**
 * An AsyncDelegate which requires no parameters to be passed to its handler.
 * 
 * @author Mike Stead
 */
class AsyncBasicDelegate extends AsyncDelegate
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

	private function asyncHanlder():Void
	{
		responseHandler();
	}
}