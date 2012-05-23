package math;

import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import org.hamcrest.MatchersBase;

class CalculatorTest extends MatchersBase
{
    var calculator:Calculator;

    public function new()
    {
        super();
    }

    @BeforeClass
    public function beforeClass():Void
    {
    }

    @AfterClass
    public function afterClass():Void
    {
    }

    @Before
    public function setup():Void
    {
        calculator = new Calculator();
    }

    @After
    public function tearDown():Void
    {
    }

    @Test
    public function shouldAddXToY()
    {
       assertThat(calculator.add(3, 2), equalTo(5));
    }

    @AsyncTest
    public function shouldAddXToYAfterDelay(factory:AsyncFactory):Void
    {
        var resultHandler:Dynamic = factory.createHandler(this, verifyShouldAddXToYAfterDelay, 1000);
        calculator.addAsync(3, 2, resultHandler);
    }

    function verifyShouldAddXToYAfterDelay(result:Int):Void
    {
        assertThat(result, equalTo(5));
    }
}
