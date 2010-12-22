package massive.munit;
import haxe.PosInfos;

/**
 * Exception thrown when an assertion is made which is not correct.
 *  
 * @author Mike Stead
 * @see Assert
 */

class AssertionException extends MUnitException
{
	/**
	 * @param	msg				message describing the assertion which failed
	 * @param	info			pos infos of where the failing assertion was made
	 */
	public function new(msg:String, ?info:PosInfos) 
	{
		super(msg, info);
		type = here.className;
	}
}