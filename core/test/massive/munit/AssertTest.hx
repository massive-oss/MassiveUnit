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
	
	@test
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