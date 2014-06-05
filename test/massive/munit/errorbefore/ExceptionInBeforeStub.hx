package massive.munit.errorbefore;

class ExceptionInBeforeStub
{
    public function new()
    {}

    @Before
    public function before():Void
    {
        throw "Error in before";
    }

    @Test
    public function exampleTestOne():Void
    {
    }
}
