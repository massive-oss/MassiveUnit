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

package massive.munit;
import haxe.Constraints.Function; 
import haxe.PosInfos; 
import haxe.extern.EitherType; 
 
private typedef RefType = EitherType<{}, Function>; 

/**
 * Used to make assertions about values in test cases.
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
	 * @param message The message to display in case of failure
	 * @throws	AssertionException	if value is not true
	 */
	public static function isTrue(value:Bool, ?message:String, ?info:PosInfos)
	{
		assertionCount++;
		if(value) return;
		if(message == null) message = "Expected TRUE but was [" + value + "]";
		fail(message, info);
	}
	
	/**
	 * Assert that a value is false.
	 * 
	 * @param	value				value expected to be false
	 * @param message The message to display in case of failure
	 * @throws	AssertionException	if value is not false
	 */
	public static function isFalse(value:Bool, ?message:String, ?info:PosInfos)
	{
		assertionCount++;
		if(!value) return;
		if(message == null) message = "Expected FALSE but was [" + value + "]";
		fail(message, info);
	}
	
	/**
	 * Assert that a value is null.
	 * 
	 * @param	value				value expected to be null
	 * @param message The message to display in case of failure
	 * @throws	AssertionException	if value is not null
	 */
	public static function isNull<T>(value:Null<T>, ?message:String, ?info:PosInfos)
	{
		assertionCount++;
		if(value == null) return;
		if(message == null) message = "Value [" + value + "] was not NULL";
		fail(message, info);
	}
	
	/**
	 * Assert that a value is not null.
	 * 
	 * @param	value				value expected not to be null
	 * @param message The message to display in case of failure
	 * @throws	AssertionException	if value is null
	 */
	public static function isNotNull<T>(value:Null<T>, ?message:String, ?info:PosInfos)
	{
		assertionCount++;
		if(value != null) return;
		if(message == null) message = "Value [" + value + "] was NULL";
		fail(message, info);
	}
	
	/**
	 * Assert that a value is Math.NaN.
	 * 
	 * @param	value				value expected to be Math.NaN
	 * @param message The message to display in case of failure
	 * @throws	AssertionException	if value is not Math.NaN
	 */
	public static function isNaN(value:Float, ?message:String, ?info:PosInfos)
	{
		assertionCount++;
		if(Math.isNaN(value)) return;
		if(message == null) message = "Value [" + value + "]  was not NaN";
		fail(message, info);
	}

	/**
	 * Assert that a value is not Math.NaN.
	 * 
	 * @param	value				value expected not to be Math.NaN
	 * @param message The message to display in case of failure
	 * @throws	AssertionException	if value is Math.NaN
	 */
	public static function isNotNaN(value:Float, ?message:String, ?info:PosInfos)
	{
		assertionCount++;
		if(!Math.isNaN(value)) return;
		if(message == null) message = "Value [" + value + "] was NaN";
		fail(message, info);
	}
	
	/**
	 * Assert that a value is of a specific type.
	 * 
	 * @param	value				value expected to be of a given type
	 * @param	type				type the value should be
	 * @param message The message to display in case of failure
	 */
	public static function isType(value:Dynamic, type:Dynamic, ?message:String, ?info:PosInfos)
	{
		assertionCount++;
		if(Std.is(value, type)) return;
		if(message == null) message = "Value [" + value + "] was not of type: " + Type.getClassName(type);
		fail(message, info);
	}
	
	/**
	 * Assert that a value is not of a specific type.
	 * 
	 * @param	value				value expected to not be of a given type
	 * @param	type				type the value should not be
	 * @param message The message to display in case of failure
	 */
	public static function isNotType(value:Dynamic, type:Dynamic, ?message:String, ?info:PosInfos)
	{
		assertionCount++;
		if(!Std.is(value, type)) return;
		if(message == null) message = "Value [" + value + "] was of type: " + Type.getClassName(type);
		fail(message, info);
	}
	
	/**
	 * Assert that two values are equal.
	 * 
	 * If the expected value is an Enum then Type.enumEq will be used to compare the two values.
	 * Otherwise strict equality is used.
	 * @param	expected			expected value
	 * @param	actual				actual value
	 * @param message The message to display in case of failure
	 * @throws	AssertionException	if expected is not equal to the actual value
	 */
	public static function areEqual<TExpected, TActual>(expected:TExpected, actual:TActual, ?message:String, ?info:PosInfos)
	{
		assertionCount++;
		if(equals(expected, actual)) return;
		if(message == null) message = "Value [" + actual + "] was not equal to expected value [" + expected + "]";
		fail(message, info);
	}
	
	/**
	 * Assert that two values are not equal.
	 * 
	 * If the expected value is an Enum then Type.enumEq will be used to compare the two values.
	 * Otherwise strict equality is used.
	 * @param	expected			expected value
	 * @param	actual				actual value
	 * @param message The message to display in case of failure
	 * @throws	AssertionException	if expected is equal to the actual value
	 */
	public static function areNotEqual<TExpected, TActual>(expected:TExpected, actual:TActual, ?message:String, ?info:PosInfos)
	{
		assertionCount++;
		if(!equals(expected, actual)) return;
		if(message == null) message = "Value [" + actual + "] was equal to value [" + expected + "]";
		fail(message, info);
	}

	/**
	 * Assert that two values are one and the same.
	 * 
	 * @param	expected			expected value
	 * @param	actual				actual value
	 * @param message The message to display in case of failure
	 * @throws	AssertionException	if expected is not the same as the actual value
	 */
	public static function areSame<T:RefType>(expected:T, actual:T, ?message:String, ?info:PosInfos)
	{
		assertionCount++;
		if(expected == actual) return;
		if(message == null) message = "Value [" + actual + "] was not the same as expected value [" + expected + "]";
		fail(message, info);
	}

	/**
	 * Assert that two values are not one and the same.
	 * 
	 * @param	expected			expected value
	 * @param	actual				actual value
	 * @param message The message to display in case of failure
	 * @throws	AssertionException	if expected is the same as the actual value
	 */
	public static function areNotSame<T:RefType>(expected:T, actual:T, ?message:String, ?info:PosInfos)
	{
		assertionCount++;
		if(expected != actual) return;
		if(message == null) message = "Value [" + actual + "] was the same as expected value [" + expected + "]";
		fail(message, info);
	}

	/**
	 * Assert that a string matches a regular expression. The internal state of the given regular expression
	 * may be modified by this assertion.
	 *
	 * @param	string			value expected to match the regular expression
	 * @param	regex			a regular expression that should match the string value
	 * @param message The message to display in case of failure
	 * @throws	AssertionException	if regex does not match string
	 */
	public static function doesMatch(string:String, regexp:EReg, ?message:String, ?info:PosInfos)
	{
		assertionCount++;
		if(regexp.match(string)) return;
		if(message == null) message = "Value [" + string + "] was expected to match [" + regexp + "]";
		fail(message, info);
	}

	/**
	 * Assert that a string does not match a regular expression. The internal state of the given regular expression
	 * may be modified by this assertion.
	 *
	 * @param	string			value expected to not match the regular expression
	 * @param	regex			a regular expression that should not match the string value
	 * @param message The message to display in case of failure
	 * @throws	AssertionException	if regex matches string
	 */
	public static function doesNotMatch(string:String, regexp:EReg, ?message:String, ?info:PosInfos)
	{
		assertionCount++;
		if(!regexp.match(string)) return;
		if(message == null) message = "Value [" + string + "] was expected to not match [" + regexp + "], and matched at [" + regexp.matchedPos().pos + "]";
		fail(message, info);
	}

	/**
	 * Assert that an expectation was thrown. Can expect strings and non-strings.
	 *
	 * @param   expectedType        the type of exception expected (eg. String, AssertionException)
	 * @param   code				a function which should throw an exception
	 * @return					  the exception that was thrown
	 * @throws  AssertionException  if no expectation is thrown
	 */
	public static function throws(expectedType:Dynamic, code:Dynamic, ?info:PosInfos):Dynamic
	{
		try
		{
			code();
			fail("Expected exception wasn't thrown!", info);
		}
		catch (e:Dynamic)
		{
			if(Std.is(e, expectedType)) return e;
			Assert.fail('Expected exception of type ${Type.getClassName(expectedType)} but got ${Type.getClassName(Type.getClass(e))}: ${e}');
		}
		return null;
	}

	/**
	 * Force an assertion failure.
	 * 
	 * @param	message				message describing the assertion which failed
	 * @throws	AssertionException	thrown automatically
	 */
	public static function fail(message:String, ?info:PosInfos)
	{
		throw new AssertionException(message, info);
	}
	
	static inline function equals(a:Dynamic, b:Dynamic) return switch(Type.typeof(a)) {
		case TEnum(_): Type.enumEq(a, b);
		case TFunction: Reflect.compareMethods(a, b);
		default: a == b;
	}
}
