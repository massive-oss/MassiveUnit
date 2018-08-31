/****
* Copyright 2017 Massive Interactive. All rights reserved.
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



package massive.munit;

/**
 * The value object which contains the result of a test.
 * 
 * @author Mike Stead
 */

class TestResult
{
	/**
	 * Whether the test passed or not.
	 */
	public var passed:Bool = false;
	
	/**
	 * The execution time of the test in milliseconds.
	 */
	public var executionTime:Float = 0.0;
	
	/**
	 * The name of the test. This maps to the name of the test method.
	 */
	public var name:String = "";
	
	/**
	 * The name of the class (qualified with package) where the test is located.
	 */
	public var className:String = "";
	
	/**
     * An optional description.
     */
	public var description:String = "";
	
	/**
	 * The fully qualified location of this test. (i.e. package.ClassName#method)
	 */
	public var location(get, null):String;
	function get_location():String 
	{
		return (name == "" && className == "") ? "" : className + "#" + name;
	}

	/**
	 * Whether the test is asynchronous or not.
	 */
	public var async:Bool = false;
	
	/**
     * Whether the test is ignored or not.
     */
    public var ignore:Bool = false;
	
	/**
	 * If this test failed, the assertion exception that was captured.
	 */
	public var failure:AssertionException;
	
	/**
	 * If this test was erroneous, the error that was captured.
	 */
	public var error:Dynamic;

	public var type(get, null):TestResultType;
	
	/**
	 * Class constructor.
	 */
	public function new() {}

	function get_type():TestResultType
	{
		if(error != null) return ERROR;
		if(failure != null) return FAIL;
		if(ignore) return IGNORE;
		if(passed) return PASS;
		return UNKNOWN;
	}

}

@:enum
abstract TestResultType(String) to String
{
	var UNKNOWN = "UNKNOWN";
	var PASS = "PASS";
	var FAIL = "FAIL";
	var ERROR = "ERROR";
	var IGNORE = "IGNORE";
}