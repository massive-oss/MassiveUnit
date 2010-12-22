package massive.munit.async;
import haxe.PosInfos;
import massive.munit.MUnitException;

/**
 * Exception thrown when an asynchronous test does not create an AsyncDelegate.
 * 
 * @author Mike Stead
 */
class MissingAsyncDelegateException extends MUnitException
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
