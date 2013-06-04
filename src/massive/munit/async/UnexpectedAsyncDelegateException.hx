/*
 * Copyright 2013 TiVo Inc.
 */

package massive.munit.async;

import haxe.PosInfos;
import massive.munit.MUnitException;
import massive.haxe.util.ReflectUtil;

/**
 * Exception thrown when a synchronous test creates an AsyncDelegate.
 */
class UnexpectedAsyncDelegateException extends MUnitException
{
	/**
	 * {@inheritDoc}
	 */
	public function new(message:String, ?info:PosInfos)
	{
		super(message, info);
		type = ReflectUtil.here().className;
	}
}
