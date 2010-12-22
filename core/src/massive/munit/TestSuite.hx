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
