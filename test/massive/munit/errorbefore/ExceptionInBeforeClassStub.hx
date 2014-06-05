package massive.munit.errorbefore;

class ExceptionInBeforeClassStub
{
    public function new()
    {}

    @BeforeClass
    public function beforeClass():Void
    {
        throw "Error in beforeClass";
    }

    @Test
    public function exampleTestOne():Void
    {
    }

    @Test
    public function exampleTestTwo():Void
    {
    }
}
