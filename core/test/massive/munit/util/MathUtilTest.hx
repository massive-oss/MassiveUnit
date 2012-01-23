package massive.munit.util;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import massive.munit.util.MathUtil;

/**
* Auto generated MassiveUnit Test Class  for massive.munit.util.MathUtil 
*/
class MathUtilTest 
{
	var instance:MathUtil; 
	
	public function new() 
	{
		
	}
	
	@BeforeClass
	public function beforeClass():Void
	{
	}
	
	@AfterClass
	public function afterClass():Void
	{
	}
	
	@Before
	public function setup():Void
	{
	}
	
	@After
	public function tearDown():Void
	{
	}

	@Test
	public function testConstrutor()
	{
		instance = new MathUtil();
		Assert.isTrue(true);
	}
	
	
	@Test
	public function shouldRoundValue():Void
	{
		Assert.areEqual(1.44, MathUtil.round(1.444444, 2));
		Assert.areEqual(1.56, MathUtil.round(1.555555, 2));
		Assert.areEqual(1.55, MathUtil.round(1.5454, 2));

	}
}