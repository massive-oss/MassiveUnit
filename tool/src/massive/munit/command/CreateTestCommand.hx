package massive.munit.command;

import massive.haxe.log.Log;
import massive.sys.haxe.HaxeWrapper;
import massive.sys.io.File;
import massive.sys.io.FileSys;
import massive.sys.util.PathUtil;
import massive.munit.Config;
import massive.haxe.util.TemplateUtil;

class CreateTestCommand extends MUnitCommand
{
	var qualifiedTestName:String;
	var qualifiedClassName:String;
	
	public function new():Void
	{
		super();
	}

	override public function initialise():Void
	{
		qualifiedTestName = console.getNextArg();
		qualifiedClassName = console.getOption("for");

		if(qualifiedTestName == null)
		{
			if(qualifiedClassName == null)
			{
				error("Invalid or missing options. Please refer to help.");
				return;
			}
			qualifiedTestName = qualifiedClassName + "Test";
		}

		if(qualifiedClassName != null && (config.classPaths == null || config.classPaths.length == 0))
		{
			error("This command requires an update to your munit project settings. Please re-run 'munit config' to set target class paths (i.e. 'src')");
			return;

		}
	}

	override public function execute():Void
	{
		var packages = qualifiedTestName.split(".");
		var testName = packages.pop();
		var testPackage = packages.length > 0 ? packages.join(".") : "";

		var testFilePath = qualifiedTestName.split(".").join("/") + ".hx";


		var hasClass = qualifiedClassName != null;
		var classPackage:String = null;
		var className:String = null;
		var classFilePath:String = null;

		if(hasClass)
		{
			packages = qualifiedClassName.split(".");
			className = packages.pop();
			classPackage = packages.length > 0 ? packages.join("."): "";
			classFilePath = qualifiedClassName.split(".").join("/") + ".hx";
		}
		
		var testFile = File.create(testFilePath, config.src);

		if(!testFile.exists)
		{
			var props = {testName:testName, packageName:testPackage, hasClass:hasClass, qualifiedClassName:qualifiedClassName, className:className};


			var content = TemplateUtil.getTemplate("test-stub-test", props);
			testFile.writeString(content, true);
		}

		if(!hasClass) return;

		var classFile = File.create(classFilePath, config.classPaths[0]);

		if(!classFile.exists)
		{
			var props = {packageName:classPackage, className:className};

			var content = TemplateUtil.getTemplate("test-stub-class", props);
			classFile.writeString(content, true);
		}

	}
}