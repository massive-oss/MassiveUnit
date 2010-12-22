package massive.munit;

/**
 * The value object which contains the result of a test.
 * 
 * @author Mike Stead
 */

class TestResult
{
	/**
	 * Whether the test passed or not.
	 */
	public var passed:Bool;
	
	/**
	 * The execution time of the test in milliseconds.
	 */
	public var executionTime:Float;
	
	/**
	 * The name of the test. This maps to the name of the test method.
	 */
	public var name:String;
	
	/**
	 * The name of the class (qualified with package) where the test is located.
	 */
	public var className:String;
	
	/**
	 * The fully qualified location of this test. (i.e. package.ClassName#method)
	 */
	public var location(get_location, null):String;
	private function get_location():String 
	{
		return (name == "" && className == "") ? "" : className + "#" + name;
	}

	/**
	 * Whether the test is asynchronous or not.
	 */
	public var async:Bool;
	
	/**
	 * If this test failed, the assertion exception that was captured.
	 */
	public var failure:AssertionException;
	
	/**
	 * If this test was erroneous, the error that was captured.
	 */
	public var error:Dynamic;

	/**
	 * Class constructor.
	 */
	public function new() 
	{
		passed = false;
		executionTime = 0.0;
		name = "";
		className = "";
		async = false;
		error = null;
		failure = null;
	}
}