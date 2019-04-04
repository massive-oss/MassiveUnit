package massive.munit.async;

import massive.munit.Assert;
import massive.munit.util.Timer;
import massive.munit.async.AsyncTimeoutException;

/**
 * <p>
 * A chained async delegate has its primary async delegate's response handler (or time-out handler) create another
 * async delegate (& so on, for any number of levels as needed by the feature being tested).
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
class ChainedAsyncTest
{
    static inline var L1_RESPONS_FACTOR       =  11;
    static inline var L2_RESPONS_FACTOR       =  13;
    static inline var L1_TIMEOUT_FACTOR       =  17;
    static inline var L2_TIMEOUT_FACTOR       =  19;
    static inline var FAILURE_TIMEOUT_FACTOR  =  97;

    private var actualValue   : Int;
    private var expectedValue : Int;

    private var h1     : Void->Void;
    private var h2     : Void->Void;
    private var h3     : Void->Void;
    private var h4     : Void->Void;
    private var h5     : Void->Void;
    private var t1     : Void->Void;
    private var t2     : Void->Void;
    private var t3     : Void->Void;
    private var t4     : Void->Void;
    private var t5     : Void->Void;

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
    *  This test creates an async delegate that is expected to trigger the response handler (responseHandler11).
    *  That handler creates another async delegate, triggerring another response handler (responseHandler12).
    *
    *  Chaining is occurring in response handlers.
    *
    *  This test should always Succeed.
    */
    @AsyncTest
    public function testResponseChainSuccess(factory:AsyncFactory) : Void
    {
        expectedValue = L1_RESPONS_FACTOR * L2_RESPONS_FACTOR;

        h1 = factory.createHandler ( this, responseHandler11, 250, forbiddenTimeOutHandler );
        Timer.delay ( h1, 10 );
    }

    public function responseHandler11() : Void
    {
        actualValue *= L1_RESPONS_FACTOR;

        t1 = Async.handler ( this, responseHandler12, 250, forbiddenTimeOutHandler );
        Timer.delay ( t1, 10 );
    }

    public function responseHandler12() : Void
    {
        actualValue *= L2_RESPONS_FACTOR;
    }

    /**
    *  This test creates an async delegate that is expected to trigger the response handler (responseHandler21).
    *  That (responseHandler21) creates another async delegate implemented to result in a time-out.
    *  That time-out handler triggers an Assert.fail condition.
    *
    *  Chaining is occurring in response handlers.
    *
    *  This test is expected to be reported as FAILed with "Ignore: this is EXPECTED" as part of its error message.
    */
    @AsyncTest
    public function testTimeoutHandlerFailure(factory:AsyncFactory) : Void
    {
        expectedValue = L1_RESPONS_FACTOR * FAILURE_TIMEOUT_FACTOR;

        h2 = factory.createHandler ( this, responseHandler21, 250, forbiddenTimeOutHandler );
        Timer.delay ( h2, 10 );
    }

    public function responseHandler21() : Void
    {
        actualValue *= L1_RESPONS_FACTOR;

        t2 = Async.handler ( this, forbiddenResponseHandler, 250, failingTimeOutHandler );
    }

    /**
    *  This test creates an async delegate that is expected to trigger the response handler (responseHandler31).
    *  That (responseHandler31) creates another async delegate implemented to result in a time-out.
    *  That time-out handler should not fail.
    *
    *  Chaining is occurring in response handlers.
    *
    *  This test should always Succeed.
    */
    @AsyncTest
    public function testTimeoutHandlerSuccess(factory:AsyncFactory) : Void
    {
        expectedValue = L1_RESPONS_FACTOR * L2_TIMEOUT_FACTOR;

        h3 = factory.createHandler ( this, responseHandler31, 250, forbiddenTimeOutHandler );
        Timer.delay ( h3, 10 );
    }

    public function responseHandler31() : Void
    {
        actualValue *= L1_RESPONS_FACTOR;

        t3 = Async.handler ( this, forbiddenResponseHandler, 250, basicTimeOutHandler );
    }

    /**
    *  This test creates an async delegate that times-out resulting in invoking a time-out handler,
    *  chainABasicTimeOutHandler, that creates another async delegate resulting in a time-out also.
    *  This 2nd time-out handler hould not fail.
    *
    *  Chaining is occurring in time-out handlers.
    *
    *  This test should always Succeed.
    */
    @AsyncTest
    public function testChainedTimeoutHandlerSuccess(factory:AsyncFactory) : Void
    {
        expectedValue = L1_TIMEOUT_FACTOR * L2_TIMEOUT_FACTOR;

        h4 = factory.createHandler ( this, forbiddenResponseHandler, 250, chainABasicTimeOutHandler );
    }

    public function chainABasicTimeOutHandler() : Void
    {
        actualValue *= L1_TIMEOUT_FACTOR;

        t4 = Async.handler ( this, forbiddenResponseHandler, 250, basicTimeOutHandler );
    }

    /**
    *  This test creates an async delegate that times-out resulting in invoking a time-out handler,
    *  chainAFailureTimeOutHandler, that creates another async delegate resulting in a time-out also.
    *  This 2nd time-out handler triggers an Assert.fail condition.
    *
    *  Chaining is occurring in time-out handlers.
    *
    *  This test is expected to be reported as FAILed with "Ignore: this is EXPECTED" as part of its error message.
    */
    @AsyncTest
    public function testChainedTimeoutHandlerFailure(factory:AsyncFactory) : Void
    {
        expectedValue = L1_TIMEOUT_FACTOR * FAILURE_TIMEOUT_FACTOR;

        h5 = factory.createHandler ( this, forbiddenResponseHandler, 250, chainAFailureTimeOutHandler );
    }

    public function chainAFailureTimeOutHandler() : Void
    {
        actualValue *= L1_TIMEOUT_FACTOR;

        t5 = Async.handler ( this, forbiddenResponseHandler, 250, failingTimeOutHandler );
    }

    public function basicTimeOutHandler() : Void
    {
        actualValue *= L2_TIMEOUT_FACTOR;
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
