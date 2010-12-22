/****
* Copyright 2010 Massive Interactive. All rights reserved.
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
* 
****/



package massive.munit;

import haxe.rtti.Meta;

/**
 * A helper used to discover, and provide access to, the test and life cycle methods of a test class.
 * <p>
 * This object implements Iterable methods (http://haxe.org/ref/iterators) for iterating over the test 
 * cases it discovers in a class.
 * </p>
 * <p>
 * <code>for (test in testHelper){ ... }</code>
 * </p>
 * 
 * @author Mike Stead
 */

class TestClassHelper 
{
	/**
	 * Meta tag marking method to be called before all tests in a class.
	 */
	public inline static var META_TAG_BEFORE_CLASS:String = "BeforeClass";

	/**
	 * Meta tag marking method to be called after all tests in a class.
	 */
	public inline static var META_TAG_AFTER_CLASS:String = "AfterClass";
	
	/**
	 * Meta tag marking method to be called before each test in a class.
	 */
	public inline static var META_TAG_BEFORE:String = "Before";
	
	/**
	 * Meta tag marking method to be called after each test in a class.
	 */
	public inline static var META_TAG_AFTER:String = "After";

	/**
	 * Meta tag marking test method in class.
	 */
	public inline static var META_TAG_TEST:String = "Test";
		
	/**
	 * Param for META_TAG_TEST, marking test method in class as asynchronous.
	 */
	public inline static var META_PARAM_ASYNC_TEST:String = "Async";
	
	/**
	 * Array of all valid meta tags.
	 */
	public static var META_TAGS = [META_TAG_BEFORE_CLASS,
									META_TAG_AFTER_CLASS,
									META_TAG_BEFORE,
									META_TAG_AFTER,
									META_TAG_TEST];

	/**
	 * The type of the test class this helper is wrapping.
	 */
	public var type(default, null):Class<Dynamic>;
	
	/**
	 * The instance of the test class this helper is wrapping.
	 */
	public var test(default, null):Dynamic;
	
	/**
	 * The life cycle method to be called once, before tests in the class are executed.
	 */
	public var beforeClass(default, null):Dynamic;
	
	/**
	 * The life cycle method to be called once, after tests in the class are executed.
	 */
	public var afterClass(default, null):Dynamic;
	
	/**
	 * The life cycle method to be called once, before each test in the class is executed.
	 */
	public var before(default, null):Dynamic;
	
	/**
	 * The life cycle method to be called once, after each test in the class is executed.
	 */
	public var after(default, null):Dynamic;
	
	private var tests(default, null):Array<TestCaseData>;
	private var index(default, null):Int;
	private var className(default, null):String;

	/**
	 * Class constructor.
	 * 
	 * @param	type			type of test class this helper is wrapping
	 */
	public function new(type:Class<Dynamic>) 
	{
		this.type = type;
		tests = [];
		index = 0;
		className = Type.getClassName(type);
		
		// Assign empty function so we can call'em without worry about runtime errors
		beforeClass = nullFunc;
		afterClass = nullFunc;
		before = nullFunc;
		after = nullFunc;
		
		parse(type);
	}
	
	/**
	 * Check if there is another test in the iterable list of tests.
	 * 
	 * @return	true if there is one or more tests available, false if not.
	 */
	public function hasNext():Bool
	{
		return index < tests.length;
	}
	
	/**
	 * Returns the next test in the iterable list of tests.
	 * 
	 * @return	if another test is available it's returned, otherwise returns null
	 */
	public function next():Dynamic
	{
		return hasNext() ? tests[index++] : null;
	}
	
	/**
	 * Get the current test in the iterable list of tests.
	 * 
	 * @return	current test in the iterable list of tests
	 */
	public function current():Dynamic
	{
		return (index <= 0) ? tests[0] : tests[index - 1];
	}
	
	private function parse(type:Class<Dynamic>):Void
	{		
		test = Type.createEmptyInstance(type);
		var fields:Array<String> = Type.getInstanceFields(type);
		var meta:Dynamic = Meta.getFields(type);
		
		if (meta == null) return;
		
		for (field in fields)
		{
			var f:Dynamic = Reflect.field(test, field);
			
			if (Reflect.isFunction(f) && Reflect.hasField(meta, field))
			{
				var funcMeta:Dynamic = Reflect.field(meta, field);
				for (tag in META_TAGS)
				{
					if (Reflect.hasField(funcMeta, tag))
					{
						var args:Array<String> = Reflect.field(funcMeta, tag);
						
						switch(tag)
						{
							case META_TAG_BEFORE_CLASS:
								beforeClass = f;
							case META_TAG_AFTER_CLASS:
								afterClass = f;
							case META_TAG_BEFORE:
								before = f;
							case META_TAG_AFTER:
								after = f;
							case META_TAG_TEST:
								var result:TestResult = new TestResult();
								result.async = (args != null && args[0] == META_PARAM_ASYNC_TEST);
								result.className = className;
								result.name = field;
								var data:TestCaseData = { test:f, scope:test, result:result };
								tests.push(data);
						}
					}
				}
			}
		}
		
		tests.sort(sortTestsByName);
	}
	
	private function sortTestsByName(x:TestCaseData, y:TestCaseData):Int
	{
		if (x.result.name == y.result.name) return 0;
		if (x.result.name > y.result.name) return 1;
		else return -1;
	}
	
	private function nullFunc():Void
	{}
}

typedef TestCaseData =
{
	var test:Dynamic;
	var scope:Dynamic;
	var result:TestResult;
}