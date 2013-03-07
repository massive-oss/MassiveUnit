package massive.sys.cmd;

import massive.sys.io.FileSys;
import haxe.PosInfos;

class ConsoleMock extends Console
{
	private var mockArgs:Array<String>;
	
	public function new(?argsString:String=null, ?posInfos:PosInfos):Void
	{	
		if(argsString != null && argsString != "")
		{
			mockArgs = argsString.split(" ");
		}
		
		super();
	
	}
	
	
	override private function parseArguments(a:Array<String>):Void
	{
		if(mockArgs != null)
		{
			systemArgs = mockArgs.concat([]);
		}
		
		super.parseArguments(systemArgs);
	}
	
	
	public var promptMsg:String;
	
	override public function prompt(promptMsg:String, rpad:Int=0):String
	{
		this.promptMsg = promptMsg;
		return "mock";
	}

	
}