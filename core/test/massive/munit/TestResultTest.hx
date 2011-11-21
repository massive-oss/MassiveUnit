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
import massive.haxe.util.ReflectUtil;
import massive.munit.TestResult;
/**
 * ...
 * @author Mike Stead
 */

class TestResultTest 
{
	public function new() 
	{}
	
	@Test
	public function testConstructor():Void
	{
		var result:TestResult = new TestResult();
		Assert.isFalse(result.passed);
		Assert.areEqual(0.0, result.executionTime);
		Assert.areEqual("", result.name);
		Assert.areEqual("", result.className);
		Assert.areEqual("", result.location);
		Assert.isFalse(result.async);
		Assert.isNull(result.error);
		Assert.isNull(result.failure);

		Assert.areEqual(TestResultType.UNKNOWN, result.type);
	}
	
	@Test
	public function testLocation():Void
	{
		var result:TestResult = new TestResult();
		var positionInfo = ReflectUtil.here();
		
		result.name = positionInfo.methodName;
		Assert.areEqual("#" + positionInfo.methodName, result.location);
		
		result = new TestResult();
		result.className = positionInfo.className;
		Assert.areEqual(positionInfo.className + "#", result.location);
		
		result = new TestResult();
		result.name = positionInfo.methodName;
		result.className = positionInfo.className;
		Assert.areEqual(positionInfo.className + "#" + positionInfo.methodName, result.location);
	}

	@Test
	public function testType()
	{
		var result:TestResult = new TestResult();
		Assert.areEqual(TestResultType.UNKNOWN, result.type);

		result.passed = true;
		Assert.areEqual(TestResultType.PASS, result.type);

		result.ignore = true;
		Assert.areEqual(TestResultType.IGNORE, result.type);

		result.failure = new AssertionException("fail");
		Assert.areEqual(TestResultType.FAIL, result.type);

		result.error = "error";
		Assert.areEqual(TestResultType.ERROR, result.type);
	}
}
