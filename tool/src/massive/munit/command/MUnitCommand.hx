package massive.munit.command;

import massive.munit.Config;
import massive.neko.cmd.Command;

class MUnitCommand extends Command
{
	public var config:Config;

	
	public function new():Void
	{
		super();
	}
	
	/**
	* Called prior to running any dependency tasks.
	*  An opportunity to check/prompt for command line parameters
	*  prior to running the tasks. 
	*/
	override public function initialise():Void
	{
		super.initialise();
		

	}

	override public function execute():Void
	{
		super.execute();
	
	}

}
