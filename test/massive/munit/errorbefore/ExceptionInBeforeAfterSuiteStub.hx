package massive.munit.errorbefore;

class ExceptionInBeforeAfterSuiteStub extends massive.munit.TestSuite
{
    public function new()
    {
        super();
        add(ExceptionInBeforeStub);
        add(ExceptionInAfterStub);
        add(FailInBeforeStub);
        add(ExceptionInBothBeforeAfterStub);
        add(ExceptionInBeforeClassStub);
        add(ExceptionInAfterAsyncStub);
    }
}
