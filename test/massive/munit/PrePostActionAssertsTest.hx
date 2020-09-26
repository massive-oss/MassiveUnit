package massive.munit;

import massive.munit.async.AsyncFactory;
import massive.munit.util.Timer;

/**
 * <p>All unit tests in this class result in a failure state but, that should not halt the TestSuite.
 * That validates TestRunner capability to not stall when these pre/post-conditional fails.</p>
 *
 * <p>
 * Test cases that fail (by design) produce a result of failure & emit a message containing, "Ignore: this is EXPECTED".
 * You may consider them as acceptable test results & ignore the exception with that message.
 * </p>
 **/
class PrePostActionAssertsTest
{
    private var h1       : Void->Void;

    private var runner:TestRunner;
    private var client:TestResultClientStub;

    public function new()
    {}

    @BeforeClass
    public function beforeClass():Void
    {}

    @AfterClass
    public function afterClass():Void
    {}

    @Before
    public function setup():Void
    {}

    @After
    public function tearDown():Void
    {
        Assert.fail("Ignore: this is EXPECTED");
    }

    // these test methods are not testing any function because
    // our interest is to validate pre-/post-conditional methods
    // i.e. the actual tests in this class don't do anything
    @Test
    public function testSimple():Void
    {
        Assert.areEqual(true,true);
    }

    @AsyncTest
    public function testAsync(factory:AsyncFactory) : Void
    {
        h1 = factory.createHandler ( this, responseHandlerFunc );
        Timer.delay ( h1,  100 );
    }

    public function responseHandlerFunc() : Void
    {
        Assert.areEqual(true,true);
    }
}
