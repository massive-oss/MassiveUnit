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

/**
 * @author Mike Stead
 */
class TestClassHelperTest 
{
	@Test
	public function testConstructor()
	{
		var helper:TestClassHelper = new TestClassHelper(TestClassStub);
		Assert.isNotNull(helper.test);
		Assert.isType(helper.test, TestClassStub);
		Assert.areEqual(helper.type, TestClassStub);
		
		Assert.areEqual(helper.beforeClass.length, 2);
		Assert.areEqual(helper.afterClass.length, 2);
		Assert.areEqual(helper.before.length, 2);
		Assert.areEqual(helper.after.length, 2);
		Assert.areEqual(helper.test.beforeClassSuper, helper.beforeClass[0]);
		Assert.areEqual(helper.test.afterClassSuper, helper.afterClass[1]);
		Assert.areEqual(helper.test.beforeSuper, helper.before[0]);
		Assert.areEqual(helper.test.afterSuper, helper.after[1]);
		Assert.areEqual(helper.test.beforeClass, helper.beforeClass[1]);
		Assert.areEqual(helper.test.afterClass, helper.afterClass[0]);
		Assert.areEqual(helper.test.before, helper.before[1]);
		Assert.areEqual(helper.test.after, helper.after[0]);
	}
	
	@Test
	public function testIterator()
	{
		var helper:TestClassHelper = new TestClassHelper(TestClassStub);
		Assert.isTrue(helper.hasNext());
		Assert.isNotNull(helper.current());
		Assert.areEqual(helper.test.exampleTestOne, helper.current().test);
		Assert.areEqual(helper.test.exampleTestOne, helper.next().test);
		Assert.areEqual(helper.test.exampleTestOne, helper.current().test);
		Assert.isFalse(helper.current().result.async);
		Assert.areEqual(helper.test, helper.current().scope);
		Assert.areEqual(helper.test.exampleTestTwo, helper.next().test);
		Assert.areEqual(helper.test.exampleTestTwo, helper.current().test);
		Assert.isTrue(helper.current().result.async);
		Assert.areEqual(helper.test, helper.current().scope);
		Assert.isFalse(helper.hasNext());
		Assert.isNull(helper.next());
	}
	
	@Test
	public function testIteratorDebug()
	{
		var helper:TestClassHelper = new TestClassHelper(TestClassStub, true);
		Assert.isTrue(helper.hasNext());
		Assert.isNotNull(helper.current());
		Assert.areEqual(helper.test.exampleTestOne, helper.current().test);
		Assert.areEqual(helper.test.exampleTestOne, helper.next().test);
		Assert.areEqual(helper.test.exampleTestOne, helper.current().test);
		Assert.isFalse(helper.current().result.async);
		Assert.areEqual(helper.test, helper.current().scope);
		Assert.areEqual(helper.test.exampleTestThree, helper.next().test);
		Assert.areEqual(helper.test.exampleTestThree, helper.current().test);
		Assert.isFalse(helper.current().result.async);
		Assert.areEqual(helper.test, helper.current().scope);
		Assert.isFalse(helper.hasNext());
		Assert.isNull(helper.next());
	}
}
