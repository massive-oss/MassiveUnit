package massive.munit;
import haxe.PosInfos;

/**
 * Exception thrown when a test triggers an exception in code which was not captured.
 * 
 * @author Mike Stead
 */
class UnhandledException extends MUnitException
{
	/**
	 * {@inheritDoc}
	 */
	public function new(message:String, info:PosInfos) 
	{
		super(message, info);
		type = here.className;
	}
}
