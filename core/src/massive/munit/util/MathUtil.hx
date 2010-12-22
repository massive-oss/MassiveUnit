package massive.munit.util;

/**
 * Utility class for math related operations.
 * 
 * @author Mike Stead
 */
class MathUtil 
{
	public function new() 
	{}
	
	/**
	 * Round a floating point number to a given decimal place.
	 * 
	 * @param	value			number to round up
	 * @param	precision		precision to round the value to
	 * @return	the rounded value
	 */
	public static function round(value:Float, precision:Int):Float
	{
		value = value * Math.pow(10, precision);
		return Math.round(value) / Math.pow(10, precision);
	}	
}