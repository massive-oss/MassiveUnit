package massive.munit;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.sys.io.File;

class ConfigMock 
{
	public var mockDir:File;
	public var mockConfigFile:File;
	
	public function new():Void
	{
		mockDir = File.createTempDirectory();
		mockConfigFile = createMockConfigFile();
		super(mockDir, currentVersion);
	}
	
	override private function createMockConfigFile():Void
	{
		var file:File = mockDir.dir.resolveFile(".munit");
		
		var str:String = "";
		str += "version=1.0";
		str += "\n#this is a comment";
		str += "\nsrc=src";
		str += "\nbin=bin";
		str += "\nreport=report";
		str += "\nclassPaths=src";
		str += "\nhxml=test.hxml";


		file.writeString(str);
	}
	
	public function deleteMock():Void
	{
		mockDir.deleteDirectory();
	}
}