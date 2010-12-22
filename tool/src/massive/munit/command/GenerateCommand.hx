package massive.munit.command;

import massive.neko.io.File;
import massive.haxe.util.TemplateUtil;

class GenerateCommand extends MUnitCommand
{
	private var dir:File;
	private var hxml:File;
	
	public function new():Void
	{
		super();
	}
	
	override public function initialise():Void
	{
		var testSrcPath = console.getNextArg();
		
		if(testSrcPath == null)
		{
			dir = config.src;
			if(dir == null)
			{
				error("Default test src directory is not set. Please run munit config.");
			}
			
			
			if(!dir.exists)
			{
				error("Default test src directory does not exist (" + config.dir.getRelativePath(dir) + ").\nPlease run munit config or specify a <src> and <hxml> path");
			}
		}
		
		else
		{
			dir = File.create(testSrcPath, console.dir);
			if(!dir.exists)
			{
				error("test src directory does not exist (" + testSrcPath + ")");
			}
		}
		
		if(console.getOption("nohxml") == "true") return;
	
		//hxml
		var hxmlPath  = console.getNextArg();
		
		var defaultHxml:File = config.hxml;
		
		if(hxmlPath == null && defaultHxml == null)
		{
			error("Default hxml path is not set. Please run munit config or specify a hxml file path.");	
		}
		
		if(hxmlPath == null && !defaultHxml.exists )
		{
			hxmlPath = defaultHxml.nativePath;
		}
	
		if(hxmlPath != null)
		{
			hxml = File.create(hxmlPath, config.dir); 
			
			if(hxml == null)
			{
				error("Invalid hxml path " + hxmlPath);
			}	
		}
	}

	override public function execute():Void
	{
		var testMain:File = dir.resolvePath("TestMain.hx");
		var testMainTmp:File = dir.resolvePath("TestMain.tmp");
		var testSuite:File = dir.resolvePath("TestSuite.hx");
		var testExample:File = dir.resolvePath("ExampleTest.hx");
		
		var firstTime:Bool = !testMain.exists;
		
		var content:String;
			
		if(firstTime)
		{
			//create an example test class for reference
			content = TemplateUtil.getTemplate("test-example");
			testExample.writeString(content, true);
		}
		else
		{
			//remove existing files so they dont get added to the tests
			testMain.moveTo(testMainTmp);
			testSuite.deleteFile();
		}

		var files:Array<File> = dir.getRecursiveDirectoryListing(~/.*Test\.hx$/);
		var imports:String = "";
		var tests:String = "";
		var cls:String;
		
		for(file in files)
		{
			cls = dir.getRelativePath(file).substr(0, -3);
			cls = cls.split("/").join(".");

		//	print(cls);
			
			imports += "\nimport " + cls + ";";
			tests += "\n		add(" + cls + ");";
		}

		content = TemplateUtil.getTemplate("test-suite", {imports:imports,tests:tests});
		testSuite.writeString(content, true);
		
		if(firstTime)
		{
			content = TemplateUtil.getTemplate("test-main", {url:RunCommand.SERVER_URL});
			testMain.writeString(content, true);
		}
		else
		{
			testMainTmp.moveTo(testMain);	
		}
		
		if(hxml != null)
		{
			var src:String = config.src != null ? config.dir.getRelativePath(config.src) + "" : "";
			var bin:String = config.bin != null ? config.dir.getRelativePath(config.bin) + "": "";
			
			//write out stub hxml file
			content = TemplateUtil.getTemplate("test-hxml", {src:src, bin:bin});
			hxml.writeString(content, true);
			
		}
	}	
}
