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

import massive.munit.Assert;

/**
 * ...
 * @author Mike Stead
 */
class AssertTest 
{
	public function new() 
	{
		
	}
	
	@Test
	public function testIsTrue():Void
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
	public function testIsFalse():Void
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
	public function testIsNull():Void
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
	public function testIsNotNull():Void
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
	public function testIsNaN():Void
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
	public function testIsNotNaN():Void
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
	public function testIsType():Void
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
	public function testIsNotType():Void
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
	public function testAreEqualString():Void
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
	public function testAreEqualObject():Void
	{
		var obj:Dynamic = { };
		Assert.areEqual(obj, obj);
		try 
		{
			Assert.areEqual({ }, obj);
		}
		catch (e:AssertionException) 
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function testAreEqualNumber():Void
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
	public function testAreEqualEnum():Void
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
	public function testAreEqualEnumWithParam():Void
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
	public function testAreNotEqualString():Void
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
	public function testAreNotEqualObject():Void
	{
		var obj:Dynamic = { };
		Assert.areNotEqual({}, obj);
		try 
		{
			Assert.areNotEqual(obj, obj);
		}
		catch (e:AssertionException) 
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function testAreNotEqualNumber():Void
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
	public function testAreNotEqualEnum():Void
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
	public function testAreNotEqualEnumWithParam():Void
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

	public function testAreSameString():Void
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
	public function testAreSameObject():Void
	{
		var obj:Dynamic = {};
		Assert.areSame(obj, obj);
		try
		{
			Assert.areSame({}, obj);
		}
		catch (e:AssertionException)
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}

	@Test
	public function testAreSameNumber():Void
	{
		Assert.areSame(1, 1);
		try
		{
			Assert.areSame(1, 2);
		}
		catch (e:AssertionException)
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}

	@Test
	public function testAreSameEnum():Void
	{
		Assert.areSame(ValueA, ValueA);
		try
		{
			Assert.areSame(ValueA, ValueB);
		}
		catch (e:AssertionException)
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}

	@Test
	public function testAreSameEnumWithParam():Void
	{
		var e = ValueC("foo");
		Assert.areSame(e, e);
		try
		{
			Assert.areSame(e, ValueC("foo"));
		}
		catch (e:AssertionException)
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}

	@Test
	public function testAreNotSameString():Void
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
	public function testAreNotSameObject():Void
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
	public function testAreNotSameNumber():Void
	{
		Assert.areNotSame(1, 2);
		try
		{
			Assert.areNotSame(1, 1);
		}
		catch (e:AssertionException)
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}

	@Test
	public function testAreNotSameEnum():Void
	{
		Assert.areNotSame(ValueA, ValueB);
		try
		{
			Assert.areNotSame(ValueA, ValueA);
		}
		catch (e:AssertionException)
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}

	@Test
	public function testAreNotSameEnumWithParam():Void
	{
		Assert.areNotSame(ValueC("foo"), ValueC("foo"));
		try
		{
			var e = ValueC("foo");
			Assert.areNotSame(e, e);
		}
		catch (e:AssertionException)
		{
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}

	@Test
	public function testFail():Void
	{
		try 
		{
			Assert.fail("failure message");
		}
		catch (e:AssertionException) 
		{
			Assert.areEqual("failure message", e.message); 
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}
	
	@Test
	public function testThrowsStringAndObject():Void
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
	public function testThrowsFailsIfWrongExceptionTypeThrown():Void
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
