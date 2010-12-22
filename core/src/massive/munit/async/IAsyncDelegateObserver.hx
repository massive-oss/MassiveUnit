package massive.munit.async;

/**
 * Interface which observers of an AsyncDelegate should implement.
 * 
 * @author Mike Stead
 */
interface IAsyncDelegateObserver 
{
	/**
	 * Called when an AsyncDelegate being observed receives a successful asynchronous callback.
	 * 
	 * @param	delegate		delegate which received the successful callback
	 */
	function asyncExecuteHandler(delegate:AsyncDelegate):Void;
	
	/**
	 * Called when an AsyncDelegate being observed does not receive its asynchronous callback
	 * in the time allowed.
	 * 
	 * @param	delegate		delegate whose asynchronous callback timed out
	 */
	function asyncTimeoutHandler(delegate:AsyncDelegate):Void;
}