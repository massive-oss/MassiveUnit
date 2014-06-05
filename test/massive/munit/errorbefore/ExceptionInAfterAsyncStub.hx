package massive.munit.errorbefore;

class ExceptionInAfterAsyncStub
{
    public function new()
    {}

    @After
    public function after():Void
    {
        throw "Error in after";
    }

    @TestAsync
    public function exampleTestOne():Void
    {
    }
}
