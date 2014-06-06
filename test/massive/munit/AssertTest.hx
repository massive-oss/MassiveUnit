/**************************************** ****************************************
 * Copyright 2010 Massive Interactive. All rights reserved.
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
 */
package massive.munit;

import massive.munit.Assert;

/**
 * ...
 * @author Mike Stead
 */
class AssertTest 
{
	private static var PREFIX : String = "this is a test prefix";

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
	public function testIsTruePrefix():Void
	{
		Assert.isTrue(true, PREFIX);
		try 
		{
			Assert.isTrue(false, PREFIX);
		}
		catch (e:AssertionException) 
		{
			Assert.isTrue(StringTools.startsWith(e.message, PREFIX + " - "));
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
	public function testIsFalsePrefix():Void
	{
		Assert.isFalse(false, PREFIX);
		try 
		{
			Assert.isFalse(true, PREFIX);
		}
		catch (e:AssertionException) 
		{
			Assert.isTrue(StringTools.startsWith(e.message, PREFIX + " - "));
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
	public function testIsNullPrefix():Void
	{
		Assert.isNull(null, PREFIX);
		try 
		{
			Assert.isNull({}, PREFIX);
		}
		catch (e:AssertionException) 
		{
			Assert.isTrue(StringTools.startsWith(e.message, PREFIX + " - "));
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
	public function testIsNotNullPrefix():Void
	{
		Assert.isNotNull({}, PREFIX);
		try 
		{
			Assert.isNotNull(null, PREFIX);
		}
		catch (e:AssertionException) 
		{
			Assert.isTrue(StringTools.startsWith(e.message, PREFIX + " - "));
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
	public function testIsNaNPrefix():Void
	{
		Assert.isNaN(Math.NaN, PREFIX);
		try 
		{
			Assert.isNaN(1, PREFIX);
		}
		catch (e:AssertionException) 
		{
			Assert.isTrue(StringTools.startsWith(e.message, PREFIX + " - "));
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
	public function testIsNotNaNPrefix():Void
	{
		Assert.isNotNaN(1, PREFIX);
		try 
		{
			Assert.isNotNaN(Math.NaN, PREFIX);
		}
		catch (e:AssertionException) 
		{
			Assert.isTrue(StringTools.startsWith(e.message, PREFIX + " - "));
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
	public function testIsTypePrefix():Void
	{
		Assert.isType(1, Int, PREFIX);
		try 
		{
			Assert.isType(1, String, PREFIX);
		}
		catch (e:AssertionException) 
		{
			Assert.isTrue(StringTools.startsWith(e.message, PREFIX + " - "));
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
	public function testIsNotTypePrefix():Void
	{
		Assert.isNotType(1, String, PREFIX);
		try 
		{
			Assert.isNotType(1, Int, PREFIX);
		}
		catch (e:AssertionException) 
		{
			Assert.isTrue(StringTools.startsWith(e.message, PREFIX + " - "));
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
	public function testAreEqualStringPrefix():Void
	{
		Assert.areEqual("yoyo", "yoyo", PREFIX);
		try 
		{
			Assert.areEqual("", "yoyo", PREFIX);
		}
		catch (e:AssertionException) 
		{
			Assert.isTrue(StringTools.startsWith(e.message, PREFIX + " - "));
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
	public function testAreEqualObjectPrefix():Void
	{
		var obj:Dynamic = { };
		Assert.areEqual(obj, obj, PREFIX);
		try 
		{
			Assert.areEqual({ }, obj, PREFIX);
		}
		catch (e:AssertionException) 
		{
			Assert.isTrue(StringTools.startsWith(e.message, PREFIX + " - "));
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
	public function testAreEqualNumberPrefix():Void
	{
		Assert.areEqual(1, 1, PREFIX);
		try 
		{
			Assert.areEqual(1, 2, PREFIX);
		}
		catch (e:AssertionException) 
		{
			Assert.isTrue(StringTools.startsWith(e.message, PREFIX + " - "));
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
	public function testAreEqualEnumPrefix():Void
	{
		Assert.areEqual(ValueA, ValueA, PREFIX);
		try
		{
			Assert.areEqual(ValueA, ValueB, PREFIX);
		}
		catch (e:AssertionException)
		{
			Assert.isTrue(StringTools.startsWith(e.message, PREFIX + " - "));
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
	public function testAreEqualEnumWithParamPrefix():Void
	{
		Assert.areEqual(ValueC("foo"), ValueC("foo"), PREFIX);
		try
		{
			Assert.areEqual(ValueC("foo"), ValueC("bar"), PREFIX);
		}
		catch (e:AssertionException)
		{
			Assert.isTrue(StringTools.startsWith(e.message, PREFIX + " - "));
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
	public function testAreNotEqualStringPrefix():Void
	{
		Assert.areNotEqual("", "yoyo", PREFIX);
		try 
		{
			Assert.areNotEqual("yoyo", "yoyo", PREFIX);
		}
		catch (e:AssertionException) 
		{
			Assert.isTrue(StringTools.startsWith(e.message, PREFIX + " - "));
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
	public function testAreNotEqualObjectPrefix():Void
	{
		var obj:Dynamic = { };
		Assert.areNotEqual({}, obj, PREFIX);
		try 
		{
			Assert.areNotEqual(obj, obj, PREFIX);
		}
		catch (e:AssertionException) 
		{
			Assert.isTrue(StringTools.startsWith(e.message, PREFIX + " - "));
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
	public function testAreNotEqualNumberPrefix():Void
	{
		Assert.areNotEqual(1, 2, PREFIX);
		try 
		{
			Assert.areNotEqual(1, 1, PREFIX);
		}
		catch (e:AssertionException) 
		{
			Assert.isTrue(StringTools.startsWith(e.message, PREFIX + " - "));
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
	public function testAreNotEqualEnumPrefix():Void
	{
		Assert.areNotEqual(ValueA, ValueB, PREFIX);
		try
		{
			Assert.areNotEqual(ValueA, ValueA, PREFIX);
		}
		catch (e:AssertionException)
		{
			Assert.isTrue(StringTools.startsWith(e.message, PREFIX + " - "));
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

	@Test
	public function testAreNotEqualEnumWithParamPrefix():Void
	{
		Assert.areNotEqual(ValueC("foo"), ValueC("bar"), PREFIX);
		try
		{
			Assert.areNotEqual(ValueC("foo"), ValueC("foo"), PREFIX);
		}
		catch (e:AssertionException)
		{
			Assert.isTrue(StringTools.startsWith(e.message, PREFIX + " - "));
			return;
		}
		Assert.fail("Invalid assertion not captured");
	}

	@Test
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
	public function testAreSameStringPrefix():Void
	{
		Assert.areSame("yoyo", "yoyo", PREFIX);
		try
		{
			Assert.areEqual("", "yoyo", PREFIX);
		}
		catch (e:AssertionException)
		{
			Assert.isTrue(StringTools.startsWith(e.message, PREFIX + " - "));
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
	public function testAreSameObjectPrefix():Void
	{
		var obj:Dynamic = {};
		Assert.areSame(obj, obj, PREFIX);
		try
		{
			Assert.areSame({}, obj, PREFIX);
		}
		catch (e:AssertionException)
		{
			Assert.isTrue(StringTools.startsWith(e.message, PREFIX + " - "));
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
	public function testAreSameNumberPrefix():Void
	{
		Assert.areSame(1, 1, PREFIX);
		try
		{
			Assert.areSame(1, 2, PREFIX);
		}
		catch (e:AssertionException)
		{
			Assert.isTrue(StringTools.startsWith(e.message, PREFIX + " - "));
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
	public function testAreSameEnumPrefix():Void
	{
		Assert.areSame(ValueA, ValueA, PREFIX);
		try
		{
			Assert.areSame(ValueA, ValueB, PREFIX);
		}
		catch (e:AssertionException)
		{
			Assert.isTrue(StringTools.startsWith(e.message, PREFIX + " - "));
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
	public function testAreSameEnumWithParamPrefix():Void
	{
		var e = ValueC("foo");
		Assert.areSame(e, e, PREFIX);
		try
		{
			Assert.areSame(e, ValueC("foo"), PREFIX);
		}
		catch (e:AssertionException)
		{
			Assert.isTrue(StringTools.startsWith(e.message, PREFIX + " - "));
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
	public function testAreNotSameStringPrefix():Void
	{
		Assert.areNotSame("", "yoyo", PREFIX);
		try
		{
			Assert.areNotSame("yoyo", "yoyo", PREFIX);
		}
		catch (e:AssertionException)
		{
			Assert.isTrue(StringTools.startsWith(e.message, PREFIX + " - "));
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
	public function testAreNotSameObjectPrefix():Void
	{
		var obj:Dynamic = {};
		Assert.areNotSame({}, obj, PREFIX);
		try
		{
			Assert.areNotSame(obj, obj, PREFIX);
		}
		catch (e:AssertionException)
		{
			Assert.isTrue(StringTools.startsWith(e.message, PREFIX + " - "));
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
	public function testAreNotSameNumberPrefix():Void
	{
		Assert.areNotSame(1, 2, PREFIX);
		try
		{
			Assert.areNotSame(1, 1, PREFIX);
		}
		catch (e:AssertionException)
		{
			Assert.isTrue(StringTools.startsWith(e.message, PREFIX + " - "));
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
	public function testAreNotSameEnumPrefix():Void
	{
		Assert.areNotSame(ValueA, ValueB, PREFIX);
		try
		{
			Assert.areNotSame(ValueA, ValueA, PREFIX);
		}
		catch (e:AssertionException)
		{
			Assert.isTrue(StringTools.startsWith(e.message, PREFIX + " - "));
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
	public function testAreNotSameEnumWithParamPrefix():Void
	{
		Assert.areNotSame(ValueC("foo"), ValueC("foo"), PREFIX);
		try
		{
			var e = ValueC("foo");
			Assert.areNotSame(e, e, PREFIX);
		}
		catch (e:AssertionException)
		{
			Assert.isTrue(StringTools.startsWith(e.message, PREFIX + " - "));
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
}

private enum DummyEnum
{
	ValueA;
	ValueB;
	ValueC(param:String);
}
