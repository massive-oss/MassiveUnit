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
 * ...
 * @author Mike Stead
 */

class TestSuiteTest 
{
	private var suite:massive.munit.TestSuite;

	public function new() 
	{}
	
	@Before
	public function setup():Void
	{
		suite = new massive.munit.TestSuite();
	}
	
	@After
	public function tearDown():Void
	{
		suite = null;
	}
	
	@Test
	public function testConstructor():Void
	{
		Assert.isFalse(suite.hasNext());
	}
	
	@Test
	public function testAdd():Void
	{
		suite.add(TestSuiteTest);
		Assert.isTrue(suite.hasNext());
	}
	
	@Test
	public function testIterator():Void
	{
		suite.add(TestSuiteTest);
		suite.add(TestRunnerTest);
		
		Assert.isTrue(suite.hasNext());		
		Assert.areEqual(TestRunnerTest, suite.next());
		Assert.isTrue(suite.hasNext());
		Assert.areEqual(TestSuiteTest, suite.next());
		Assert.isFalse(suite.hasNext());
		
		suite.repeat();

		Assert.isTrue(suite.hasNext());
		Assert.areEqual(TestSuiteTest, suite.next());
	}
}
