package ;
import massive.munit.async.AsyncFactory;
import haxe.PosInfos;
import massive.munit.async.IAsyncDelegateObserver;

/**
 * ...
 * @author Mike Stead
 */

class MUnitAsyncFactory extends AsyncFactory
{
	public function new(observer:IAsyncDelegateObserver) 
	{
		super(observer);
	}
	
	public function createTestRunnerHandler(testCase:Dynamic, handler:Dynamic, ?timeout:Int, ?info:PosInfos):Dynamic
	{
		var dispatcher:TestRunnerAsyncDelegate = new TestRunnerAsyncDelegate(testCase, handler, timeout, info);
		dispatcher.observer = observer;
		asyncDelegateCount++;
		return dispatcher.delegateHandler;
	}
}