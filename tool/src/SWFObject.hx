extern class SWFObject
{
	public static function getFlashPlayerVersion():Dynamic;
	public static function getQueryParamValue(param:String):Dynamic;
	public static function embedSWF(path:String, id:String, width:Dynamic, height:Dynamic, version:String,
									attributes:Dynamic, flashvars:Dynamic, params:Dynamic):Void;
}