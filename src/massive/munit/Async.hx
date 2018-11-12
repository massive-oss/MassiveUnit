package massive.munit;

import haxe.PosInfos;
import massive.munit.Assert;

class Async
{
	public static function handler(testCase:Dynamic, callbackFunc:Dynamic, timeout:Int = 1000, timeoutHandler:Dynamic = null, ?info:PosInfos):Dynamic
	{
		if (TestRunner.activeRunner == null)
		{
			throw "Can't create an handler when not running tests";
		}
		return TestRunner.activeRunner.asyncFactory.createHandler(testCase, callbackFunc, timeout, timeoutHandler, info);
	}
}
