$estr = function() { return js.Boot.__string_rec(this,''); }
Item = function(p) { if( p === $_ ) return; {
	null;
}}
Item.__name__ = ["Item"];
Item.prototype.__class__ = Item;
ItemMock = function(p) { if( p === $_ ) return; {
	Item.apply(this,[]);
}}
ItemMock.__name__ = ["ItemMock"];
ItemMock.__super__ = Item;
for(var k in Item.prototype ) ItemMock.prototype[k] = Item.prototype[k];
ItemMock.prototype.__class__ = ItemMock;
if(typeof haxe=='undefined') haxe = {}
haxe.StackItem = { __ename__ : ["haxe","StackItem"], __constructs__ : ["CFunction","Module","FilePos","Method","Lambda"] }
haxe.StackItem.CFunction = ["CFunction",0];
haxe.StackItem.CFunction.toString = $estr;
haxe.StackItem.CFunction.__enum__ = haxe.StackItem;
haxe.StackItem.FilePos = function(s,file,line) { var $x = ["FilePos",2,s,file,line]; $x.__enum__ = haxe.StackItem; $x.toString = $estr; return $x; }
haxe.StackItem.Lambda = function(v) { var $x = ["Lambda",4,v]; $x.__enum__ = haxe.StackItem; $x.toString = $estr; return $x; }
haxe.StackItem.Method = function(classname,method) { var $x = ["Method",3,classname,method]; $x.__enum__ = haxe.StackItem; $x.toString = $estr; return $x; }
haxe.StackItem.Module = function(m) { var $x = ["Module",1,m]; $x.__enum__ = haxe.StackItem; $x.toString = $estr; return $x; }
haxe.Stack = function() { }
haxe.Stack.__name__ = ["haxe","Stack"];
haxe.Stack.callStack = function() {
	return haxe.Stack.makeStack("$s");
}
haxe.Stack.exceptionStack = function() {
	return haxe.Stack.makeStack("$e");
}
haxe.Stack.toString = function(stack) {
	var b = new StringBuf();
	{
		var _g = 0;
		while(_g < stack.length) {
			var s = stack[_g];
			++_g;
			b.b[b.b.length] = "\nCalled from ";
			haxe.Stack.itemToString(b,s);
		}
	}
	return b.b.join("");
}
haxe.Stack.itemToString = function(b,s) {
	var $e = (s);
	switch( $e[1] ) {
	case 0:
	{
		b.b[b.b.length] = "a C function";
	}break;
	case 1:
	var m = $e[2];
	{
		b.b[b.b.length] = "module ";
		b.b[b.b.length] = m;
	}break;
	case 2:
	var line = $e[4], file = $e[3], s1 = $e[2];
	{
		if(s1 != null) {
			haxe.Stack.itemToString(b,s1);
			b.b[b.b.length] = " (";
		}
		b.b[b.b.length] = file;
		b.b[b.b.length] = " line ";
		b.b[b.b.length] = line;
		if(s1 != null) b.b[b.b.length] = ")";
	}break;
	case 3:
	var meth = $e[3], cname = $e[2];
	{
		b.b[b.b.length] = cname;
		b.b[b.b.length] = ".";
		b.b[b.b.length] = meth;
	}break;
	case 4:
	var n = $e[2];
	{
		b.b[b.b.length] = "local function #";
		b.b[b.b.length] = n;
	}break;
	}
}
haxe.Stack.makeStack = function(s) {
	var a = (function($this) {
		var $r;
		try {
			$r = eval(s);
		}
		catch( $e0 ) {
			{
				var e = $e0;
				$r = [];
			}
		}
		return $r;
	}(this));
	var m = new Array();
	{
		var _g1 = 0, _g = a.length - (s == "$s"?2:0);
		while(_g1 < _g) {
			var i = _g1++;
			var d = a[i].split("::");
			m.unshift(haxe.StackItem.Method(d[0],d[1]));
		}
	}
	return m;
}
haxe.Stack.prototype.__class__ = haxe.Stack;
if(typeof massive=='undefined') massive = {}
if(!massive.munit) massive.munit = {}
if(!massive.munit.async) massive.munit.async = {}
massive.munit.async.AsyncDelegate = function(testCase,handler,timeout,info) { if( testCase === $_ ) return; {
	var self = this;
	this.testCase = testCase;
	this.handler = handler;
	this.delegateHandler = Reflect.makeVarArgs($closure(this,"responseHandler"));
	this.info = info;
	this.params = [];
	this.timedOut = false;
	if(timeout == null || timeout <= 0) timeout = 400;
	this.timeoutDelay = timeout;
	this.timer = massive.munit.util.Timer.delay($closure(this,"timeoutHandler"),this.timeoutDelay);
}}
massive.munit.async.AsyncDelegate.__name__ = ["massive","munit","async","AsyncDelegate"];
massive.munit.async.AsyncDelegate.prototype.delegateHandler = null;
massive.munit.async.AsyncDelegate.prototype.handler = null;
massive.munit.async.AsyncDelegate.prototype.info = null;
massive.munit.async.AsyncDelegate.prototype.observer = null;
massive.munit.async.AsyncDelegate.prototype.params = null;
massive.munit.async.AsyncDelegate.prototype.responseHandler = function(params) {
	if(this.timedOut) return;
	this.timer.stop();
	if(params == null) params = [];
	this.params = params;
	if(this.observer != null) this.observer.asyncResponseHandler(this);
}
massive.munit.async.AsyncDelegate.prototype.runTest = function() {
	this.handler.apply(this.testCase,this.params);
}
massive.munit.async.AsyncDelegate.prototype.testCase = null;
massive.munit.async.AsyncDelegate.prototype.timedOut = null;
massive.munit.async.AsyncDelegate.prototype.timeoutDelay = null;
massive.munit.async.AsyncDelegate.prototype.timeoutHandler = function() {
	this.handler = null;
	this.delegateHandler = null;
	this.timedOut = true;
	if(this.observer != null) this.observer.asyncTimeoutHandler(this);
}
massive.munit.async.AsyncDelegate.prototype.timer = null;
massive.munit.async.AsyncDelegate.prototype.__class__ = massive.munit.async.AsyncDelegate;
massive.munit.MUnitException = function(message,info) { if( message === $_ ) return; {
	this.type = { fileName : "MUnitException.hx", lineNumber : 65, className : "massive.munit.MUnitException", methodName : "new"}.className;
	this.message = message;
	this.info = info;
}}
massive.munit.MUnitException.__name__ = ["massive","munit","MUnitException"];
massive.munit.MUnitException.prototype.info = null;
massive.munit.MUnitException.prototype.message = null;
massive.munit.MUnitException.prototype.toString = function() {
	var str = this.type + ": ";
	if(this.info == null) str += this.message;
	else str += ((((((this.message + " at ") + this.info.className) + "#") + this.info.methodName) + " (") + this.info.lineNumber) + ")";
	return str;
}
massive.munit.MUnitException.prototype.type = null;
massive.munit.MUnitException.prototype.__class__ = massive.munit.MUnitException;
massive.munit.UnhandledException = function(message,info) { if( message === $_ ) return; {
	massive.munit.MUnitException.apply(this,[message,info]);
	this.type = { fileName : "UnhandledException.hx", lineNumber : 48, className : "massive.munit.UnhandledException", methodName : "new"}.className;
}}
massive.munit.UnhandledException.__name__ = ["massive","munit","UnhandledException"];
massive.munit.UnhandledException.__super__ = massive.munit.MUnitException;
for(var k in massive.munit.MUnitException.prototype ) massive.munit.UnhandledException.prototype[k] = massive.munit.MUnitException.prototype[k];
massive.munit.UnhandledException.prototype.__class__ = massive.munit.UnhandledException;
massive.munit.TestClassHelper = function(type) { if( type === $_ ) return; {
	this.type = type;
	this.tests = [];
	this.index = 0;
	this.className = Type.getClassName(type);
	this.beforeClass = $closure(this,"nullFunc");
	this.afterClass = $closure(this,"nullFunc");
	this.before = $closure(this,"nullFunc");
	this.after = $closure(this,"nullFunc");
	this.parse(type);
}}
massive.munit.TestClassHelper.__name__ = ["massive","munit","TestClassHelper"];
massive.munit.TestClassHelper.prototype.after = null;
massive.munit.TestClassHelper.prototype.afterClass = null;
massive.munit.TestClassHelper.prototype.before = null;
massive.munit.TestClassHelper.prototype.beforeClass = null;
massive.munit.TestClassHelper.prototype.className = null;
massive.munit.TestClassHelper.prototype.current = function() {
	return ((this.index <= 0)?this.tests[0]:this.tests[this.index - 1]);
}
massive.munit.TestClassHelper.prototype.hasNext = function() {
	return this.index < this.tests.length;
}
massive.munit.TestClassHelper.prototype.index = null;
massive.munit.TestClassHelper.prototype.next = function() {
	return (this.hasNext()?this.tests[this.index++]:null);
}
massive.munit.TestClassHelper.prototype.nullFunc = function() {
	null;
}
massive.munit.TestClassHelper.prototype.parse = function(type) {
	this.test = Type.createEmptyInstance(type);
	var fields = Type.getInstanceFields(type);
	var meta = haxe.rtti.Meta.getFields(type);
	if(meta == null) return;
	{
		var _g = 0;
		while(_g < fields.length) {
			var field = fields[_g];
			++_g;
			var f = Reflect.field(this.test,field);
			if(Reflect.isFunction(f) && Reflect.hasField(meta,field)) {
				var funcMeta = Reflect.field(meta,field);
				{
					var _g1 = 0, _g2 = massive.munit.TestClassHelper.META_TAGS;
					while(_g1 < _g2.length) {
						var tag = _g2[_g1];
						++_g1;
						if(Reflect.hasField(funcMeta,tag)) {
							var args = Reflect.field(funcMeta,tag);
							switch(tag) {
							case "BeforeClass":{
								this.beforeClass = f;
							}break;
							case "AfterClass":{
								this.afterClass = f;
							}break;
							case "Before":{
								this.before = f;
							}break;
							case "After":{
								this.after = f;
							}break;
							case "Test":{
								var result = new massive.munit.TestResult();
								result.async = (args != null && args[0] == "Async");
								result.className = this.className;
								result.name = field;
								var data = { test : f, scope : this.test, result : result}
								this.tests.push(data);
							}break;
							}
						}
					}
				}
			}
		}
	}
	this.tests.sort($closure(this,"sortTestsByName"));
}
massive.munit.TestClassHelper.prototype.sortTestsByName = function(x,y) {
	if(x.result.name == y.result.name) return 0;
	if(x.result.name > y.result.name) return 1;
	else return -1;
}
massive.munit.TestClassHelper.prototype.test = null;
massive.munit.TestClassHelper.prototype.tests = null;
massive.munit.TestClassHelper.prototype.type = null;
massive.munit.TestClassHelper.prototype.__class__ = massive.munit.TestClassHelper;
if(!massive.munit.util) massive.munit.util = {}
massive.munit.util.MathUtil = function(p) { if( p === $_ ) return; {
	null;
}}
massive.munit.util.MathUtil.__name__ = ["massive","munit","util","MathUtil"];
massive.munit.util.MathUtil.round = function(value,precision) {
	value = value * Math.pow(10,precision);
	return Math.round(value) / Math.pow(10,precision);
}
massive.munit.util.MathUtil.prototype.__class__ = massive.munit.util.MathUtil;
massive.munit.async.IAsyncDelegateObserver = function() { }
massive.munit.async.IAsyncDelegateObserver.__name__ = ["massive","munit","async","IAsyncDelegateObserver"];
massive.munit.async.IAsyncDelegateObserver.prototype.asyncResponseHandler = null;
massive.munit.async.IAsyncDelegateObserver.prototype.asyncTimeoutHandler = null;
massive.munit.async.IAsyncDelegateObserver.prototype.__class__ = massive.munit.async.IAsyncDelegateObserver;
massive.munit.TestRunner = function(resultClient) { if( resultClient === $_ ) return; {
	this.clients = new Array();
	this.addResultClient(resultClient);
	this.set_asyncFactory(this.createAsyncFactory());
	this.running = false;
}}
massive.munit.TestRunner.__name__ = ["massive","munit","TestRunner"];
massive.munit.TestRunner.prototype.activeHelper = null;
massive.munit.TestRunner.prototype.addResultClient = function(resultClient) {
	{
		var _g = 0, _g1 = this.clients;
		while(_g < _g1.length) {
			var client = _g1[_g];
			++_g;
			if(client == resultClient) return;
		}
	}
	resultClient.set_completeHandler($closure(this,"clientCompletionHandler"));
	this.clients.push(resultClient);
}
massive.munit.TestRunner.prototype.asyncFactory = null;
massive.munit.TestRunner.prototype.asyncPending = null;
massive.munit.TestRunner.prototype.asyncResponseHandler = function(delegate) {
	var testCaseData = this.activeHelper.current();
	testCaseData.test = $closure(delegate,"runTest");
	testCaseData.scope = delegate;
	this.asyncPending = false;
	this.executeTestCase(testCaseData,false);
	this.activeHelper.after();
	this.execute();
}
massive.munit.TestRunner.prototype.asyncTimeoutHandler = function(delegate) {
	var testCaseData = this.activeHelper.current();
	var result = testCaseData.result;
	result.executionTime = massive.munit.util.Timer.stamp() - this.testStartTime;
	result.error = new massive.munit.async.AsyncTimeoutException("",delegate.info);
	this.asyncPending = false;
	this.errorCount++;
	{
		var _g = 0, _g1 = this.clients;
		while(_g < _g1.length) {
			var c = _g1[_g];
			++_g;
			c.addError(result);
		}
	}
	this.activeHelper.after();
	this.execute();
}
massive.munit.TestRunner.prototype.clientCompleteCount = null;
massive.munit.TestRunner.prototype.clientCompletionHandler = function(resultClient) {
	if(++this.clientCompleteCount == this.clients.length) {
		if(this.completionHandler != null) {
			var successful = (this.passCount == this.testCount);
			this.completionHandler(successful);
		}
		this.running = false;
	}
}
massive.munit.TestRunner.prototype.clientCount = null;
massive.munit.TestRunner.prototype.clients = null;
massive.munit.TestRunner.prototype.completionHandler = null;
massive.munit.TestRunner.prototype.createAsyncFactory = function() {
	return new massive.munit.async.AsyncFactory(this);
}
massive.munit.TestRunner.prototype.emptyParams = null;
massive.munit.TestRunner.prototype.errorCount = null;
massive.munit.TestRunner.prototype.execute = function() {
	{
		var _g1 = this.suiteIndex, _g = this.testSuites.length;
		while(_g1 < _g) {
			var i = _g1++;
			var suite = this.testSuites[i];
			{ var $it0 = suite;
			while( $it0.hasNext() ) { var testClass = $it0.next();
			{
				if(this.activeHelper == null || this.activeHelper.type != testClass) {
					this.activeHelper = new massive.munit.TestClassHelper(testClass);
					this.activeHelper.beforeClass.apply(this.activeHelper.test,this.emptyParams);
				}
				this.executeTestCases();
				if(!this.asyncPending) {
					this.activeHelper.afterClass.apply(this.activeHelper.test,this.emptyParams);
				}
				else {
					suite.repeat();
					this.suiteIndex = i;
					return;
				}
			}
			}}
		}
	}
	if(!this.asyncPending) {
		var time = massive.munit.util.Timer.stamp() - this.startTime;
		{
			var _g = 0, _g1 = this.clients;
			while(_g < _g1.length) {
				var client = _g1[_g];
				++_g;
				client.reportFinalStatistics(this.testCount,this.passCount,this.failCount,this.errorCount,time);
			}
		}
	}
}
massive.munit.TestRunner.prototype.executeTestCase = function(testCaseData,async) {
	var result = testCaseData.result;
	try {
		var assertionCount = massive.munit.Assert.assertionCount;
		if(async) {
			var delegateCount = this.asyncFactory.asyncDelegateCount;
			testCaseData.test.apply(testCaseData.scope,[this.asyncFactory]);
			if(this.asyncFactory.asyncDelegateCount == delegateCount) {
				throw new massive.munit.async.MissingAsyncDelegateException("No AsyncDelegate was created in async test at " + result.get_location(),null);
			}
			if(massive.munit.Assert.assertionCount > assertionCount) {
				throw new massive.munit.AssertionException("Assertion(s) were made before async test returned at " + result.get_location(),null);
			}
			this.asyncPending = true;
		}
		else {
			testCaseData.test.apply(testCaseData.scope,this.emptyParams);
			if(massive.munit.Assert.assertionCount > assertionCount) {
				result.passed = true;
				result.executionTime = massive.munit.util.Timer.stamp() - this.testStartTime;
				this.passCount++;
				{
					var _g = 0, _g1 = this.clients;
					while(_g < _g1.length) {
						var c = _g1[_g];
						++_g;
						c.addPass(result);
					}
				}
			}
			else {
				throw new massive.munit.AssertionException("No assertions made in test case at " + result.get_location(),null);
			}
		}
	}
	catch( $e0 ) {
		if( js.Boot.__instanceof($e0,massive.munit.AssertionException) ) {
			var ae = $e0;
			{
				result.executionTime = massive.munit.util.Timer.stamp() - this.testStartTime;
				result.failure = ae;
				this.failCount++;
				{
					var _g = 0, _g1 = this.clients;
					while(_g < _g1.length) {
						var c = _g1[_g];
						++_g;
						c.addFail(result);
					}
				}
			}
		} else {
			var e = $e0;
			{
				result.executionTime = massive.munit.util.Timer.stamp() - this.testStartTime;
				if(!Std["is"](e,massive.munit.MUnitException)) {
					e = new massive.munit.UnhandledException((e.toString() + " at ") + result.get_location(),null);
				}
				result.error = e;
				this.errorCount++;
				{
					var _g = 0, _g1 = this.clients;
					while(_g < _g1.length) {
						var c = _g1[_g];
						++_g;
						c.addError(result);
					}
				}
			}
		}
	}
}
massive.munit.TestRunner.prototype.executeTestCases = function() {
	{ var $it0 = this.activeHelper;
	while( $it0.hasNext() ) { var testCaseData = $it0.next();
	{
		this.testCount++;
		this.activeHelper.before.apply(this.activeHelper.test,[]);
		this.testStartTime = massive.munit.util.Timer.stamp();
		this.executeTestCase(testCaseData,testCaseData.result.async);
		if(!this.asyncPending) this.activeHelper.after.apply(this.activeHelper.test,this.emptyParams);
		else return;
	}
	}}
}
massive.munit.TestRunner.prototype.failCount = null;
massive.munit.TestRunner.prototype.get_clientCount = function() {
	return this.clients.length;
}
massive.munit.TestRunner.prototype.passCount = null;
massive.munit.TestRunner.prototype.run = function(testSuiteClasses) {
	if(this.running) return;
	this.running = true;
	this.asyncPending = false;
	this.testCount = 0;
	this.failCount = 0;
	this.errorCount = 0;
	this.passCount = 0;
	this.suiteIndex = 0;
	this.clientCompleteCount = 0;
	massive.munit.Assert.assertionCount = 0;
	this.emptyParams = new Array();
	this.testSuites = new Array();
	this.startTime = massive.munit.util.Timer.stamp();
	{
		var _g = 0;
		while(_g < testSuiteClasses.length) {
			var suiteType = testSuiteClasses[_g];
			++_g;
			this.testSuites.push(Type.createInstance(suiteType,new Array()));
		}
	}
	this.execute();
}
massive.munit.TestRunner.prototype.running = null;
massive.munit.TestRunner.prototype.set_asyncFactory = function(value) {
	if(value == this.asyncFactory) return value;
	if(this.running) throw new massive.munit.MUnitException("Can't change AsyncFactory while tests are running",{ fileName : "TestRunner.hx", lineNumber : 117, className : "massive.munit.TestRunner", methodName : "set_asyncFactory"});
	value.observer = this;
	return this.asyncFactory = value;
}
massive.munit.TestRunner.prototype.startTime = null;
massive.munit.TestRunner.prototype.suiteIndex = null;
massive.munit.TestRunner.prototype.testCount = null;
massive.munit.TestRunner.prototype.testStartTime = null;
massive.munit.TestRunner.prototype.testSuites = null;
massive.munit.TestRunner.prototype.__class__ = massive.munit.TestRunner;
massive.munit.TestRunner.__interfaces__ = [massive.munit.async.IAsyncDelegateObserver];
massive.munit.util.Timer = function(time_ms) { if( time_ms === $_ ) return; {
	this.id = massive.munit.util.Timer.arr.length;
	massive.munit.util.Timer.arr[this.id] = this;
	this.timerId = window.setInterval(("massive.munit.util.Timer.arr[" + this.id) + "].run();",time_ms);
}}
massive.munit.util.Timer.__name__ = ["massive","munit","util","Timer"];
massive.munit.util.Timer.delay = function(f,time_ms) {
	var t = new massive.munit.util.Timer(time_ms);
	t.run = function() {
		t.stop();
		f();
	}
	return t;
}
massive.munit.util.Timer.stamp = function() {
	return Date.now().getTime() / 1000;
}
massive.munit.util.Timer.prototype.id = null;
massive.munit.util.Timer.prototype.run = function() {
	null;
}
massive.munit.util.Timer.prototype.stop = function() {
	if(this.id == null) return;
	window.clearInterval(this.timerId);
	massive.munit.util.Timer.arr[this.id] = null;
	if(this.id > 100 && this.id == massive.munit.util.Timer.arr.length - 1) {
		var p = this.id - 1;
		while(p >= 0 && massive.munit.util.Timer.arr[p] == null) p--;
		massive.munit.util.Timer.arr = massive.munit.util.Timer.arr.slice(0,p + 1);
	}
	this.id = null;
}
massive.munit.util.Timer.prototype.timerId = null;
massive.munit.util.Timer.prototype.__class__ = massive.munit.util.Timer;
StringTools = function() { }
StringTools.__name__ = ["StringTools"];
StringTools.urlEncode = function(s) {
	return encodeURIComponent(s);
}
StringTools.urlDecode = function(s) {
	return decodeURIComponent(s.split("+").join(" "));
}
StringTools.htmlEscape = function(s) {
	return s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
}
StringTools.htmlUnescape = function(s) {
	return s.split("&gt;").join(">").split("&lt;").join("<").split("&amp;").join("&");
}
StringTools.startsWith = function(s,start) {
	return (s.length >= start.length && s.substr(0,start.length) == start);
}
StringTools.endsWith = function(s,end) {
	var elen = end.length;
	var slen = s.length;
	return (slen >= elen && s.substr(slen - elen,elen) == end);
}
StringTools.isSpace = function(s,pos) {
	var c = s.charCodeAt(pos);
	return (c >= 9 && c <= 13) || c == 32;
}
StringTools.ltrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,r)) {
		r++;
	}
	if(r > 0) return s.substr(r,l - r);
	else return s;
}
StringTools.rtrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,(l - r) - 1)) {
		r++;
	}
	if(r > 0) {
		return s.substr(0,l - r);
	}
	else {
		return s;
	}
}
StringTools.trim = function(s) {
	return StringTools.ltrim(StringTools.rtrim(s));
}
StringTools.rpad = function(s,c,l) {
	var sl = s.length;
	var cl = c.length;
	while(sl < l) {
		if(l - sl < cl) {
			s += c.substr(0,l - sl);
			sl = l;
		}
		else {
			s += c;
			sl += cl;
		}
	}
	return s;
}
StringTools.lpad = function(s,c,l) {
	var ns = "";
	var sl = s.length;
	if(sl >= l) return s;
	var cl = c.length;
	while(sl < l) {
		if(l - sl < cl) {
			ns += c.substr(0,l - sl);
			sl = l;
		}
		else {
			ns += c;
			sl += cl;
		}
	}
	return ns + s;
}
StringTools.replace = function(s,sub,by) {
	return s.split(sub).join(by);
}
StringTools.hex = function(n,digits) {
	var s = "";
	var hexChars = "0123456789ABCDEF";
	do {
		s = hexChars.charAt(n & 15) + s;
		n >>>= 4;
	} while(n > 0);
	if(digits != null) while(s.length < digits) s = "0" + s;
	return s;
}
StringTools.prototype.__class__ = StringTools;
Reflect = function() { }
Reflect.__name__ = ["Reflect"];
Reflect.hasField = function(o,field) {
	if(o.hasOwnProperty != null) return o.hasOwnProperty(field);
	var arr = Reflect.fields(o);
	{ var $it0 = arr.iterator();
	while( $it0.hasNext() ) { var t = $it0.next();
	if(t == field) return true;
	}}
	return false;
}
Reflect.field = function(o,field) {
	var v = null;
	try {
		v = o[field];
	}
	catch( $e0 ) {
		{
			var e = $e0;
			null;
		}
	}
	return v;
}
Reflect.setField = function(o,field,value) {
	o[field] = value;
}
Reflect.callMethod = function(o,func,args) {
	return func.apply(o,args);
}
Reflect.fields = function(o) {
	if(o == null) return new Array();
	var a = new Array();
	if(o.hasOwnProperty) {
		
				for(var i in o)
					if( o.hasOwnProperty(i) )
						a.push(i);
			;
	}
	else {
		var t;
		try {
			t = o.__proto__;
		}
		catch( $e0 ) {
			{
				var e = $e0;
				{
					t = null;
				}
			}
		}
		if(t != null) o.__proto__ = null;
		
				for(var i in o)
					if( i != "__proto__" )
						a.push(i);
			;
		if(t != null) o.__proto__ = t;
	}
	return a;
}
Reflect.isFunction = function(f) {
	return typeof(f) == "function" && f.__name__ == null;
}
Reflect.compare = function(a,b) {
	return ((a == b)?0:((((a) > (b))?1:-1)));
}
Reflect.compareMethods = function(f1,f2) {
	if(f1 == f2) return true;
	if(!Reflect.isFunction(f1) || !Reflect.isFunction(f2)) return false;
	return f1.scope == f2.scope && f1.method == f2.method && f1.method != null;
}
Reflect.isObject = function(v) {
	if(v == null) return false;
	var t = typeof(v);
	return (t == "string" || (t == "object" && !v.__enum__) || (t == "function" && v.__name__ != null));
}
Reflect.deleteField = function(o,f) {
	if(!Reflect.hasField(o,f)) return false;
	delete(o[f]);
	return true;
}
Reflect.copy = function(o) {
	var o2 = { }
	{
		var _g = 0, _g1 = Reflect.fields(o);
		while(_g < _g1.length) {
			var f = _g1[_g];
			++_g;
			o2[f] = Reflect.field(o,f);
		}
	}
	return o2;
}
Reflect.makeVarArgs = function(f) {
	return function() {
		var a = new Array();
		{
			var _g1 = 0, _g = arguments.length;
			while(_g1 < _g) {
				var i = _g1++;
				a.push(arguments[i]);
			}
		}
		return f(a);
	}
}
Reflect.prototype.__class__ = Reflect;
haxe.Log = function() { }
haxe.Log.__name__ = ["haxe","Log"];
haxe.Log.trace = function(v,infos) {
	js.Boot.__trace(v,infos);
}
haxe.Log.clear = function() {
	js.Boot.__clear_trace();
}
haxe.Log.prototype.__class__ = haxe.Log;
massive.munit.async.MissingAsyncDelegateException = function(message,info) { if( message === $_ ) return; {
	massive.munit.MUnitException.apply(this,[message,info]);
	this.type = { fileName : "MissingAsyncDelegateException.hx", lineNumber : 49, className : "massive.munit.async.MissingAsyncDelegateException", methodName : "new"}.className;
}}
massive.munit.async.MissingAsyncDelegateException.__name__ = ["massive","munit","async","MissingAsyncDelegateException"];
massive.munit.async.MissingAsyncDelegateException.__super__ = massive.munit.MUnitException;
for(var k in massive.munit.MUnitException.prototype ) massive.munit.async.MissingAsyncDelegateException.prototype[k] = massive.munit.MUnitException.prototype[k];
massive.munit.async.MissingAsyncDelegateException.prototype.__class__ = massive.munit.async.MissingAsyncDelegateException;
massive.munit.ITestResultClient = function() { }
massive.munit.ITestResultClient.__name__ = ["massive","munit","ITestResultClient"];
massive.munit.ITestResultClient.prototype.addError = null;
massive.munit.ITestResultClient.prototype.addFail = null;
massive.munit.ITestResultClient.prototype.addPass = null;
massive.munit.ITestResultClient.prototype.completionHandler = null;
massive.munit.ITestResultClient.prototype.id = null;
massive.munit.ITestResultClient.prototype.reportFinalStatistics = null;
massive.munit.ITestResultClient.prototype.__class__ = massive.munit.ITestResultClient;
if(!massive.munit.client) massive.munit.client = {}
massive.munit.client.HTTPClient = function(client,url,queueRequest,httpRequest) { if( client === $_ ) return; {
	if(queueRequest == null) queueRequest = true;
	this.id = "HTTPClient";
	this.client = client;
	this.url = url;
	this.queueRequest = queueRequest;
	this.httpRequest = httpRequest;
}}
massive.munit.client.HTTPClient.__name__ = ["massive","munit","client","HTTPClient"];
massive.munit.client.HTTPClient.dispatchNextRequest = function() {
	if(massive.munit.client.HTTPClient.responsePending || massive.munit.client.HTTPClient.queue.length == 0) return;
	massive.munit.client.HTTPClient.responsePending = true;
	var httpRequest = massive.munit.client.HTTPClient.queue.pop();
	httpRequest.setHeader("munit-requestId","" + massive.munit.client.HTTPClient.queue.length);
	httpRequest.request(true);
}
massive.munit.client.HTTPClient.prototype.addError = function(result) {
	this.client.addError(result);
}
massive.munit.client.HTTPClient.prototype.addFail = function(result) {
	this.client.addFail(result);
}
massive.munit.client.HTTPClient.prototype.addPass = function(result) {
	this.client.addPass(result);
}
massive.munit.client.HTTPClient.prototype.client = null;
massive.munit.client.HTTPClient.prototype.completionHandler = null;
massive.munit.client.HTTPClient.prototype.get_completeHandler = function() {
	return this.completionHandler;
}
massive.munit.client.HTTPClient.prototype.httpRequest = null;
massive.munit.client.HTTPClient.prototype.id = null;
massive.munit.client.HTTPClient.prototype.onData = function(data) {
	if(this.queueRequest) {
		massive.munit.client.HTTPClient.responsePending = false;
		massive.munit.client.HTTPClient.dispatchNextRequest();
	}
	if(this.get_completeHandler() != null) (this.get_completeHandler())(this);
}
massive.munit.client.HTTPClient.prototype.onError = function(msg) {
	if(this.queueRequest) {
		massive.munit.client.HTTPClient.responsePending = false;
		massive.munit.client.HTTPClient.dispatchNextRequest();
	}
	if(this.get_completeHandler() != null) (this.get_completeHandler())(this);
}
massive.munit.client.HTTPClient.prototype.platform = function() {
	return "js";
	return "unknown";
}
massive.munit.client.HTTPClient.prototype.queueRequest = null;
massive.munit.client.HTTPClient.prototype.reportFinalStatistics = function(testCount,passCount,failCount,errorCount,time) {
	var result = this.client.reportFinalStatistics(testCount,passCount,failCount,errorCount,time);
	this.sendResult(result);
	return result;
}
massive.munit.client.HTTPClient.prototype.sendResult = function(result) {
	if(this.httpRequest == null) {
		this.httpRequest = new haxe.Http(this.url);
		this.httpRequest.setHeader("munit-clientId",this.client.id);
		this.httpRequest.setHeader("munit-platformId",this.platform());
		this.httpRequest.onData = $closure(this,"onData");
		this.httpRequest.onError = $closure(this,"onError");
	}
	this.httpRequest.setParameter("data",result);
	if(this.queueRequest) {
		massive.munit.client.HTTPClient.queue.unshift(this.httpRequest);
		massive.munit.util.Timer.delay($closure(massive.munit.client.HTTPClient,"dispatchNextRequest"),50);
	}
	else this.httpRequest.request(true);
}
massive.munit.client.HTTPClient.prototype.set_completeHandler = function(value) {
	return this.completionHandler = value;
}
massive.munit.client.HTTPClient.prototype.url = null;
massive.munit.client.HTTPClient.prototype.__class__ = massive.munit.client.HTTPClient;
massive.munit.client.HTTPClient.__interfaces__ = [massive.munit.ITestResultClient];
massive.munit.Assert = function() { }
massive.munit.Assert.__name__ = ["massive","munit","Assert"];
massive.munit.Assert.isTrue = function(value,info) {
	massive.munit.Assert.assertionCount++;
	if(value != true) massive.munit.Assert.fail(("Expected TRUE but was [" + value) + "]",info);
}
massive.munit.Assert.isFalse = function(value,info) {
	massive.munit.Assert.assertionCount++;
	if(value != false) massive.munit.Assert.fail(("Expected FALSE but was [" + value) + "]",info);
}
massive.munit.Assert.isNull = function(value,info) {
	massive.munit.Assert.assertionCount++;
	if(value != null) massive.munit.Assert.fail(("Value [" + value) + "] was not NULL",info);
}
massive.munit.Assert.isNotNull = function(value,info) {
	massive.munit.Assert.assertionCount++;
	if(value == null) massive.munit.Assert.fail(("Value [" + value) + "] was NULL",info);
}
massive.munit.Assert.isNaN = function(value,info) {
	massive.munit.Assert.assertionCount++;
	if(!Math.isNaN(value)) massive.munit.Assert.fail(("Value [" + value) + "]  was not NaN",info);
}
massive.munit.Assert.isNotNaN = function(value,info) {
	massive.munit.Assert.assertionCount++;
	if(Math.isNaN(value)) massive.munit.Assert.fail(("Value [" + value) + "] was NaN",info);
}
massive.munit.Assert.isType = function(value,type) {
	massive.munit.Assert.assertionCount++;
	if(!Std["is"](value,type)) massive.munit.Assert.fail((("Value [" + value) + "] was not of type: ") + Type.getClassName(type),{ fileName : "Assert.hx", lineNumber : 129, className : "massive.munit.Assert", methodName : "isType"});
}
massive.munit.Assert.isNotType = function(value,type) {
	massive.munit.Assert.assertionCount++;
	if(Std["is"](value,type)) massive.munit.Assert.fail((("Value [" + value) + "] was of type: ") + Type.getClassName(type),{ fileName : "Assert.hx", lineNumber : 141, className : "massive.munit.Assert", methodName : "isNotType"});
}
massive.munit.Assert.areEqual = function(expected,actual,info) {
	massive.munit.Assert.assertionCount++;
	if(expected != actual) massive.munit.Assert.fail(((("Value [" + actual) + "] was not equal to expected value [") + expected) + "]",info);
}
massive.munit.Assert.areNotEqual = function(expected,actual,info) {
	massive.munit.Assert.assertionCount++;
	if(expected == actual) massive.munit.Assert.fail(((("Value [" + actual) + "] was equal to value [") + expected) + "]",info);
}
massive.munit.Assert.fail = function(msg,info) {
	throw new massive.munit.AssertionException(msg,info);
}
massive.munit.Assert.prototype.__class__ = massive.munit.Assert;
if(typeof sub=='undefined') sub = {}
sub.ItemTest = function(p) { if( p === $_ ) return; {
	Item.apply(this,[]);
	this.item = new ItemMock();
}}
sub.ItemTest.__name__ = ["sub","ItemTest"];
sub.ItemTest.__super__ = Item;
for(var k in Item.prototype ) sub.ItemTest.prototype[k] = Item.prototype[k];
sub.ItemTest.prototype.afterClass = function() {
	null;
}
sub.ItemTest.prototype.beforeClass = function() {
	null;
}
sub.ItemTest.prototype.item = null;
sub.ItemTest.prototype.setup = function() {
	null;
}
sub.ItemTest.prototype.tearDown = function() {
	null;
}
sub.ItemTest.prototype.testBlah = function() {
	massive.munit.Assert.isTrue(true,{ fileName : "ItemTest.hx", lineNumber : 47, className : "sub.ItemTest", methodName : "testBlah"});
}
sub.ItemTest.prototype.testConstructor = function() {
	massive.munit.Assert.isFalse(false,{ fileName : "ItemTest.hx", lineNumber : 41, className : "sub.ItemTest", methodName : "testConstructor"});
}
sub.ItemTest.prototype.__class__ = sub.ItemTest;
StringBuf = function(p) { if( p === $_ ) return; {
	this.b = new Array();
}}
StringBuf.__name__ = ["StringBuf"];
StringBuf.prototype.add = function(x) {
	this.b[this.b.length] = x;
}
StringBuf.prototype.addChar = function(c) {
	this.b[this.b.length] = String.fromCharCode(c);
}
StringBuf.prototype.addSub = function(s,pos,len) {
	this.b[this.b.length] = s.substr(pos,len);
}
StringBuf.prototype.b = null;
StringBuf.prototype.toString = function() {
	return this.b.join("");
}
StringBuf.prototype.__class__ = StringBuf;
massive.munit.AssertionException = function(msg,info) { if( msg === $_ ) return; {
	massive.munit.MUnitException.apply(this,[msg,info]);
	this.type = { fileName : "AssertionException.hx", lineNumber : 51, className : "massive.munit.AssertionException", methodName : "new"}.className;
}}
massive.munit.AssertionException.__name__ = ["massive","munit","AssertionException"];
massive.munit.AssertionException.__super__ = massive.munit.MUnitException;
for(var k in massive.munit.MUnitException.prototype ) massive.munit.AssertionException.prototype[k] = massive.munit.MUnitException.prototype[k];
massive.munit.AssertionException.prototype.__class__ = massive.munit.AssertionException;
SampleTest = function(p) { if( p === $_ ) return; {
	null;
}}
SampleTest.__name__ = ["SampleTest"];
SampleTest.prototype.afterClass = function() {
	null;
}
SampleTest.prototype.beforeClass = function() {
	null;
}
SampleTest.prototype.handler = null;
SampleTest.prototype.onTestConstructor = function() {
	massive.munit.Assert.isFalse(false,{ fileName : "SampleTest.hx", lineNumber : 56, className : "SampleTest", methodName : "onTestConstructor"});
}
SampleTest.prototype.setup = function() {
	null;
}
SampleTest.prototype.tearDown = function() {
	null;
}
SampleTest.prototype.testAsyncOperation = function(factory) {
	var handler = factory.createHandler(this,$closure(this,"onTestConstructor"),1000,{ fileName : "SampleTest.hx", lineNumber : 50, className : "SampleTest", methodName : "testAsyncOperation"});
	this.timer = massive.munit.util.Timer.delay(handler,200);
}
SampleTest.prototype.testConstructor = function() {
	massive.munit.Assert.isTrue(true,{ fileName : "SampleTest.hx", lineNumber : 44, className : "SampleTest", methodName : "testConstructor"});
}
SampleTest.prototype.timer = null;
SampleTest.prototype.__class__ = SampleTest;
TestMain = function(p) { if( p === $_ ) return; {
	var suites = new Array();
	suites.push(TestSuite);
	var runner = new massive.munit.TestRunner(new massive.munit.client.HTTPClient(new massive.munit.client.PrintClient(),"http://localhost:2000/"));
	runner.addResultClient(new massive.munit.client.HTTPClient(new massive.munit.client.JUnitReportClient(),"http://localhost:2000/"));
	runner.completionHandler = $closure(this,"completionHandler");
	runner.run(suites);
}}
TestMain.__name__ = ["TestMain"];
TestMain.main = function() {
	new TestMain();
}
TestMain.prototype.completionHandler = function(successful) {
	try {
		js.Lib.eval(("testResult(" + successful) + ");");
	}
	catch( $e0 ) {
		{
			var e = $e0;
			null;
		}
	}
}
TestMain.prototype.__class__ = TestMain;
massive.munit.async.AsyncTimeoutException = function(message,info) { if( message === $_ ) return; {
	massive.munit.MUnitException.apply(this,[message,info]);
	this.type = { fileName : "AsyncTimeoutException.hx", lineNumber : 49, className : "massive.munit.async.AsyncTimeoutException", methodName : "new"}.className;
}}
massive.munit.async.AsyncTimeoutException.__name__ = ["massive","munit","async","AsyncTimeoutException"];
massive.munit.async.AsyncTimeoutException.__super__ = massive.munit.MUnitException;
for(var k in massive.munit.MUnitException.prototype ) massive.munit.async.AsyncTimeoutException.prototype[k] = massive.munit.MUnitException.prototype[k];
massive.munit.async.AsyncTimeoutException.prototype.__class__ = massive.munit.async.AsyncTimeoutException;
IntIter = function(min,max) { if( min === $_ ) return; {
	this.min = min;
	this.max = max;
}}
IntIter.__name__ = ["IntIter"];
IntIter.prototype.hasNext = function() {
	return this.min < this.max;
}
IntIter.prototype.max = null;
IntIter.prototype.min = null;
IntIter.prototype.next = function() {
	return this.min++;
}
IntIter.prototype.__class__ = IntIter;
Std = function() { }
Std.__name__ = ["Std"];
Std["is"] = function(v,t) {
	return js.Boot.__instanceof(v,t);
}
Std.string = function(s) {
	return js.Boot.__string_rec(s,"");
}
Std["int"] = function(x) {
	if(x < 0) return Math.ceil(x);
	return Math.floor(x);
}
Std.parseInt = function(x) {
	var v = parseInt(x);
	if(Math.isNaN(v)) return null;
	return v;
}
Std.parseFloat = function(x) {
	return parseFloat(x);
}
Std.random = function(x) {
	return Math.floor(Math.random() * x);
}
Std.prototype.__class__ = Std;
massive.munit.TestSuite = function(p) { if( p === $_ ) return; {
	this.tests = new Array();
	this.index = 0;
}}
massive.munit.TestSuite.__name__ = ["massive","munit","TestSuite"];
massive.munit.TestSuite.prototype.add = function(test) {
	this.tests.push(test);
	this.sortTests();
}
massive.munit.TestSuite.prototype.hasNext = function() {
	return this.index < this.tests.length;
}
massive.munit.TestSuite.prototype.index = null;
massive.munit.TestSuite.prototype.next = function() {
	return (this.hasNext()?this.tests[this.index++]:null);
}
massive.munit.TestSuite.prototype.repeat = function() {
	if(this.index > 0) this.index--;
}
massive.munit.TestSuite.prototype.sortByName = function(x,y) {
	var xName = Type.getClassName(x);
	var yName = Type.getClassName(y);
	if(xName == yName) return 0;
	if(xName > yName) return 1;
	else return -1;
}
massive.munit.TestSuite.prototype.sortTests = function() {
	this.tests.sort($closure(this,"sortByName"));
}
massive.munit.TestSuite.prototype.tests = null;
massive.munit.TestSuite.prototype.__class__ = massive.munit.TestSuite;
TestSuite = function(p) { if( p === $_ ) return; {
	massive.munit.TestSuite.apply(this,[]);
	this.add(SampleTest);
	this.add(sub.ItemTest);
}}
TestSuite.__name__ = ["TestSuite"];
TestSuite.__super__ = massive.munit.TestSuite;
for(var k in massive.munit.TestSuite.prototype ) TestSuite.prototype[k] = massive.munit.TestSuite.prototype[k];
TestSuite.prototype.__class__ = TestSuite;
haxe.Http = function(url) { if( url === $_ ) return; {
	this.url = url;
	this.headers = new Hash();
	this.params = new Hash();
	this.async = true;
}}
haxe.Http.__name__ = ["haxe","Http"];
haxe.Http.requestUrl = function(url) {
	var h = new haxe.Http(url);
	h.async = false;
	var r = null;
	h.onData = function(d) {
		r = d;
	}
	h.onError = function(e) {
		throw e;
	}
	h.request(false);
	return r;
}
haxe.Http.prototype.async = null;
haxe.Http.prototype.headers = null;
haxe.Http.prototype.onData = function(data) {
	null;
}
haxe.Http.prototype.onError = function(msg) {
	null;
}
haxe.Http.prototype.onStatus = function(status) {
	null;
}
haxe.Http.prototype.params = null;
haxe.Http.prototype.postData = null;
haxe.Http.prototype.request = function(post) {
	var me = this;
	var r = new js.XMLHttpRequest();
	var onreadystatechange = function() {
		if(r.readyState != 4) return;
		var s = (function($this) {
			var $r;
			try {
				$r = r.status;
			}
			catch( $e0 ) {
				{
					var e = $e0;
					$r = null;
				}
			}
			return $r;
		}(this));
		if(s == undefined) s = null;
		if(s != null) me.onStatus(s);
		if(s != null && s >= 200 && s < 400) me.onData(r.responseText);
		else switch(s) {
		case null:{
			me.onError("Failed to connect or resolve host");
		}break;
		case 12029:{
			me.onError("Failed to connect to host");
		}break;
		case 12007:{
			me.onError("Unknown host");
		}break;
		default:{
			me.onError("Http Error #" + r.status);
		}break;
		}
	}
	if(this.async) r.onreadystatechange = onreadystatechange;
	var uri = this.postData;
	if(uri != null) post = true;
	else { var $it1 = this.params.keys();
	while( $it1.hasNext() ) { var p = $it1.next();
	{
		if(uri == null) uri = "";
		else uri += "&";
		uri += (StringTools.urlDecode(p) + "=") + StringTools.urlEncode(this.params.get(p));
	}
	}}
	try {
		if(post) r.open("POST",this.url,this.async);
		else if(uri != null) {
			var question = this.url.split("?").length <= 1;
			r.open("GET",(this.url + ((question?"?":"&"))) + uri,this.async);
			uri = null;
		}
		else r.open("GET",this.url,this.async);
	}
	catch( $e2 ) {
		{
			var e = $e2;
			{
				this.onError(e.toString());
				return;
			}
		}
	}
	if(this.headers.get("Content-Type") == null && post && this.postData == null) r.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
	{ var $it3 = this.headers.keys();
	while( $it3.hasNext() ) { var h = $it3.next();
	r.setRequestHeader(h,this.headers.get(h));
	}}
	r.send(uri);
	if(!this.async) onreadystatechange();
}
haxe.Http.prototype.setHeader = function(header,value) {
	this.headers.set(header,value);
}
haxe.Http.prototype.setParameter = function(param,value) {
	this.params.set(param,value);
}
haxe.Http.prototype.setPostData = function(data) {
	this.postData = data;
}
haxe.Http.prototype.url = null;
haxe.Http.prototype.__class__ = haxe.Http;
ValueType = { __ename__ : ["ValueType"], __constructs__ : ["TNull","TInt","TFloat","TBool","TObject","TFunction","TClass","TEnum","TUnknown"] }
ValueType.TBool = ["TBool",3];
ValueType.TBool.toString = $estr;
ValueType.TBool.__enum__ = ValueType;
ValueType.TClass = function(c) { var $x = ["TClass",6,c]; $x.__enum__ = ValueType; $x.toString = $estr; return $x; }
ValueType.TEnum = function(e) { var $x = ["TEnum",7,e]; $x.__enum__ = ValueType; $x.toString = $estr; return $x; }
ValueType.TFloat = ["TFloat",2];
ValueType.TFloat.toString = $estr;
ValueType.TFloat.__enum__ = ValueType;
ValueType.TFunction = ["TFunction",5];
ValueType.TFunction.toString = $estr;
ValueType.TFunction.__enum__ = ValueType;
ValueType.TInt = ["TInt",1];
ValueType.TInt.toString = $estr;
ValueType.TInt.__enum__ = ValueType;
ValueType.TNull = ["TNull",0];
ValueType.TNull.toString = $estr;
ValueType.TNull.__enum__ = ValueType;
ValueType.TObject = ["TObject",4];
ValueType.TObject.toString = $estr;
ValueType.TObject.__enum__ = ValueType;
ValueType.TUnknown = ["TUnknown",8];
ValueType.TUnknown.toString = $estr;
ValueType.TUnknown.__enum__ = ValueType;
Type = function() { }
Type.__name__ = ["Type"];
Type.getClass = function(o) {
	if(o == null) return null;
	if(o.__enum__ != null) return null;
	return o.__class__;
}
Type.getEnum = function(o) {
	if(o == null) return null;
	return o.__enum__;
}
Type.getSuperClass = function(c) {
	return c.__super__;
}
Type.getClassName = function(c) {
	var a = c.__name__;
	return a.join(".");
}
Type.getEnumName = function(e) {
	var a = e.__ename__;
	return a.join(".");
}
Type.resolveClass = function(name) {
	var cl;
	try {
		cl = eval(name);
	}
	catch( $e0 ) {
		{
			var e = $e0;
			{
				cl = null;
			}
		}
	}
	if(cl == null || cl.__name__ == null) return null;
	return cl;
}
Type.resolveEnum = function(name) {
	var e;
	try {
		e = eval(name);
	}
	catch( $e0 ) {
		{
			var err = $e0;
			{
				e = null;
			}
		}
	}
	if(e == null || e.__ename__ == null) return null;
	return e;
}
Type.createInstance = function(cl,args) {
	if(args.length <= 3) return new cl(args[0],args[1],args[2]);
	if(args.length > 8) throw "Too many arguments";
	return new cl(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7]);
}
Type.createEmptyInstance = function(cl) {
	return new cl($_);
}
Type.createEnum = function(e,constr,params) {
	var f = Reflect.field(e,constr);
	if(f == null) throw "No such constructor " + constr;
	if(Reflect.isFunction(f)) {
		if(params == null) throw ("Constructor " + constr) + " need parameters";
		return f.apply(e,params);
	}
	if(params != null && params.length != 0) throw ("Constructor " + constr) + " does not need parameters";
	return f;
}
Type.createEnumIndex = function(e,index,params) {
	var c = Type.getEnumConstructs(e)[index];
	if(c == null) throw index + " is not a valid enum constructor index";
	return Type.createEnum(e,c,params);
}
Type.getInstanceFields = function(c) {
	var a = Reflect.fields(c.prototype);
	a.remove("__class__");
	return a;
}
Type.getClassFields = function(c) {
	var a = Reflect.fields(c);
	a.remove("__name__");
	a.remove("__interfaces__");
	a.remove("__super__");
	a.remove("prototype");
	return a;
}
Type.getEnumConstructs = function(e) {
	return e.__constructs__;
}
Type["typeof"] = function(v) {
	switch(typeof(v)) {
	case "boolean":{
		return ValueType.TBool;
	}break;
	case "string":{
		return ValueType.TClass(String);
	}break;
	case "number":{
		if(Math.ceil(v) == v % 2147483648.0) return ValueType.TInt;
		return ValueType.TFloat;
	}break;
	case "object":{
		if(v == null) return ValueType.TNull;
		var e = v.__enum__;
		if(e != null) return ValueType.TEnum(e);
		var c = v.__class__;
		if(c != null) return ValueType.TClass(c);
		return ValueType.TObject;
	}break;
	case "function":{
		if(v.__name__ != null) return ValueType.TObject;
		return ValueType.TFunction;
	}break;
	case "undefined":{
		return ValueType.TNull;
	}break;
	default:{
		return ValueType.TUnknown;
	}break;
	}
}
Type.enumEq = function(a,b) {
	if(a == b) return true;
	try {
		if(a[0] != b[0]) return false;
		{
			var _g1 = 2, _g = a.length;
			while(_g1 < _g) {
				var i = _g1++;
				if(!Type.enumEq(a[i],b[i])) return false;
			}
		}
		var e = a.__enum__;
		if(e != b.__enum__ || e == null) return false;
	}
	catch( $e0 ) {
		{
			var e = $e0;
			{
				return false;
			}
		}
	}
	return true;
}
Type.enumConstructor = function(e) {
	return e[0];
}
Type.enumParameters = function(e) {
	return e.slice(2);
}
Type.enumIndex = function(e) {
	return e[1];
}
Type.prototype.__class__ = Type;
massive.munit.client.JUnitReportClient = function(p) { if( p === $_ ) return; {
	this.id = "junit";
	this.xml = new StringBuf();
	this.currentTestClass = "";
	this.newline = "\n";
	this.testSuiteXML = null;
	this.xml.add("<testsuites>" + this.newline);
}}
massive.munit.client.JUnitReportClient.__name__ = ["massive","munit","client","JUnitReportClient"];
massive.munit.client.JUnitReportClient.prototype.addError = function(result) {
	this.checkForNewTestClass(result);
	this.suiteErrorCount++;
	this.testSuiteXML.add((((((("<testcase classname=\"" + result.className) + "\" name=\"") + result.name) + "\" time=\"") + massive.munit.util.MathUtil.round(result.executionTime,5)) + "\" >") + this.newline);
	this.testSuiteXML.add(((("<error message=\"" + result.error.message) + "\" type=\"") + result.error.type) + "\">");
	this.testSuiteXML.add(result.error);
	this.testSuiteXML.add("</error>" + this.newline);
	this.testSuiteXML.add("</testcase>" + this.newline);
}
massive.munit.client.JUnitReportClient.prototype.addFail = function(result) {
	this.checkForNewTestClass(result);
	this.suiteFailCount++;
	this.testSuiteXML.add((((((("<testcase classname=\"" + result.className) + "\" name=\"") + result.name) + "\" time=\"") + massive.munit.util.MathUtil.round(result.executionTime,5)) + "\" >") + this.newline);
	this.testSuiteXML.add(((("<failure message=\"" + result.failure.message) + "\" type=\"") + result.failure.type) + "\">");
	this.testSuiteXML.add(result.failure);
	this.testSuiteXML.add("</failure>" + this.newline);
	this.testSuiteXML.add("</testcase>" + this.newline);
}
massive.munit.client.JUnitReportClient.prototype.addPass = function(result) {
	this.checkForNewTestClass(result);
	this.suitePassCount++;
	this.testSuiteXML.add((((((("<testcase classname=\"" + result.className) + "\" name=\"") + result.name) + "\" time=\"") + massive.munit.util.MathUtil.round(result.executionTime,5)) + "\" />") + this.newline);
}
massive.munit.client.JUnitReportClient.prototype.checkForNewTestClass = function(result) {
	if(result.className != this.currentTestClass) {
		this.endTestSuite();
		this.currentTestClass = result.className;
		this.startTestSuite();
	}
}
massive.munit.client.JUnitReportClient.prototype.completionHandler = null;
massive.munit.client.JUnitReportClient.prototype.currentTestClass = null;
massive.munit.client.JUnitReportClient.prototype.endTestSuite = function() {
	if(this.testSuiteXML == null) return;
	var suiteTestCount = (this.suitePassCount + this.suiteFailCount) + this.suiteErrorCount;
	this.suiteExecutionTime = massive.munit.util.Timer.stamp() - this.suiteExecutionTime;
	var header = (((((((((((("<testsuite errors=\"" + this.suiteErrorCount) + "\" failures=\"") + this.suiteFailCount) + "\" hostname=\"\" name=\"") + this.currentTestClass) + "\" tests=\"") + suiteTestCount) + "\" time=\"") + massive.munit.util.MathUtil.round(this.suiteExecutionTime,5)) + "\" timestamp=\"") + Date.now()) + "\">") + this.newline;
	var footer = "</testsuite>" + this.newline;
	this.testSuiteXML.add("<system-out></system-out>" + this.newline);
	this.testSuiteXML.add("<system-err></system-err>" + this.newline);
	this.xml.add(header);
	this.xml.add(this.testSuiteXML.b.join(""));
	this.xml.add(footer);
}
massive.munit.client.JUnitReportClient.prototype.get_completeHandler = function() {
	return this.completionHandler;
}
massive.munit.client.JUnitReportClient.prototype.id = null;
massive.munit.client.JUnitReportClient.prototype.newline = null;
massive.munit.client.JUnitReportClient.prototype.reportFinalStatistics = function(testCount,passCount,failCount,errorCount,time) {
	this.endTestSuite();
	this.xml.add("</testsuites>");
	if(this.get_completeHandler() != null) (this.get_completeHandler())(this);
	return this.xml.b.join("");
}
massive.munit.client.JUnitReportClient.prototype.set_completeHandler = function(value) {
	return this.completionHandler = value;
}
massive.munit.client.JUnitReportClient.prototype.startTestSuite = function() {
	this.suitePassCount = 0;
	this.suiteFailCount = 0;
	this.suiteErrorCount = 0;
	this.suiteExecutionTime = massive.munit.util.Timer.stamp();
	this.testSuiteXML = new StringBuf();
}
massive.munit.client.JUnitReportClient.prototype.suiteErrorCount = null;
massive.munit.client.JUnitReportClient.prototype.suiteExecutionTime = null;
massive.munit.client.JUnitReportClient.prototype.suiteFailCount = null;
massive.munit.client.JUnitReportClient.prototype.suitePassCount = null;
massive.munit.client.JUnitReportClient.prototype.testSuiteXML = null;
massive.munit.client.JUnitReportClient.prototype.xml = null;
massive.munit.client.JUnitReportClient.prototype.__class__ = massive.munit.client.JUnitReportClient;
massive.munit.client.JUnitReportClient.__interfaces__ = [massive.munit.ITestResultClient];
if(typeof js=='undefined') js = {}
js.Lib = function() { }
js.Lib.__name__ = ["js","Lib"];
js.Lib.isIE = null;
js.Lib.isOpera = null;
js.Lib.document = null;
js.Lib.window = null;
js.Lib.alert = function(v) {
	alert(js.Boot.__string_rec(v,""));
}
js.Lib.eval = function(code) {
	return eval(code);
}
js.Lib.setErrorHandler = function(f) {
	js.Lib.onerror = f;
}
js.Lib.prototype.__class__ = js.Lib;
js.Boot = function() { }
js.Boot.__name__ = ["js","Boot"];
js.Boot.__unhtml = function(s) {
	return s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
}
js.Boot.__trace = function(v,i) {
	var msg = (i != null?((i.fileName + ":") + i.lineNumber) + ": ":"");
	msg += js.Boot.__unhtml(js.Boot.__string_rec(v,"")) + "<br/>";
	var d = document.getElementById("haxe:trace");
	if(d == null) alert("No haxe:trace element defined\n" + msg);
	else d.innerHTML += msg;
}
js.Boot.__clear_trace = function() {
	var d = document.getElementById("haxe:trace");
	if(d != null) d.innerHTML = "";
	else null;
}
js.Boot.__closure = function(o,f) {
	var m = o[f];
	if(m == null) return null;
	var f1 = function() {
		return m.apply(o,arguments);
	}
	f1.scope = o;
	f1.method = m;
	return f1;
}
js.Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ != null || o.__ename__ != null)) t = "object";
	switch(t) {
	case "object":{
		if(o instanceof Array) {
			if(o.__enum__ != null) {
				if(o.length == 2) return o[0];
				var str = o[0] + "(";
				s += "\t";
				{
					var _g1 = 2, _g = o.length;
					while(_g1 < _g) {
						var i = _g1++;
						if(i != 2) str += "," + js.Boot.__string_rec(o[i],s);
						else str += js.Boot.__string_rec(o[i],s);
					}
				}
				return str + ")";
			}
			var l = o.length;
			var i;
			var str = "[";
			s += "\t";
			{
				var _g = 0;
				while(_g < l) {
					var i1 = _g++;
					str += ((i1 > 0?",":"")) + js.Boot.__string_rec(o[i1],s);
				}
			}
			str += "]";
			return str;
		}
		var tostr;
		try {
			tostr = o.toString;
		}
		catch( $e0 ) {
			{
				var e = $e0;
				{
					return "???";
				}
			}
		}
		if(tostr != null && tostr != Object.toString) {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = (o.hasOwnProperty != null);
		for( var k in o ) { ;
		if(hasp && !o.hasOwnProperty(k)) continue;
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__") continue;
		if(str.length != 2) str += ", \n";
		str += ((s + k) + " : ") + js.Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += ("\n" + s) + "}";
		return str;
	}break;
	case "function":{
		return "<function>";
	}break;
	case "string":{
		return o;
	}break;
	default:{
		return String(o);
	}break;
	}
}
js.Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0, _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js.Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js.Boot.__interfLoop(cc.__super__,cl);
}
js.Boot.__instanceof = function(o,cl) {
	try {
		if(o instanceof cl) {
			if(cl == Array) return (o.__enum__ == null);
			return true;
		}
		if(js.Boot.__interfLoop(o.__class__,cl)) return true;
	}
	catch( $e0 ) {
		{
			var e = $e0;
			{
				if(cl == null) return false;
			}
		}
	}
	switch(cl) {
	case Int:{
		return Math.ceil(o%2147483648.0) === o;
	}break;
	case Float:{
		return typeof(o) == "number";
	}break;
	case Bool:{
		return o === true || o === false;
	}break;
	case String:{
		return typeof(o) == "string";
	}break;
	case Dynamic:{
		return true;
	}break;
	default:{
		if(o == null) return false;
		return o.__enum__ == cl || (cl == Class && o.__name__ != null) || (cl == Enum && o.__ename__ != null);
	}break;
	}
}
js.Boot.__init = function() {
	js.Lib.isIE = (typeof document!='undefined' && document.all != null && typeof window!='undefined' && window.opera == null);
	js.Lib.isOpera = (typeof window!='undefined' && window.opera != null);
	Array.prototype.copy = Array.prototype.slice;
	Array.prototype.insert = function(i,x) {
		this.splice(i,0,x);
	}
	Array.prototype.remove = (Array.prototype.indexOf?function(obj) {
		var idx = this.indexOf(obj);
		if(idx == -1) return false;
		this.splice(idx,1);
		return true;
	}:function(obj) {
		var i = 0;
		var l = this.length;
		while(i < l) {
			if(this[i] == obj) {
				this.splice(i,1);
				return true;
			}
			i++;
		}
		return false;
	});
	Array.prototype.iterator = function() {
		return { cur : 0, arr : this, hasNext : function() {
			return this.cur < this.arr.length;
		}, next : function() {
			return this.arr[this.cur++];
		}}
	}
	var cca = String.prototype.charCodeAt;
	String.prototype.cca = cca;
	String.prototype.charCodeAt = function(i) {
		var x = cca.call(this,i);
		if(isNaN(x)) return null;
		return x;
	}
	var oldsub = String.prototype.substr;
	String.prototype.substr = function(pos,len) {
		if(pos != null && pos != 0 && len != null && len < 0) return "";
		if(len == null) len = this.length;
		if(pos < 0) {
			pos = this.length + pos;
			if(pos < 0) pos = 0;
		}
		else if(len < 0) {
			len = (this.length + len) - pos;
		}
		return oldsub.apply(this,[pos,len]);
	}
	$closure = js.Boot.__closure;
}
js.Boot.prototype.__class__ = js.Boot;
if(!haxe.rtti) haxe.rtti = {}
haxe.rtti.Meta = function() { }
haxe.rtti.Meta.__name__ = ["haxe","rtti","Meta"];
haxe.rtti.Meta.getType = function(t) {
	var meta = t.__meta__;
	return ((meta == null)?meta:meta.obj);
}
haxe.rtti.Meta.getStatics = function(t) {
	var meta = t.__meta__;
	return ((meta == null)?meta:meta.statics);
}
haxe.rtti.Meta.getFields = function(t) {
	var meta = t.__meta__;
	return ((meta == null)?meta:meta.fields);
}
haxe.rtti.Meta.prototype.__class__ = haxe.rtti.Meta;
massive.munit.async.AsyncFactory = function(observer) { if( observer === $_ ) return; {
	this.observer = observer;
	this.asyncDelegateCount = 0;
}}
massive.munit.async.AsyncFactory.__name__ = ["massive","munit","async","AsyncFactory"];
massive.munit.async.AsyncFactory.prototype.asyncDelegateCount = null;
massive.munit.async.AsyncFactory.prototype.createHandler = function(testCase,handler,timeout,info) {
	var dispatcher = new massive.munit.async.AsyncDelegate(testCase,handler,timeout,info);
	dispatcher.observer = this.observer;
	this.asyncDelegateCount++;
	return dispatcher.delegateHandler;
}
massive.munit.async.AsyncFactory.prototype.observer = null;
massive.munit.async.AsyncFactory.prototype.__class__ = massive.munit.async.AsyncFactory;
massive.munit.client.PrintClient = function(p) { if( p === $_ ) return; {
	this.id = "print";
	this.init();
	this.print("MUnit Results" + this.newline);
	this.print("------------------------------" + this.newline);
}}
massive.munit.client.PrintClient.__name__ = ["massive","munit","client","PrintClient"];
massive.munit.client.PrintClient.prototype.addError = function(result) {
	this.checkForNewTestClass(result);
	this.errors += this.newline + result.error;
}
massive.munit.client.PrintClient.prototype.addFail = function(result) {
	this.checkForNewTestClass(result);
	this.failures += this.newline + result.failure;
}
massive.munit.client.PrintClient.prototype.addPass = function(result) {
	this.checkForNewTestClass(result);
	this.print(".");
}
massive.munit.client.PrintClient.prototype.checkForNewTestClass = function(result) {
	if(result.className != this.currentTestClass) {
		this.printExceptions();
		this.currentTestClass = result.className;
		this.print(((this.newline + "Class: ") + this.currentTestClass) + " ");
	}
}
massive.munit.client.PrintClient.prototype.completionHandler = null;
massive.munit.client.PrintClient.prototype.currentTestClass = null;
massive.munit.client.PrintClient.prototype.customTrace = function(value,info) {
	this.print(((((("TRACE: " + info.fileName) + "|") + info.lineNumber) + "| ") + Std.string(value)) + this.newline);
}
massive.munit.client.PrintClient.prototype.errors = null;
massive.munit.client.PrintClient.prototype.failures = null;
massive.munit.client.PrintClient.prototype.get_completeHandler = function() {
	return this.completionHandler;
}
massive.munit.client.PrintClient.prototype.id = null;
massive.munit.client.PrintClient.prototype.init = function() {
	this.originalTrace = $closure(haxe.Log,"trace");
	haxe.Log.trace = $closure(this,"customTrace");
	this.output = "";
	this.failures = "";
	this.errors = "";
	this.currentTestClass = "";
	this.newline = "\n";
	this.textArea = js.Lib.document.getElementById("haxe:trace");
	if(this.textArea == null) {
		var error = ((((("MissingElementException: 'haxe:trace' element not found at " + { fileName : "PrintClient.hx", lineNumber : 139, className : "massive.munit.client.PrintClient", methodName : "init"}.className) + "#") + { fileName : "PrintClient.hx", lineNumber : 139, className : "massive.munit.client.PrintClient", methodName : "init"}.methodName) + "(") + { fileName : "PrintClient.hx", lineNumber : 139, className : "massive.munit.client.PrintClient", methodName : "init"}.lineNumber) + ")";
		js.Lib.alert(error);
	}
}
massive.munit.client.PrintClient.prototype.newline = null;
massive.munit.client.PrintClient.prototype.originalTrace = null;
massive.munit.client.PrintClient.prototype.output = null;
massive.munit.client.PrintClient.prototype.print = function(value) {
	value = js.Boot.__string_rec(value,"");
	var v = StringTools.htmlEscape(value);
	v = v.split(this.newline).join("<br/>");
	if(this.textArea != null) this.textArea.innerHTML += v;
	this.output += value;
}
massive.munit.client.PrintClient.prototype.printExceptions = function() {
	if(this.errors != "") {
		this.print(this.errors + this.newline);
		this.errors = "";
	}
	if(this.failures != "") {
		this.print(this.failures + this.newline);
		this.failures = "";
	}
}
massive.munit.client.PrintClient.prototype.reportFinalStatistics = function(testCount,passCount,failCount,errorCount,time) {
	this.printExceptions();
	this.print(this.newline + this.newline);
	this.print(((passCount == testCount)?"PASSED":"FAILED"));
	this.print(((((((((((this.newline + "Tests: ") + testCount) + "  Passed: ") + passCount) + "  Failed: ") + failCount) + " Errors: ") + errorCount) + " Time: ") + massive.munit.util.MathUtil.round(time,5)) + this.newline);
	this.print("==============================" + this.newline);
	haxe.Log.trace = this.originalTrace;
	if(this.get_completeHandler() != null) (this.get_completeHandler())(this);
	return this.output;
}
massive.munit.client.PrintClient.prototype.set_completeHandler = function(value) {
	return this.completionHandler = value;
}
massive.munit.client.PrintClient.prototype.textArea = null;
massive.munit.client.PrintClient.prototype.__class__ = massive.munit.client.PrintClient;
massive.munit.client.PrintClient.__interfaces__ = [massive.munit.ITestResultClient];
Hash = function(p) { if( p === $_ ) return; {
	this.h = {}
	if(this.h.__proto__ != null) {
		this.h.__proto__ = null;
		delete(this.h.__proto__);
	}
	else null;
}}
Hash.__name__ = ["Hash"];
Hash.prototype.exists = function(key) {
	try {
		key = "$" + key;
		return this.hasOwnProperty.call(this.h,key);
	}
	catch( $e0 ) {
		{
			var e = $e0;
			{
				
				for(var i in this.h)
					if( i == key ) return true;
			;
				return false;
			}
		}
	}
}
Hash.prototype.get = function(key) {
	return this.h["$" + key];
}
Hash.prototype.h = null;
Hash.prototype.iterator = function() {
	return { ref : this.h, it : this.keys(), hasNext : function() {
		return this.it.hasNext();
	}, next : function() {
		var i = this.it.next();
		return this.ref["$" + i];
	}}
}
Hash.prototype.keys = function() {
	var a = new Array();
	
			for(var i in this.h)
				a.push(i.substr(1));
		;
	return a.iterator();
}
Hash.prototype.remove = function(key) {
	if(!this.exists(key)) return false;
	delete(this.h["$" + key]);
	return true;
}
Hash.prototype.set = function(key,value) {
	this.h["$" + key] = value;
}
Hash.prototype.toString = function() {
	var s = new StringBuf();
	s.b[s.b.length] = "{";
	var it = this.keys();
	{ var $it0 = it;
	while( $it0.hasNext() ) { var i = $it0.next();
	{
		s.b[s.b.length] = i;
		s.b[s.b.length] = " => ";
		s.b[s.b.length] = Std.string(this.get(i));
		if(it.hasNext()) s.b[s.b.length] = ", ";
	}
	}}
	s.b[s.b.length] = "}";
	return s.b.join("");
}
Hash.prototype.__class__ = Hash;
massive.munit.TestResult = function(p) { if( p === $_ ) return; {
	this.passed = false;
	this.executionTime = 0.0;
	this.name = "";
	this.className = "";
	this.async = false;
	this.error = null;
	this.failure = null;
}}
massive.munit.TestResult.__name__ = ["massive","munit","TestResult"];
massive.munit.TestResult.prototype.async = null;
massive.munit.TestResult.prototype.className = null;
massive.munit.TestResult.prototype.error = null;
massive.munit.TestResult.prototype.executionTime = null;
massive.munit.TestResult.prototype.failure = null;
massive.munit.TestResult.prototype.get_location = function() {
	return ((this.name == "" && this.className == "")?"":(this.className + "#") + this.name);
}
massive.munit.TestResult.prototype.location = null;
massive.munit.TestResult.prototype.name = null;
massive.munit.TestResult.prototype.passed = null;
massive.munit.TestResult.prototype.__class__ = massive.munit.TestResult;
$Main = function() { }
$Main.__name__ = ["@Main"];
$Main.prototype.__class__ = $Main;
$_ = {}
js.Boot.__res = {}
js.Boot.__init();
{
	var d = Date;
	d.now = function() {
		return new Date();
	}
	d.fromTime = function(t) {
		var d1 = new Date();
		d1["setTime"](t);
		return d1;
	}
	d.fromString = function(s) {
		switch(s.length) {
		case 8:{
			var k = s.split(":");
			var d1 = new Date();
			d1["setTime"](0);
			d1["setUTCHours"](k[0]);
			d1["setUTCMinutes"](k[1]);
			d1["setUTCSeconds"](k[2]);
			return d1;
		}break;
		case 10:{
			var k = s.split("-");
			return new Date(k[0],k[1] - 1,k[2],0,0,0);
		}break;
		case 19:{
			var k = s.split(" ");
			var y = k[0].split("-");
			var t = k[1].split(":");
			return new Date(y[0],y[1] - 1,y[2],t[0],t[1],t[2]);
		}break;
		default:{
			throw "Invalid date format : " + s;
		}break;
		}
	}
	d.prototype["toString"] = function() {
		var date = this;
		var m = date.getMonth() + 1;
		var d1 = date.getDate();
		var h = date.getHours();
		var mi = date.getMinutes();
		var s = date.getSeconds();
		return (((((((((date.getFullYear() + "-") + ((m < 10?"0" + m:"" + m))) + "-") + ((d1 < 10?"0" + d1:"" + d1))) + " ") + ((h < 10?"0" + h:"" + h))) + ":") + ((mi < 10?"0" + mi:"" + mi))) + ":") + ((s < 10?"0" + s:"" + s));
	}
	d.prototype.__class__ = d;
	d.__name__ = ["Date"];
}
{
	String.prototype.__class__ = String;
	String.__name__ = ["String"];
	Array.prototype.__class__ = Array;
	Array.__name__ = ["Array"];
	Int = { __name__ : ["Int"]}
	Dynamic = { __name__ : ["Dynamic"]}
	Float = Number;
	Float.__name__ = ["Float"];
	Bool = { __ename__ : ["Bool"]}
	Class = { __name__ : ["Class"]}
	Enum = { }
	Void = { __ename__ : ["Void"]}
}
{
	Math.__name__ = ["Math"];
	Math.NaN = Number["NaN"];
	Math.NEGATIVE_INFINITY = Number["NEGATIVE_INFINITY"];
	Math.POSITIVE_INFINITY = Number["POSITIVE_INFINITY"];
	Math.isFinite = function(i) {
		return isFinite(i);
	}
	Math.isNaN = function(i) {
		return isNaN(i);
	}
}
{
	js.Lib.document = document;
	js.Lib.window = window;
	onerror = function(msg,url,line) {
		var f = js.Lib.onerror;
		if( f == null )
			return false;
		return f(msg,[url+":"+line]);
	}
}
{
	js["XMLHttpRequest"] = (window.XMLHttpRequest?XMLHttpRequest:(window.ActiveXObject?function() {
		try {
			return new ActiveXObject("Msxml2.XMLHTTP");
		}
		catch( $e0 ) {
			{
				var e = $e0;
				{
					try {
						return new ActiveXObject("Microsoft.XMLHTTP");
					}
					catch( $e1 ) {
						{
							var e1 = $e1;
							{
								throw "Unable to create XMLHttpRequest object.";
							}
						}
					}
				}
			}
		}
	}:(function($this) {
		var $r;
		throw "Unable to create XMLHttpRequest object.";
		return $r;
	}(this))));
}
massive.munit.async.AsyncDelegate.DEFAULT_TIMEOUT = 400;
massive.munit.TestClassHelper.META_TAG_BEFORE_CLASS = "BeforeClass";
massive.munit.TestClassHelper.META_TAG_AFTER_CLASS = "AfterClass";
massive.munit.TestClassHelper.META_TAG_BEFORE = "Before";
massive.munit.TestClassHelper.META_TAG_AFTER = "After";
massive.munit.TestClassHelper.META_TAG_TEST = "Test";
massive.munit.TestClassHelper.META_PARAM_ASYNC_TEST = "Async";
massive.munit.TestClassHelper.META_TAGS = ["BeforeClass","AfterClass","Before","After","Test"];
massive.munit.util.Timer.arr = new Array();
massive.munit.client.HTTPClient.DEFAULT_ID = "HTTPClient";
massive.munit.client.HTTPClient.CLIENT_HEADER_KEY = "munit-clientId";
massive.munit.client.HTTPClient.PLATFORM_HEADER_KEY = "munit-platformId";
massive.munit.client.HTTPClient.REQUEST_ID_KEY = "munit-requestId";
massive.munit.client.HTTPClient.queue = [];
massive.munit.client.HTTPClient.responsePending = false;
massive.munit.Assert.assertionCount = 0;
sub.ItemTest.__meta__ = { fields : { beforeClass : { BeforeClass : null}, afterClass : { AfterClass : null}, setup : { Before : null}, tearDown : { After : null}, testConstructor : { Test : null}, testBlah : { Test : null}}}
SampleTest.__meta__ = { fields : { beforeClass : { BeforeClass : null}, afterClass : { AfterClass : null}, setup : { Before : null}, tearDown : { After : null}, testConstructor : { Test : null}, testAsyncOperation : { Test : ["Async"]}}}
massive.munit.client.JUnitReportClient.DEFAULT_ID = "junit";
js.Lib.onerror = null;
massive.munit.client.PrintClient.DEFAULT_ID = "print";
$Main.init = TestMain.main();
