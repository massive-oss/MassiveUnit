import massive.munit.client.PrintClient;
import massive.munit.client.RichPrintClient;
import massive.munit.client.HTTPClient;
import massive.munit.client.JUnitReportClient;
import massive.munit.TestRunner;

#if js
import js.Lib;
import js.Dom;
#end

/**
 * Auto generated Test Application.
 * Refer to munit command line tool for more information (haxelib run munit)
 */
class TestMain
{
    static function main(){	new TestMain(); }

    public function new()
    {
        var suites = new Array<Class<massive.munit.TestSuite>>();
        suites.push(TestSuite);

        #if MCOVER
            var client = new m.cover.coverage.munit.client.MCoverPrintClient();
        #else
            var client = new RichPrintClient();
        #end

        var runner:TestRunner = new TestRunner(client);
        //runner.addResultClient(new HTTPClient(new JUnitReportClient()));
        runner.completionHandler = completionHandler;
        runner.run(suites);
    }

    /*
        updates the background color and closes the current browser
        for flash and html targets (useful for continous integration servers)
    */
    function completionHandler(successful:Bool):Void
    {
        try
        {
            #if flash
                flash.external.ExternalInterface.call("testResult", successful);
            #elseif js
                js.Lib.eval("testResult(" + successful + ");");
            #elseif neko
                neko.Sys.exit(0);
            #end
        }
        // if run from outside browser can get error which we can ignore
        catch (e:Dynamic)
        {
        }
    }
}
