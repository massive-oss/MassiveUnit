/****
* Copyright 2012 Massive Interactive. All rights reserved.
* 
* Redistribution and use in source and binary forms, with or without modification, are
* permitted provided that the following conditions are met:
* 
*    1. Redistributions of source code must retain the above copyright notice, this list of
*       conditions and the following disclaimer.
* 
*    2. Redistributions in binary form must reproduce the above copyright notice, this list
*       of conditions and the following disclaimer in the documentation and/or other materials
*       provided with the distribution.
* 
* THIS SOFTWARE IS PROVIDED BY MASSIVE INTERACTIVE ``AS IS'' AND ANY EXPRESS OR IMPLIED
* WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
* FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL MASSIVE INTERACTIVE OR
* CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
* CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
* ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
* ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
* 
* The views and conclusions contained in the software and documentation are those of the
* authors and should not be interpreted as representing official policies, either expressed
* or implied, of Massive Interactive.
****/

package massive.munit.client;

/**
Provides a high level summary report in text format

e.g.

result:true
count:49
count:7
pass:5
fail:2
error:0
ignore:2
time:1234.3

# className#method
# className#method
# className#method
# className#method
# className#method
# className#method
# className#method
# className#method
# className#method
# ... plus 5 more

*/
class SummaryReportClient extends AbstractTestResultClient
{
	public static var DEFAULT_ID:String = "summary";

	public function new()
	{
		super();
		id = DEFAULT_ID;
	}

	override function printFinalStatistics(result:Bool, testCount:Int, passCount:Int, failCount:Int, errorCount:Int, ignoreCount:Int, time:Float)
	{
		output = "";
		output += "result:" + result;
		output += "\ncount:" + testCount;
		output += "\npass:" + passCount;
		output += "\nfail:" + failCount;
		output += "\nerror:" + errorCount;
		output += "\nignore:" + ignoreCount;
		output += "\ntime:" + time;
		output += "\n";

		var resultCount = 0;

		while(totalResults.length > 0 && resultCount < 10)
		{
			var result = totalResults.shift();
			if(!result.passed)
			{
				output += "\n# " + result.location;
				resultCount ++;
			}
		}

		var remainder = (failCount + errorCount) - resultCount;

		if(remainder > 0)
		{
			output += "# ... plus " + remainder  + " more";
		}

	}

	override function printOverallResult(result:Bool)
	{
		//handled by printFinalStatistics		
	}


	override function printReports()
	{
		//not implemented 
	}

}
