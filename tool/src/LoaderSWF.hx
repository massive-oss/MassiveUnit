class LoaderSWF extends LoaderJS
{
	public static function main():LoaderSWF { return new LoaderSWF(); }
	
	public function new()
	{
		super();
		isFlashRunner = true;
	}


}