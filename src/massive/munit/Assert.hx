/****
* Copyright 2013 Massive Interactive. All rights reserved.
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

package massive.munit;

import haxe.PosInfos;

/**
 * Used to make assertions about values in test cases.
 *  
 * @author Mike Stead
 */
class Assert 
{
	/**
	 * The incremented number of assertions made during the execution of a set of tests.
	 */
	public static var assertionCount:Int = 0;
	
	/**
	 * Assert that a value is true.
	 *  
	 * @param	value				value expected to be true
	 * @throws	AssertionException	if value is not true
	 */ 
	public static function isTrue(value:Bool, ?info:PosInfos):Void
	{
		assertionCount++;
		if (value != true) fail("Expected TRUE but was [" + value + "]", info);
	}
	
	/**
	 * Assert that a value is false.
	 *  
	 * @param	value				value expected to be false
	 * @throws	AssertionException	if value is not false
	 */ 
	public static function isFalse(value:Bool, ?info:PosInfos):Void
	{
		assertionCount++;
		if (value != false) fail("Expected FALSE but was [" + value + "]", info);
	}
	
	/**
	 * Assert that a value is null.
	 *  
	 * @param	value				value expected to be null
	 * @throws	AssertionException	if value is not null
	 */ 
	public static function isNull(value:Dynamic, ?info:PosInfos):Void
	{
		assertionCount++;
		if (value != null) fail("Value [" + value + "] was not NULL", info);
	}
	
	/**
	 * Assert that a value is not null.
	 *  
	 * @param	value				value expected not to be null
	 * @throws	AssertionException	if value is null
	 */ 
	public static function isNotNull(value:Dynamic, ?info:PosInfos):Void
	{
		assertionCount++;
		if (value == null) fail("Value [" + value + "] was NULL", info);
	}
	
	/**
	 * Assert that a value is Math.NaN.
	 *  
	 * @param	value				value expected to be Math.NaN
	 * @throws	AssertionException	if value is not Math.NaN
	 */ 
	public static function isNaN(value:Float, ?info:PosInfos):Void
	{
		assertionCount++;
		if (!Math.isNaN(value)) fail("Value [" + value + "]  was not NaN", info);		
	}

	/**
	 * Assert that a value is not Math.NaN.
	 *  
	 * @param	value				value expected not to be Math.NaN
	 * @throws	AssertionException	if value is Math.NaN
	 */
	public static function isNotNaN(value:Float, ?info:PosInfos):Void
	{
		assertionCount++;
		if (Math.isNaN(value)) fail("Value [" + value + "] was NaN", info);		
	}
	
	/**
	 * Assert that a value is of a specific type.
	 * 
	 * @param	value				value expected to be of a given type
	 * @param	type				type the value should be
	 */
	public static function isType(value:Dynamic, type:Dynamic, ?info:PosInfos):Void
	{
		assertionCount++;
		if (!Std.is(value, type)) fail("Value [" + value + "] was not of type: " + Type.getClassName(type), info);
	}
	
	/**
	 * Assert that a value is not of a specific type.
	 * 
	 * @param	value				value expected to not be of a given type
	 * @param	type				type the value should not be
	 */
	public static function isNotType(value:Dynamic, type:Dynamic, ?info:PosInfos):Void
	{
		assertionCount++;
		if (Std.is(value, type)) fail("Value [" + value + "] was of type: " + Type.getClassName(type), info);
	}
	
	/**
	 * Assert that two values are equal.
	 * 
	 * If the expected value is an Enum then Type.enumEq will be used to compare the two values.
	 * Otherwise strict equality is used.
	 *  
	 * @param	expected			expected value
	 * @param	actual				actual value
	 * @throws	AssertionException	if expected is not equal to the actual value
	 */
	public static function areEqual(expected:Dynamic, actual:Dynamic, ?info:PosInfos):Void
	{
		assertionCount++;
		var equal = switch (Type.typeof(expected))
		{
			#if haxe3
			case TEnum(_): Type.enumEq(expected, actual);
			#else
			case TEnum(e): Type.enumEq(expected, actual);
			#end
			
			default: expected == actual;
		}		
		if (!equal) fail("Value [" + actual +"] was not equal to expected value [" + expected + "]", info);
	}
	
	/**
	 * Assert that two values are not equal.
	 *  
	 * If the expected value is an Enum then Type.enumEq will be used to compare the two values.
	 * Otherwise strict equality is used.
	 *  
	 * @param	expected			expected value
	 * @param	actual				actual value
	 * @throws	AssertionException	if expected is equal to the actual value
	 */
	public static function areNotEqual(expected:Dynamic, actual:Dynamic, ?info:PosInfos):Void
	{
		assertionCount++;
		var equal = switch (Type.typeof(expected))
		{
			#if haxe3
			case TEnum(_): Type.enumEq(expected, actual);
			#else
			case TEnum(e): Type.enumEq(expected, actual);
			#end
			default: expected == actual;
		}

		if (equal) fail("Value [" + actual +"] was equal to value [" + expected + "]", info);
	}

	/**
	 * Assert that two values are one and the same.
	 *  
	 * @param	expected			expected value
	 * @param	actual				actual value
	 * @throws	AssertionException	if expected is not the same as the actual value
	 */
	public static function areSame(expected:Dynamic, actual:Dynamic, ?info:PosInfos):Void
	{
		assertionCount++;
		if (expected != actual) fail("Value [" + actual +"] was not the same as expected value [" + expected + "]", info);
	}

	/**
	 * Assert that two values are not one and the same.
	 *  
	 * @param	expected			expected value
	 * @param	actual				actual value
	 * @throws	AssertionException	if expected is the same as the actual value
	 */
	public static function areNotSame(expected:Dynamic, actual:Dynamic, ?info:PosInfos):Void
	{
		assertionCount++;
		if (expected == actual) fail("Value [" + actual +"] was the same as expected value [" + expected + "]", info);
	}

	/**
	  * Force an assertion failure.
	  *  
	  * @param	msg				message describing the assertion which failed
	  * @throws	AssertionException	thrown automatically
	  */	
	public static function fail(msg:String, ?info:PosInfos):Void
	{
		throw new AssertionException(msg, info);
	}
}
