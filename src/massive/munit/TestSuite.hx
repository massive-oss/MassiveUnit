/****
* Copyright 2013 Massive Interactive. All rights reserved.
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
****/

package massive.munit;

/**
 * Iterable (http://haxe.org/ref/iterators) suite of test classes.
 * <p>
 * Each class added to a test suite should contain one or more meta tagged methods which execute unit tests.
 * </p>
 * <pre>
 * class MathUtilTest
 * {
 *     @Test
 *     public function testAdd():Void
 *     {
 *         Assert.areEqual(2, MathUtil.add(1,1));
 *     }
 * }
 * 
 * class TestSuite extends massive.unit.TestSuite
 * {
 *     public function new()
 *     {
 *          add(MathUtilTest);
 *     }
 * }
 * </pre>
 * @author Mike Stead
 */
class TestSuite 
{
	/* Note that it was a considered design decision not to cater for the addition of individual
	 * test methods to a suite. The reason being that this was not a hugely common use-case from
	 * what we'd seen, and it allowed the framework (and tools around the framework) to be simplified.
	 */	

	private var tests:Array<Dynamic>;
	private var index:Int;
	
	/**
	 * Class constructor.
	 */
	public function new() 
	{
		tests = new Array<Dynamic>();
		index = 0;
	}
	
	/**
	 * Add a class which contains test methods.
	 * 
	 * @param	test			a class containing methods which execute tests
	 */
	public function add(test:Class<Dynamic>):Void
	{
		tests.push(test);
		sortTests();
	}
	
	/**
	 * Check to see if there is another test class in this iterable suite of test classes.
	 * 
	 * @return	true if there is another test class, false if not
	 */
	public function hasNext():Bool
	{
		return index < tests.length;
	}
	
	/**
	 * Get the next test class in this iterable suite of test classes.
	 * 
	 * @return	the next test class in the suite, or null if no more classes available
	 */
	public function next():Class<Dynamic>
	{
		return hasNext() ? tests[index++] : null;
	}
	
	/**
	 * Drop the iterator back one so next call to <code>next()</code> will return the
	 * same test class again.
	 */
	public function repeat():Void
	{
		if (index > 0) index--;
	}
	
	private function sortTests():Void
	{
		tests.sort(sortByName);
	}
	
	private function sortByName(x, y):Int
	{
		var xName:String = Type.getClassName(x);
		var yName:String = Type.getClassName(y);
		if (xName == yName) return 0;
		if (xName > yName) return 1;
		else return -1;
	}
}
