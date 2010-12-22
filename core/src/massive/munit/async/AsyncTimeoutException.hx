package massive.munit.async;
import haxe.PosInfos;
import massive.munit.MUnitException;

/**
 * Exception thrown when a test makes an assertion which is incorrect.
 * 
 * @author Mike Stead
 */
class AsyncTimeoutException extends MUnitException
{
	/**
	 * {@inheritDoc}
	 */
	public function new(message:String, ?info:PosInfos) 
	{
		super(message, info);
		type = here.className;
	}
}