package massive.munit.errorbefore;

class ExceptionInBothBeforeAfterStub
{
    public function new()
    {}

    @Before
    public function before():Void
    {
        throw "Error in before";
    }

    @After
    public function after():Void
    {
        throw "Error in after";
    }

    @Test
    public function exampleTestOne():Void
    {
    }
}
