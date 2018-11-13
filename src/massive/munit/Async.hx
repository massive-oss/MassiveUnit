package massive.munit;

import haxe.Constraints;
import haxe.PosInfos;
import massive.munit.Assert;

class Async
{
	public static function handler(testCase:Dynamic, callbackFunc:Function, timeout:Int = 1000, timeoutHandler:Function = null, ?info:PosInfos):Dynamic
	{
		if (TestRunner.activeRunner == null)
		{
			throw "Can't create an handler when not running tests";
		}
		return TestRunner.activeRunner.asyncFactory.createHandler(testCase, callbackFunc, timeout, timeoutHandler, info);
	}
}
