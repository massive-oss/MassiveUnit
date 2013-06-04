/*
 * Copyright 2013 TiVo Inc.
 */

package massive.munit;

import haxe.PosInfos;
import massive.munit.Assert;

class Async
{
	public static function asyncHandler(testCase:Dynamic, handler:Dynamic, timeout:Int = 1000, timeoutHandler:Dynamic = null, ?info:PosInfos):Dynamic
	{
		if (TestRunner.activeRunner == null)
		{
			throw "Can't create an asyncHandler when not running tests";
		}
		return TestRunner.activeRunner.asyncFactory.createHandler(testCase, handler, timeout, timeoutHandler, info);
	}
}