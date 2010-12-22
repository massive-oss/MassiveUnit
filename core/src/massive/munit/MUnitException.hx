package massive.munit;
import haxe.PosInfos;

/**
 * Base exception type for all exceptions raised by munit.
 * 
 * @author Mike Stead
 */
class MUnitException 
{
	/**
	 * The exception type.
	 */
	public var type(default, null):String;
	
	/**
	 * The message describing the exception.
	 */
	public var message(default, null):String;
	
	/**
	 * The pos infos from where the exception was thrown.
	 */
	public var info(default, null):PosInfos;
	
	/**
	 * Class constructor.
	 * 
	 * @param	message			a description of the exception
	 * @param	info			pos infos from where the exception was thrown
	 */
	public function new(message:String, ?info:PosInfos) 
	{
		type = here.className;
		this.message = message;
		this.info = info;
	}
	
	/**
	 * Returns a string representation of this exception.
	 * 
	 * @return a string representation of this exception
	 */
	public function toString():String
	{
		var str:String = type + ": ";
		if (info == null) str += message;
		else str += message + " at " + info.className + "#" + info.methodName + " (" + info.lineNumber + ")";
		return str;
	}
}