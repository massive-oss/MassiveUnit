package massive.munit;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.sys.io.File;

class ConfigTest 
{
	private var dir:File;
	private var configFile:File;
	
	public function new() 
	{
		
	}
	
	@BeforeClass
	public function beforeClass():Void
	{
	}
	
	@AfterClass
	public function afterClass():Void
	{
	}
	
	@Before
	public function setup():Void
	{
		dir = File.current.resolveDirectory("tmpConfig", true);
		configFile = dir.resolveFile(".munit");
	}
	
	@After
	public function tearDown():Void
	{
		dir.deleteDirectory();
	}
	
	@Test
	public function testConstructor():Void
	{
		var config:Config = new Config(dir, "1.1");
		Assert.isFalse(config.exists);
		Assert.areEqual(dir.nativePath, config.dir.nativePath);
	
		Assert.isNull(config.src);
		Assert.isNull(config.bin);
		Assert.isNull(config.report);
		Assert.isNull(config.hxml);
		Assert.isNull(config.configVersion);
		Assert.areEqual("1.1", config.currentVersion);
		
		//with config file
		var str = createMockConfigString();
		configFile.writeString(str);
		var config:Config = new Config(dir, "1.1");
		
		Assert.isTrue(config.exists);
		Assert.areEqual(dir.resolveDirectory("src").nativePath, config.src.nativePath);
		Assert.areEqual(dir.resolveDirectory("bin").nativePath, config.bin.nativePath);
		Assert.areEqual(dir.resolveDirectory("report").nativePath, config.report.nativePath);
		Assert.areEqual(dir.resolveFile("test.hxml").nativePath, config.hxml.nativePath);
		Assert.areEqual("1.0", config.configVersion);
	}

	@Test
	public function testRemove():Void
	{
		var str = createMockConfigString();
	
		configFile.writeString(str);
		
		var config:Config = new Config(dir, "1.1");
		
		Assert.isTrue(config.exists);
		Assert.areEqual(dir.resolveDirectory("src").nativePath, config.src.nativePath);
		Assert.areEqual(dir.resolveDirectory("bin").nativePath, config.bin.nativePath);
		Assert.areEqual(dir.resolveDirectory("report").nativePath, config.report.nativePath);
		Assert.areEqual(dir.resolveFile("test.hxml").nativePath, config.hxml.nativePath);
		Assert.areEqual("1.0", config.configVersion);
		
		config.remove();
		
		Assert.isNull(config.src);
		Assert.isNull(config.bin);
		Assert.isNull(config.report);
		Assert.isNull(config.hxml);
		Assert.isNull(config.configVersion);
	}
	
	@Test
	public function testCreateDefault():Void
	{
		var altSrc:File = dir.resolveDirectory("test2");
		var altBin:File = dir.resolveDirectory("bin2");
		var altReport:File = dir.resolveDirectory("report2");
		var altHxml:File = dir.resolveDirectory("test2.hxml");
		var config:Config = new Config(dir, "1.1");
		
		config.createDefault();
		
		Assert.isTrue(config.exists);
		Assert.areEqual(dir.resolveDirectory("test").nativePath, config.src.nativePath);
		Assert.areEqual(dir.resolveDirectory("bin").nativePath, config.bin.nativePath);
		Assert.areEqual(dir.resolveDirectory("report").nativePath, config.report.nativePath);
		Assert.areEqual(dir.resolveFile("test.hxml").nativePath, config.hxml.nativePath);
		Assert.areEqual("1.1", config.configVersion);
		
		config.remove();
		
		var config:Config = new Config(dir, "1.1");
		config.createDefault(altSrc, altBin, altReport, altHxml);

		Assert.isTrue(config.exists);
		Assert.areEqual(altSrc.nativePath, config.src.nativePath);
		Assert.areEqual(altBin.nativePath, config.bin.nativePath);
		Assert.areEqual(altReport.nativePath, config.report.nativePath);
		Assert.areEqual(altHxml.nativePath, config.hxml.nativePath);
	
		config.remove();
	}
	
	
	@Test
	public function testUpdateSrc():Void
	{
		var altDir:File = dir.resolveDirectory("test2");
		var config:Config = new Config(dir, "1.1");
		
		Assert.isFalse(config.exists);
		Assert.isNull(config.src);
		
		try
		{
			config.updateSrc(altDir);
			Assert.fail("Expected error because dir doesn't exists");
		}
		catch(e:Dynamic)
		{
			Assert.isTrue(true);
		}

		altDir.createDirectory();
		config.updateSrc(altDir);
		
		Assert.isTrue(config.exists);
		Assert.areEqual(altDir.nativePath, config.src.nativePath);
		
		var altFile:File = dir.resolveFile("tmp.file");
		altFile.createFile("temp");
		
		try
		{
			config.updateSrc(altFile);
			Assert.fail("Expected error because file isn't a directory");
		}
		catch(e:Dynamic)
		{
			Assert.isTrue(true);
		}
	}
	
