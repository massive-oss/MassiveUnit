package massive.munit.util;

import massive.munit.Assert;
import massive.munit.util.MathUtil;

/**
* Auto generated MassiveUnit Test Class  for massive.munit.util.MathUtil 
*/
class MathUtilTest 
{
	public function new() {}
	
	@Test
	public function shouldRoundValue()
	{
		Assert.areEqual(1.44, MathUtil.round(1.444444, 2));
		Assert.areEqual(1.56, MathUtil.round(1.555555, 2));
		Assert.areEqual(1.55, MathUtil.round(1.5454, 2));
	}
}