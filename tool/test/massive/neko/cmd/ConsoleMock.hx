package massive.sys.cmd;

import haxe.PosInfos;

class ConsoleMock extends Console
{
	private var mockArgs:Array<String>;
	
	public function new(?argsString:String, ?posInfos:PosInfos)
	{	
		if(argsString != null && argsString != "") mockArgs = argsString.split(" ");
		super();
	}
	
	override function parseArguments(a:Array<String>)
	{
		if(mockArgs != null) systemArgs = mockArgs.copy();
		super.parseArguments(systemArgs);
	}
	
	public var promptMsg:String;
	
	override public function prompt(promptMsg:String, rpad:Int = 0):String
	{
		this.promptMsg = promptMsg;
		return "mock";
	}
}