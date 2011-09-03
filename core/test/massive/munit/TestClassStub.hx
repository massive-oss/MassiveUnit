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
import massive.munit.async.AsyncFactory;
import massive.munit.util.Timer;

/**
 * ...
 * @author Mike Stead
 */

class TestClassStub 
{
	public function new() 
	{}
	
	@BeforeClass
	public function beforeClass():Void
	{
	}
	
	@AfterClass
	public function afterClass():Void
	{
	}
	
	@Before
	public function before():Void
	{
	}
	
	@After
	public function after():Void
	{
	}
	
	@Test
	@TestDebug
	public function exampleTestOne():Void
	{
		Assert.isTrue(false);
	}
	
	@AsyncTest
	public function exampleTestTwo(factory:AsyncFactory):Void
	{
		var handler:Dynamic = factory.createHandler(this, onExampleTestTwo, 200);
		Timer.delay(handler, 100);
	}
	
	private function onExampleTestTwo():Void
	{
		Assert.isTrue(true);
	}
	
	@TestDebug
	public function exampleTestThree():Void
	{
		Assert.isTrue(true);
	}
}