	@Test
	public function testUpdateBin():Void
	{
		var altDir:File = dir.resolveDirectory("bin");
		var config:Config = new Config(dir, "1.1");
		
		Assert.isFalse(config.exists);
		Assert.isNull(config.bin);
		
		try
		{
			config.updateBin(altDir);
			Assert.fail("Expected error because dir doesn't exists");
		}
		catch(e:Dynamic)
		{
			Assert.isTrue(true);
		}

		altDir.createDirectory();
		config.updateBin(altDir);
		
		Assert.isTrue(config.exists);
		Assert.areEqual(altDir.nativePath, config.bin.nativePath);
		
		var altFile:File = dir.resolveFile("tmp.file");
		altFile.createFile("temp");
		
		try
		{
			config.updateBin(altFile);
			Assert.fail("Expected error because file isn't a directory");
		}
		catch(e:Dynamic)
		{
			Assert.isTrue(true);
		}
	}
	
	@Test
	public function testUpdateReport():Void
	{
		var altDir:File = dir.resolveDirectory("report");
	
		var config:Config = new Config(dir, "1.1");
		
		Assert.isFalse(config.exists);
		Assert.isNull(config.report);
		
		try
		{
			config.updateReport(altDir);
			Assert.fail("Expected error because dir doesn't exists");
		}
		catch(e:Dynamic)
		{
			Assert.isTrue(true);
		}

		altDir.createDirectory();
		config.updateReport(altDir);
		Assert.isTrue(config.exists);
		Assert.areEqual(altDir.nativePath, config.report.nativePath);
		
		var altFile:File = dir.resolveFile("tmp.file");
		altFile.createFile("temp");
		
		try
		{
			config.updateReport(altFile);
			Assert.fail("Expected error because file isn't a directory");
		}
		catch(e:Dynamic)
		{
			Assert.isTrue(true);
		}
	}
	
	@Test
	public function testUpdateHxml():Void
	{
		var altDir:File = dir.resolveDirectory("dir");
		var altFile:File = dir.resolveFile("test.hxml");
		var config:Config = new Config(dir, "1.1");
		
		Assert.isFalse(config.exists);
		Assert.isNull(config.hxml);
		
		config.updateHxml(altFile);
		Assert.isNotNull(config.hxml);
		
		try
		{
			config.updateHxml(altDir);
			Assert.fail("Expected error because hxml is directory not file");
		}
		catch(e:Dynamic)
		{
			Assert.isTrue(true);
		}
	}
	
	@Test
	public function testToString():Void
	{
		var str = createMockConfigString();
		configFile.writeString(str);
		var config:Config = new Config(dir, "1.1");
		str = StringTools.replace(str, "1.0", "1.1");
		var lines = str.split("\n");

		var str = "";
		for(line in lines)
		{
			if(line.indexOf("#") == 0) continue;
			if(str != "") str += "\n";
			str += line;
		}
		Assert.areEqual(str, config.toString());	
	}

	////////
	function createMockConfigString():String
	{
		var str:String = "";
		str += "version=1.0\n";
		str += "#this is a comment\n";
		str += "src=src\n";
		str += "bin=bin\n";
		str += "report=report\n";
		str += "hxml=test.hxml\n";
		str += "classPaths=src\n";
		return str;
	}
	
	
}