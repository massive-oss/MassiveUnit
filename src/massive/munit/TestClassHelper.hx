/****
* Copyright 2013 Massive Interactive. All rights reserved.
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
     * Meta tag marking asynchronous test method in class.
     */
	public inline static var META_TAG_ASYNC_TEST:String = "AsyncTest";
	
	/**
     * Meta tag marking a test method to ignore.
     */
    public inline static var META_TAG_IGNORE:String = "Ignore";
		
	/**
	 * Param for META_TAG_TEST, marking test method in class as asynchronous.
     *
     * @deprecated As of 0.9.1.4, use @AsyncTest instead.
	 */
	public inline static var META_PARAM_ASYNC_TEST:String = "Async";
	
	/**
	 * Meta tag marking test method in class for execution in debug mode only.
	 */
	public inline static var META_TAG_TEST_DEBUG:String = "TestDebug";
	
	/**
	 * Array of all valid meta tags.
	 */
	public static var META_TAGS = [META_TAG_BEFORE_CLASS,
									META_TAG_AFTER_CLASS,
									META_TAG_BEFORE,
									META_TAG_AFTER,
									META_TAG_TEST,
									META_TAG_ASYNC_TEST,
									META_TAG_TEST_DEBUG];

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
	
	private var tests:Array<TestCaseData>;
	private var index:Int;
	public var className(default, null):String;
	private var isDebug:Bool;

	/**
	 * Class constructor.
	 * 
	 * @param	type			type of test class this helper is wrapping
	 */
	public function new(type:Class<Dynamic>, ?isDebug:Bool=false) 
	{
		this.type = type;
		this.isDebug = isDebug;
		tests = [];
		index = 0;
		className = Type.getClassName(type);
		
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
		
		var inherintanceChain = getInheritanceChain(type);
		var fieldMeta = collateFieldMeta(inherintanceChain);
		scanForTests(fieldMeta);
		tests.sort(sortTestsByName); // not pc as allows for possible test dependencies but useful for report consistency
	}
		
	function getInheritanceChain(clazz:Class<Dynamic>):Array<Class<Dynamic>>
	{
		var inherintanceChain = [clazz];
		while ((clazz = Type.getSuperClass(clazz)) != null)
			inherintanceChain.push(clazz);
		return inherintanceChain;
	}
	
	function collateFieldMeta(inherintanceChain:Array<Class<Dynamic>>):Dynamic
	{
		var meta = {};
		while (inherintanceChain.length > 0)
		{
			var clazz = inherintanceChain.pop(); // start at root
			var newMeta = Meta.getFields(clazz);			
			var markedFieldNames = Reflect.fields(newMeta);
			
			for (fieldName in markedFieldNames)
			{
				var recordedFieldTags = Reflect.field(meta, fieldName);
				var newFieldTags = Reflect.field(newMeta, fieldName);
				
				var newTagNames = Reflect.fields(newFieldTags);
				if (recordedFieldTags == null)
				{
					// need to create copy of tags as may need to remove
					// some later and this could impact other tests which
					// extends the same class.
					var tagsCopy = {};
					for (tagName in newTagNames)
						Reflect.setField(tagsCopy, tagName, Reflect.field(newFieldTags, tagName));
						
					Reflect.setField(meta, fieldName, tagsCopy);
				}
				else
				{
					var ignored = false;
					for (tagName in newTagNames)
					{
						if (tagName == META_TAG_IGNORE)
							ignored = true;
						
						// TODO: Support @TestDebug ignore scenarios too. ms 4.9.2011
						
						// @Test in subclass takes precendence over @Ignore in parent
						if (!ignored && (tagName == META_TAG_TEST || 
										tagName == META_TAG_ASYNC_TEST) && 
										Reflect.hasField(recordedFieldTags, META_TAG_IGNORE))
							Reflect.deleteField(recordedFieldTags, META_TAG_IGNORE);
						
						var tagValue = Reflect.field(newFieldTags, tagName);
						Reflect.setField(recordedFieldTags, tagName, tagValue);
					}
				}
			}
		}
		return meta;
	}
	
	function scanForTests(fieldMeta:Dynamic)
	{
		var fieldNames = Reflect.fields(fieldMeta);
		for (fieldName in fieldNames)
		{
			var f:Dynamic = Reflect.field(test, fieldName);
			if (Reflect.isFunction(f))
			{
				var funcMeta:Dynamic = Reflect.field(fieldMeta, fieldName);
				searchForMatchingTags(fieldName, f, funcMeta);
			}
		}
	}
	
	function searchForMatchingTags(fieldName:String, func:Dynamic, funcMeta:Dynamic)
	{
		for (tag in META_TAGS)
		{
			if (Reflect.hasField(funcMeta, tag))
			{
				var args:Array<String> = Reflect.field(funcMeta, tag);
				var description = (args != null) ? args[0] : "";
				var isAsync = (args != null && description == META_PARAM_ASYNC_TEST); // deprecated support for @Test("Async")
				var isIgnored = Reflect.hasField(funcMeta, META_TAG_IGNORE);
				
				if (isAsync) 
				{
					description = "";
				}
				else if (isIgnored)
				{
					args = Reflect.field(funcMeta, META_TAG_IGNORE);
					description = (args != null) ? args[0] : "";
				}
				
				switch(tag)
				{
					case META_TAG_BEFORE_CLASS:
						beforeClass = func;
					case META_TAG_AFTER_CLASS:
						afterClass = func;
					case META_TAG_BEFORE:
						before = func;
					case META_TAG_AFTER:
						after = func;
					case META_TAG_ASYNC_TEST:
						if (!isDebug)
							addTest(fieldName, func, test, true, isIgnored, description);
					case META_TAG_TEST:
						if (!isDebug)
							addTest(fieldName, func, test, isAsync, isIgnored, description);
					case META_TAG_TEST_DEBUG:
						if (isDebug)
							addTest(fieldName, func, test, isAsync, isIgnored, description);
				}
			}
		}
	}
	
	private function addTest(field:String, 
							testFunction:Dynamic, 
							testInstance:Dynamic, 
							isAsync:Bool, 
							isIgnored:Bool, 
							description:String):Void
	{
		var result:TestResult = new TestResult();
		result.async = isAsync;
		result.ignore = isIgnored;
		result.className = className;
		result.description = description;
		result.name = field;
		var data:TestCaseData = { test:testFunction, scope:testInstance, result:result };
		tests.push(data);
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