package massive.munit.errorbefore;

class FailInBeforeStub
{
    public function new()
    {}

    @Before
    public function before():Void
    {
        Assert.isTrue(false);
    }

    @Test
    public function exampleTestOne():Void
    {
    }
}
