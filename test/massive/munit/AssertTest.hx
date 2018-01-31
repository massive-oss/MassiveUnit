/**************************************** ****************************************
 * Copyright 2010 Massive Interactive. All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification, are
 * permitted provided that the following conditions are met:
 * 
 *	1. Redistributions of source code must retain the above copyright notice, this list of
 *	   conditions and the following disclaimer.
 * 
 *	2. Redistributions in binary form must reproduce the above copyright notice, this list
 *	   of conditions and the following disclaimer in the documentation and/or other materials
 *	   provided with the distribution.
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
 */
package massive.munit;
import haxe.io.Bytes;
import massive.munit.Assert;

/**
 * @author Mike Stead
 */
class AssertTest 
{
	static inline var FAILURE_MESSAGE = "failure message";
	
	@Test
	public function testIsTrue()
	{
		Assert.isTrue(true);
		try 
		{
			Assert.isTrue(false);
		}
		catch (e:AssertionException) 
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function isTrueWithMessage() {
		try {
			Assert.isTrue(false, FAILURE_MESSAGE);
		} catch(e:AssertionException) {
			Assert.areEqual(FAILURE_MESSAGE, e.message);
		}
	}
	
	@Test
	public function testIsFalse()
	{
		Assert.isFalse(false);
		try 
		{
			Assert.isFalse(true);
		}
		catch (e:AssertionException) 
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function isFalseWithMessage() {
		try {
			Assert.isFalse(true, FAILURE_MESSAGE);
		} catch(e:AssertionException) {
			Assert.areEqual(FAILURE_MESSAGE, e.message);
		}
	}
	
	@Test
	public function testIsNull()
	{
		Assert.isNull(null);
		try 
		{
			Assert.isNull({});
		}
		catch (e:AssertionException) 
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function isNullWithMessage() {
		try {
			Assert.isNull({}, FAILURE_MESSAGE);
		} catch(e:AssertionException) {
			Assert.areEqual(FAILURE_MESSAGE, e.message);
		}
	}
	
	@Test
	public function testIsNotNull()
	{
		Assert.isNotNull({});
		try 
		{
			Assert.isNotNull(null);
		}
		catch (e:AssertionException) 
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function isNotNullWithMessage() {
		try {
			Assert.isNotNull(null, FAILURE_MESSAGE);
		} catch(e:AssertionException) {
			Assert.areEqual(FAILURE_MESSAGE, e.message);
		}
	}
	
	@Test
	public function testIsNaN()
	{
		Assert.isNaN(Math.NaN);
		try 
		{
			Assert.isNaN(1);
		}
		catch (e:AssertionException) 
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function isNaNWithMessage() {
		try {
			Assert.isNaN(1, FAILURE_MESSAGE);
		} catch(e:AssertionException) {
			Assert.areEqual(FAILURE_MESSAGE, e.message);
		}
	}
	
	@Test
	public function testIsNotNaN()
	{
		Assert.isNotNaN(1);
		try 
		{
			Assert.isNotNaN(Math.NaN);
		}
		catch (e:AssertionException) 
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function isNotNaNWithMessage() {
		try {
			Assert.isNotNaN(Math.NaN, FAILURE_MESSAGE);
		} catch(e:AssertionException) {
			Assert.areEqual(FAILURE_MESSAGE, e.message);
		}
	}
	
	@Test
	public function testIsType()
	{
		Assert.isType(1, Int);
		try 
		{
			Assert.isType(1, String);
		}
		catch (e:AssertionException) 
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function isTypeWithMessage() {
		try {
			Assert.isType(1, String, FAILURE_MESSAGE);
		} catch(e:AssertionException) {
			Assert.areEqual(FAILURE_MESSAGE, e.message);
		}
	}
	
	@Test
	public function testIsNotType()
	{
		Assert.isNotType(1, String);
		try 
		{
			Assert.isNotType(1, Int);
		}
		catch (e:AssertionException) 
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function isNotTypeWithMessage() {
		try {
			Assert.isType(1, Int, FAILURE_MESSAGE);
		} catch(e:AssertionException) {
			Assert.areEqual(FAILURE_MESSAGE, e.message);
		}
	}
	
	@Test
	public function testAreEqualString()
	{
		Assert.areEqual("yoyo", "yoyo");
		try 
		{
			Assert.areEqual("", "yoyo");
		}
		catch (e:AssertionException) 
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function areEqualStringWithMessage() {
		try {
			Assert.areEqual("", "yoyo", FAILURE_MESSAGE);
		} catch(e:AssertionException) {
			Assert.areEqual(FAILURE_MESSAGE, e.message);
		}
	}
	
	@Test
	public function areEqualObjectWithMessage() {
		try {
			Assert.areEqual({x:1}, {y:1}, FAILURE_MESSAGE);
		} catch(e:AssertionException) {
			Assert.areEqual(FAILURE_MESSAGE, e.message);
		}
	}
	
	@Test
	public function testAreEqualNumber()
	{
		Assert.areEqual(1, 1);
		try 
		{
			Assert.areEqual(1, 2);
		}
		catch (e:AssertionException) 
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function areEqualNumberWithMessage() {
		try {
			Assert.areEqual(1, 2, FAILURE_MESSAGE);
		} catch(e:AssertionException) {
			Assert.areEqual(FAILURE_MESSAGE, e.message);
		}
	}
	
	@Test
	public function testAreEqualEnum()
	{
		Assert.areEqual(ValueA, ValueA);
		try
		{
			Assert.areEqual(ValueA, ValueB);
		}
		catch (e:AssertionException)
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function areEqualEnumWithMessage() {
		try {
			Assert.areEqual(ValueA, ValueB, FAILURE_MESSAGE);
		} catch(e:AssertionException) {
			Assert.areEqual(FAILURE_MESSAGE, e.message);
		}
	}

	@Test
	public function testAreEqualEnumWithParam()
	{
		Assert.areEqual(ValueC("foo"), ValueC("foo"));
		try
		{
			Assert.areEqual(ValueC("foo"), ValueC("bar"));
		}
		catch (e:AssertionException)
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function areEqualEnum2WithMessage() {
		try {
			Assert.areEqual(ValueC("foo"), ValueC("bar"), FAILURE_MESSAGE);
		} catch(e:AssertionException) {
			Assert.areEqual(FAILURE_MESSAGE, e.message);
		}
	}
	
	@Test
	public function areEqualArray() {
		Assert.areEqual([1, 2, 3], [1, 2, 3]);
		try {
			Assert.areEqual([1, 2, 3], [4, 5, 6]);
		} catch(e:AssertionException) {
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function areEqualArray2() {
		Assert.areEqual([[1], [2], [3]], [[1], [2], [3]]);
		try {
			Assert.areEqual([1, 2, 3], ["4", "5", "6"]);
		} catch(e:AssertionException) {
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function areEqualBytes() {
		Assert.areEqual(Bytes.ofString("0xFF0000"), Bytes.ofString("0xFF0000"));
		try {
			Assert.areEqual(Bytes.ofString("0xFF0000"), Bytes.ofString("0x00FF00"));
		} catch(e:AssertionException) {
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function areEqualMap() {
		Assert.areEqual([1 => [1,2,3]], [1 => [1,2,3]]);
		try {
			Assert.areEqual(new Map<Int, Int>(), [1 => 1]);
		} catch(e:AssertionException) {
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function areEqualDate() {
		Assert.areEqual(new Date(2017, 0, 30, 0, 0, 0), new Date(2017, 0, 30, 0, 0, 0));
		try {
			Assert.areEqual(new Date(2016, 0, 30, 0, 0, 0), Date.now());
		} catch(e:AssertionException) {
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function areEqualDynamic() {
		Assert.areEqual({x:1, a:[1,2,3]}, {x:1, a:[1,2,3]});
		try {
			Assert.areEqual({x:1, a:[1,2,3]}, {x:10, y: 10});
		} catch(e:AssertionException) {
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function areEqualClass() {
		Assert.areEqual(CustomException, CustomException);
		try {
			Assert.areEqual(CustomException, AssertionException);
		} catch(e:AssertionException) {
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function areEqualInstance() {
		Assert.areEqual(new CustomException("0", 1), new CustomException("0", 1));
		try {
			Assert.areEqual(new CustomException("0", 1), new CustomException("0", 10));
		} catch(e:AssertionException) {
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function areEqualBool() {
		Assert.areEqual(true, true);
		try {
			Assert.areEqual(true, false);
		} catch(e:AssertionException) {
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function areEqualNull() {
		Assert.areEqual(null, null);
		try {
			Assert.areEqual(null, {});
		} catch(e:AssertionException) {
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function testAreNotEqualString()
	{
		Assert.areNotEqual("", "yoyo");
		try 
		{
			Assert.areNotEqual("yoyo", "yoyo");
		}
		catch (e:AssertionException) 
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function areNotEqualStringWithMessage() {
		try {
			Assert.areNotEqual("yoyo", "yoyo", FAILURE_MESSAGE);
		} catch(e:AssertionException) {
			Assert.areEqual(FAILURE_MESSAGE, e.message);
		}
	}
	
	@Test
	public function testAreNotEqualObject()
	{
		var o = {x:10};
		Assert.areNotEqual({}, o);
		try 
		{
			Assert.areNotEqual(o, o);
		}
		catch (e:AssertionException) 
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function areNotEqualObjectWithMessage() {
		try {
			var o = {};
			Assert.areNotEqual(o, o, FAILURE_MESSAGE);
		} catch(e:AssertionException) {
			Assert.areEqual(FAILURE_MESSAGE, e.message);
		}
	}
	
	@Test
	public function testAreNotEqualNumber()
	{
		Assert.areNotEqual(1, 2);
		try 
		{
			Assert.areNotEqual(1, 1);
		}
		catch (e:AssertionException) 
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function areNotEqualNumberWithMessage() {
		try {
			Assert.areNotEqual(1, 1, FAILURE_MESSAGE);
		} catch(e:AssertionException) {
			Assert.areEqual(FAILURE_MESSAGE, e.message);
		}
	}

	@Test
	public function testAreNotEqualEnum()
	{
		Assert.areNotEqual(ValueA, ValueB);
		try
		{
			Assert.areNotEqual(ValueA, ValueA);
		}
		catch (e:AssertionException)
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function areNotEqualEnumWithMessage() {
		try {
			Assert.areNotEqual(ValueA, ValueA, FAILURE_MESSAGE);
		} catch(e:AssertionException) {
			Assert.areEqual(FAILURE_MESSAGE, e.message);
		}
	}

	@Test
	public function testAreNotEqualEnumWithParam()
	{
		Assert.areNotEqual(ValueC("foo"), ValueC("bar"));
		try
		{
			Assert.areNotEqual(ValueC("foo"), ValueC("foo"));
		}
		catch (e:AssertionException)
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function areNotEqualEnum2WithMessage() {
		try {
			Assert.areNotEqual(ValueC("foo"), ValueC("foo"), FAILURE_MESSAGE);
		} catch(e:AssertionException) {
			Assert.areEqual(FAILURE_MESSAGE, e.message);
		}
	}

	public function testAreSameString()
	{
		Assert.areSame("yoyo", "yoyo");
		try
		{
			Assert.areEqual("", "yoyo");
		}
		catch (e:AssertionException)
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function areSameStringWithMessage() {
		try {
			Assert.areSame("", "yoyo", FAILURE_MESSAGE);
		} catch(e:AssertionException) {
			Assert.areEqual(FAILURE_MESSAGE, e.message);
		}
	}

	@Test
	public function testAreSameObject()
	{
		var o = {};
		Assert.areSame(o, o);
		try
		{
			Assert.areSame({}, o);
		}
		catch (e:AssertionException)
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function areSameObjectWithMessage() {
		try {
			var o = {};
			Assert.areSame({}, o, FAILURE_MESSAGE);
		} catch(e:AssertionException) {
			Assert.areEqual(FAILURE_MESSAGE, e.message);
		}
	}

	@Test
	public function testAreNotSameString()
	{
		Assert.areNotSame("", "yoyo");
		try
		{
			Assert.areNotSame("yoyo", "yoyo");
		}
		catch (e:AssertionException)
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function areNotSameStringWithMessage() {
		try {
			Assert.areNotSame("yoyo", "yoyo", FAILURE_MESSAGE);
		} catch(e:AssertionException) {
			Assert.areEqual(FAILURE_MESSAGE, e.message);
		}
	}

	@Test
	public function testAreNotSameObject()
	{
		var obj:Dynamic = {};
		Assert.areNotSame({}, obj);
		try
		{
			Assert.areNotSame(obj, obj);
		}
		catch (e:AssertionException)
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function areNotSameObjectWithMessage() {
		try {
			var o = {};
			Assert.areNotSame(o, o, FAILURE_MESSAGE);
		} catch(e:AssertionException) {
			Assert.areEqual(FAILURE_MESSAGE, e.message);
		}
	}

	@Test
	public function testDoesMatch()
	{
		Assert.doesMatch("regular_example_45-", ~/^regular_example_\d+\-$/);

		try
		{
			Assert.doesMatch("regular_example_45", ~/^regular_\d+$/);
		}
		catch (e:AssertionException)
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function doesMatchWithMessage() {
		try {
			Assert.doesMatch("regular_example_45", ~/^regular_\d+$/, FAILURE_MESSAGE);
		} catch(e:AssertionException) {
			Assert.areEqual(FAILURE_MESSAGE, e.message);
		}
	}

	@Test
	public function testDoesNotMatch()
	{
		Assert.doesNotMatch("this is a string", ~/^This is a string$/);
		Assert.doesNotMatch("fff", ~/^\d+$/);

		try
		{
			Assert.doesNotMatch("#198c19", ~/^#[0-9a-c]+$/i);
		}
		catch (e:AssertionException)
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function doesNotMatchWithMessage() {
		try {
			Assert.doesNotMatch("#198c19", ~/^#[0-9a-c]+$/i, FAILURE_MESSAGE);
		} catch(e:AssertionException) {
			Assert.areEqual(FAILURE_MESSAGE, e.message);
		}
	}

	@Test
	public function testFail()
	{
		try 
		{
			Assert.fail(FAILURE_MESSAGE);
		}
		catch (e:AssertionException) 
		{
			Assert.areEqual(FAILURE_MESSAGE, e.message); 
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function testThrowsStringAndObject()
	{
		// Positive case: throws expected string
		var expectedMessage:String = "Invalid operation!";
		var actualMessage:String = Assert.throws(String, function()
		{
			throw expectedMessage;
		});
		Assert.areEqual(expectedMessage, actualMessage);

		// Positive case: throws expected exception
		var expectedError:CustomException = new CustomException('URL not reachable', 37);
		var actualError:CustomException = Assert.throws(CustomException, function()
		{
			throw expectedError;
		});
		Assert.areEqual(expectedError.message, actualError.message);
		Assert.areEqual(expectedError.code, actualError.code);

		// Negative case: assertion raised if block doesn't throw
		try
		{
			Assert.throws(String, function()
			{
				// Doesn't throw
			});
		}
		catch (e:AssertionException)
		{
			Assert.isTrue(e.message.indexOf("wasn't thrown") > -1);
		}
	}

	@Test
	public function testThrowsFailsIfWrongExceptionTypeThrown()
	{
		try
		{
			Assert.throws(CustomException, function()
			{
				throw "String error!";
			});
			Assert.fail("Throwing the wrong exception type didn't fail");
		}
		catch (e:AssertionException)
		{
			Assert.isTrue(e.message.indexOf("Expected exception of type") > -1);
		}
	}
    
	@Test
	public function isEmptyString() {
		Assert.isEmpty("");
		try {
			Assert.isEmpty("1,2,3");
		} catch(e:AssertionException) {
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function isEmptyStringWithMessage() {
		try {
			Assert.isEmpty("1,2,3", FAILURE_MESSAGE);
		} catch(e:AssertionException) {
			Assert.areEqual(FAILURE_MESSAGE, e.message);
		}
	}
	
	@Test
	public function isEmptyArray() {
		Assert.isEmpty([]);
		try {
			Assert.isEmpty([1,2,3]);
		} catch(e:AssertionException) {
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function isEmptyMap() {
		Assert.isEmpty(new Map<Int, Int>());
		try {
			Assert.isEmpty([0 => 1]);
		} catch(e:AssertionException) {
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
    
	@Test
	public function isNotEmptyString() {
		Assert.isNotEmpty("1,2,3");
		try {
			Assert.isNotEmpty("");
		} catch(e:AssertionException) {
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function isNotEmptyStringWithMessage() {
		try {
			Assert.isNotEmpty("", FAILURE_MESSAGE);
		} catch(e:AssertionException) {
			Assert.areEqual(FAILURE_MESSAGE, e.message);
		}
	}
    
	@Test
	public function isNotEmptyArray() {
		Assert.isNotEmpty([1,2,3]);
		try {
			Assert.isNotEmpty([]);
		} catch(e:AssertionException) {
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
    
	@Test
	public function isNotEmptyMap() {
		Assert.isNotEmpty([0 => 1]);
		try {
			Assert.isNotEmpty(new Map<Int, Int>());
		} catch(e:AssertionException) {
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
}

private enum DummyEnum
{
	ValueA;
	ValueB;
	ValueC(param:String);
}

private class CustomException
{
	public var message(default, default):String;
	public var code(default, default):Int;
	
	public function new(message:String, code:Int)
	{
		this.message = message;
		this.code = code;
	}
}
