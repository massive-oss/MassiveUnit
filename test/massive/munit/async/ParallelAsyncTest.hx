package massive.munit.async;

import massive.munit.Assert;
import massive.munit.util.Timer;
import massive.munit.async.AsyncTimeoutException;

/**
 * <p>
 * Multiple async delegates being created same time & co-existing and executing simultaneously.
 * </p>
 *
 * <p>
 * <b>Test Pass Criteria</b><br/>
 * Every test case starts with an 'actualValue' of '1', & a pre-set 'expectedValue' (value varies by test-case).
 * In every response/time-out handler, 'actualValue' is multiplied with a prime factor to mark the method invoked.
 * If test completes successfully, as designed, 'actualValue' should match 'expectedValue'... checked in @After method.
 * </p>
 *
 * <p>
 * Test cases that fail (by design) produce a result of failure & emit a message containing, "Ignore: this is EXPECTED".
 * You may consider them as acceptable test results & ignore the exception with that message.
 * </p>
 */
class ParallelAsyncTest
{
    static inline var SUCCESS_RESPONS_FACTOR  = 23;
    static inline var SUCCESS_TIMEOUT_FACTOR  = 29;
    static inline var FAILURE_TIMEOUT_FACTOR  = 97;

    private var actualValue   : Int;
    private var expectedValue : Int;

    private var h1     : Void->Void;
    private var h2     : Void->Void;
    private var h3     : Void->Void;
    private var h4     : Void->Void;
    private var h5     : Void->Void;
    private var h6     : Void->Void;
    private var h7     : Void->Void;
    private var t1     : Void->Void;
    private var t2     : Void->Void;

    public function new()
    {
    }

    @Before
    public function setup():Void
    {
        actualValue = 1;
    }

    @After
    public function tearDown():Void
    {
        Assert.areEqual (expectedValue, actualValue);
    }

    /**
    *  This test creates 3 async delegates, all of which are expected to execute their response handlers & not time-out.
    *
    *  This test should always Succeed.
    */
    @AsyncTest
    public function testResponseSuccess() : Void
    {
        expectedValue = SUCCESS_RESPONS_FACTOR * SUCCESS_RESPONS_FACTOR * SUCCESS_RESPONS_FACTOR;

        h1 = Async.handler ( this, responseHandler, 250, forbiddenTimeOutHandler );
        Timer.delay ( h1, 10 );

        h2 = Async.handler ( this, responseHandler, 250, forbiddenTimeOutHandler );
        Timer.delay ( h2, 10 );

        h3 = Async.handler ( this, responseHandler, 250, forbiddenTimeOutHandler );
        Timer.delay ( h3, 10 );
    }

    /**
    *  This test creates 3 async delegates withe one of them (first) implemented to time-out without error/fail.
    *  It is expected that the other 2 async delegates are not cancelled & execute successfully.
    *
    *  This test should always Succeed.
    */
    @AsyncTest
    public function testTimeoutHandlerSuccess() : Void
    {
        expectedValue = SUCCESS_TIMEOUT_FACTOR * SUCCESS_RESPONS_FACTOR * SUCCESS_RESPONS_FACTOR;

        t1 = Async.handler ( this, forbiddenResponseHandler,   10, basicTimeOutHandler );

        // as the above time-out handler is NOT a failure handler,
        // these should CONTINUE to execute!

        h4 = Async.handler ( this, responseHandler, 3000, forbiddenTimeOutHandler );
        Timer.delay ( h4, 1000 ); 

        h5 = Async.handler ( this, responseHandler, 3000, forbiddenTimeOutHandler );
        Timer.delay ( h5, 1000 ); 
    }

    /**
    *  This test creates 3 async delegates withe one of them (first) implemented to time-out WITH error/failure.
    *  It is expected that the other 2 async delegates are Cancelled & do NOT execute.
    *
    *  This test is expected to be reported as FAILed with "Ignore: this is EXPECTED" as part of its error message.
    */
    @AsyncTest
    public function testTimeoutHandlerFailure() : Void
    {
        expectedValue = FAILURE_TIMEOUT_FACTOR;

        t2 = Async.handler ( this, forbiddenResponseHandler,   10, failingTimeOutHandler );

        // as the above time-out handler IS A failure handler, these should be CANCELLED (if not already triggered) !

        h6 = Async.handler ( this, forbiddenResponseHandler, 3000, forbiddenTimeOutHandler );
        Timer.delay ( h6, 1000 ); 

        h7 = Async.handler ( this, forbiddenResponseHandler, 3000, forbiddenTimeOutHandler );
        Timer.delay ( h7, 1000 ); 
    }

    public function responseHandler() : Void
    {
        actualValue *= SUCCESS_RESPONS_FACTOR;
    }

    public function basicTimeOutHandler() : Void
    {
        actualValue *= SUCCESS_TIMEOUT_FACTOR;
    }

    public function failingTimeOutHandler() : Void
    {
        actualValue *= FAILURE_TIMEOUT_FACTOR;
        Assert.fail( "Ignore: this is EXPECTED");
    }

    public function forbiddenResponseHandler() : Void
    {
        actualValue = -555;
    }

    public function forbiddenTimeOutHandler() : Void
    {
        actualValue = -999;
    }
}
