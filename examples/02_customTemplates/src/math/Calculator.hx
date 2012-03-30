package math;

import massive.munit.util.Timer;

class Calculator
{
	public function new():Void
	{}
	
	public function add(x:Int, y:Int):Int
	{
		return x + y;
	}
	
	public function addAsync(x:Int, y:Int, handler:Int -> Void):Void
	{
		Timer.delay(function() {
			handler(x + y);
		}, 100);
	}
}
