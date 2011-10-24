var queue = [];
var timer = null;

var COLOR_FAILURE = "#F04242";
var COLOR_SUCCESS = "#A9D1AC";
var COLOR_WARNING = "#FFDE7A";
var COLOR_DEFAULT = "white";

/**
* Pushes a javascript call into a deferred queue in order
* to prevent additional unit testing from blocking
*/
function addToQueue(scope, arg)
{
	if(arg)
	{
		var item  = scope + "(\"" + arg + "\")";
	}
	else
	{
		var item  = scope + "()";
	}
	queue.push(item);
	if(timer ==  null) timer = setTimeout("emptyQueue()", 10);
	return true;
}

function emptyQueue()
{
	if(!initialized) initialize();

	var i = 0;
	for(i=0; i<queue.length; i++)
	{
		var item = queue[i];
		eval(item);
	}

	queue = [];
	timer = null;
}

//////////

var initialized = false;
var munit = null;

var currentLine = null;

var currentClassDiv = null;
var currentClassId = null;

var MUNIT_HEADER = "munit-header";
var MUNIT_TESTS = "munit-tests";
var MUNIT_COVERAGE = "munit-coverage";
var MUNIT_IGNORED = "munit-ignored";

function initialize()
{
	initialized = true;

	munit = createDiv("munit", "munit");
	var header = createDiv(MUNIT_HEADER, MUNIT_HEADER);
	var tests = createDiv(MUNIT_TESTS, MUNIT_TESTS);

	munit.appendChild(header);
	munit.appendChild(tests);
	document.body.appendChild(munit);

	var swf = document.getElementById("swfContainer");
	if(swf != null && swf != undefined)
	{
		swf.width = 0;
		swf.height = 0;
	}
}

function setResult(result)
{
	window.scrollTo(0,document.body.scrollHeight);
	parent.testComplete();
}



function printHeader(value)
{
	if(!initialized) initialize();

	var header = document.getElementById(MUNIT_HEADER);

	var line = createDiv(null, "line");
	line.innerHTML = value;

	header.appendChild(line);
}

///// TEST APIS ///////

//prints to the current test div
function createTest(testClass)
{
	currentClassId = testClass.split(".").join("_");
	currentClassDiv = createTestDiv(currentClassId);

	document.getElementById(MUNIT_TESTS).appendChild(currentClassDiv);

	toggleVisibility(currentClassId + "_contents");
}

function updateTestSummary(value)
{
	var line = document.getElementById(currentClassId + "_header");
	line.innerHTML += value;
}

function updateTestTraces(value)
{
	var contents = document.getElementById(currentClassId + "_contents");

	var line = createDiv(null, "trace");
	line.innerHTML = value;
	contents.appendChild(line);	

	toggleVisibility(currentClassId + "_contents", true);
}

function updateTestErrors(value)
{
	var contents = document.getElementById(currentClassId + "_contents");

	var line = createDiv(null, "error");
	line.innerHTML = value;
	contents.appendChild(line);	

	toggleVisibility(currentClassId + "_contents", true);
}

function updateTestCoverage(value)
{
	var contents = document.getElementById(currentClassId+ "_contents");

	var line = createDiv(null, "coverage");
	line.innerHTML = value;
	contents.appendChild(line);	
}

function updateTestResult(level)
{
	var color = null;

	switch(level)
	{
		case "0":
			color = COLOR_FAILURE;// red fail
			break;
		case "1":
			color = COLOR_SUCCESS;// green pas
			break;
		case "2":
			color = COLOR_WARNING;// yellow passed but not covered
			break;
		default: COLOR_DEFAULT;
			break;
	}

	var line = document.getElementById(currentClassId + "_header");
	line.style.backgroundColor = color;
}

/////////// FINAL REPORTS ///////////

function createIgnoredReport(value)
{

	var ignored = createSectionDiv(MUNIT_IGNORED, MUNIT_IGNORED);
	
	munit.appendChild(ignored);


	var header = document.getElementById(MUNIT_IGNORED + "_header");
	header.innerHTML = value;
}

function addIgnoredTest(value)
{


	var contents = document.getElementById(MUNIT_IGNORED + "_contents");
	contents.innerHTML += value;

	var line = createDiv(null, "ignored");
	line.innerHTML += value;

	contents.appendChild(line);
}

function createMissingCoverageReport(value)
{
	var coverage = createSectionDiv(MUNIT_COVERAGE, MUNIT_COVERAGE);
	munit.appendChild(coverage);
	var header = document.getElementById(MUNIT_COVERAGE + "_header");

	header.innerHTML = value;
	
}

function addMissingCoverageClass(coverageClass)
{
	var coverage = document.getElementById(MUNIT_COVERAGE + "_contents");

	currentClassId = coverageClass.split(".").join("_");
	currentClassDiv = createTestDiv(currentClassId);

	coverage.appendChild(currentClassDiv);
}

//////////

function createCoverageReportSummary(value)
{
	var id = "munit-coverage-summary";
	var coverage = createSectionDiv(id, "munit-coverage-summary");
	munit.appendChild(coverage);
	var header = document.getElementById(id + "_header");

	header.innerHTML = value;

	
}

function addCoverageReportSummaryItem(value)
{
	var id = "munit-coverage-summary";

	var contents = document.getElementById(id + "_contents");
	contents.innerHTML += value;

	var line = createDiv(null, "summary");
	line.innerHTML += value;

	contents.appendChild(line);
}


function printSummary(value)
{
	var id = "munit-summary";
	var coverage = createDiv(id, "munit-summary");

	coverage.innerHTML = value;

	munit.appendChild(coverage);
}



////////////////////// INTERNAL //////////////////

function createTestDiv(id)
{
	var test = createSectionDiv(id, "munit-test");
	return test;
}

/*
<div id="foo" class="munit-item">
	<div id="foo_header" class="munit-item-header"></div>
	<div id="foo_contents" class="munit-item-contents" ></div>
</div>
*/
function createSectionDiv(id, clazz)
{
	if(document.getElementById(id) != null)
	{
		return document.getElementById(id);
	}

	var item = createDiv(id, clazz);

	item.setAttribute("onclick", "toggleVisibility('" + id + "_contents')");

	var header = createDiv(id + "_header", clazz + "-header");
	var contents = createDiv(id + "_contents", clazz + "-contents");
	item.appendChild(header);
	item.appendChild(contents);

	return item;
}

/*
	<div id="foo" class="foo-class">
*/
function createDiv(id, clazz)
{
	if(id != null && document.getElementById(id) != null)
	{
		return document.getElementById(id);
	}

	var div = document.createElement("div");
	
	if(id != null) div.setAttribute("id", id);
	if(clazz != null) div.setAttribute("class", clazz);

	return div;

}

function toggleVisibility(id, forceOpen)
{
	var testContents = document.getElementById(id);

	if(forceOpen == true)
	{
		testContents.style.display = "block";
	}
	else
	{
		testContents.style.display = testContents.style.display == "none" ? "block" : "none";	
	}
	
}
