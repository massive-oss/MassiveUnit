package massive.munit.errorbefore;

class ExceptionInAfterStub
{
    public function new()
    {}

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
