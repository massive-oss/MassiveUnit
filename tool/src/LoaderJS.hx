import js.Lib;
class LoaderJS
{
	public static function main():LoaderJS { return new LoaderJS(); }
	
	public var isFlashRunner:Bool;
	
	public function new()
	{
		Lib.window.onload = loadHandler;
		isFlashRunner = false;
	}
	
	private function touchMoveHandler(event)
	{
		event.preventDefault();
	}
	
	private function loadHandler(event)
	{
		untyped Lib.document.body.ontouchmove = touchMoveHandler;		
		var agent = Lib.window.navigator.userAgent;
		initialiseApp();
	}

	private function initialiseApp():Void
	{
		var hasFlash = SWFObject.getFlashPlayerVersion().major >= 10;
		var rnd:Float = Date.now().getTime();
		
		if (isFlashRunner)
		{
			if(hasFlash == false)
			{
				trace("Error - flash player 10 not detected " + SWFObject.getFlashPlayerVersion());
				return;
			}
	
			var app = Lib.document.createElement('div');
			Lib.document.body.appendChild(app);
			app.id = "flash";
			SWFObject.embedSWF("test.swf?" + rnd, "flash", "1024", "768", "10.1.0", {}, {}, {allowFullScreen:true, bgcolor:0, allowScriptAccess:"always", wmode:"transparent", scale:"noscale"});
			
		}
		else
		{
			var app = Lib.document.createElement('script');
			untyped app.type= 'text/javascript';
			untyped app.src =  "test.js?" + rnd;
			Lib.document.getElementsByTagName('head')[0].appendChild(app);
		}
	}

}