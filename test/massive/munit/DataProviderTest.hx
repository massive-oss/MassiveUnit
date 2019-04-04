package massive.munit;

#if hamcrest
import org.hamcrest.Matcher;
import org.hamcrest.BaseMatcher;
import org.hamcrest.Description;
#end

/**
*  Unit tests for Data Provider feature.
*
*  A data provider is 2D Array of possible values that a test method may be invoked with.
*  - Each row corresponds to a set of values that will be passed for a single invocation of the test method.
*    The values (columns) of a row form the parameters of the test method.
*  - The test method will be invoked as many times as the number of rows are there in that data provider.
*
*  A data provider could also be a method that returns that Array.
*/
class DataProviderTest
{
    /** Array data provider */
    static public var integerValues : Array<Array<Int>> = [ [ 2 ], [ 3 ], [ 5 ] ];

    /** static method data provider */
    static public function booleanValues() : Array<Array<Bool>>
    {
        return [
                    [  true ],
                    [ false ]
               ];
    }

    public function new()  {
    }

    /** instance method data provider */
    public function multipleParameters() : Array<Array<Dynamic>>
    {
        return  [
                    [ [ 1,  true ],  4 ],
                    [ [ 2, false ], 16 ],
                    [ [ 3,  true ], 64 ]
                ];
    }

    // validation data
    static var   actualData01 : Array<Array<Int>>;
    static var   actualData02 : Array<Array<Bool>>;
    static var   actualData03 : Array<Array<Dynamic>>;

    @BeforeClass
    public function beforeClass():Void
    {
        actualData01   =     new Array<Array<Int>>();
        actualData02   =    new Array<Array<Bool>>();
        actualData03   = new Array<Array<Dynamic>>();
    }

    @AfterClass
    public function afterClass():Void
    {
        #if hamcrest
        Assert.isTrue ( new MultiDimensionArrayMatcher( actualData01 ).matches( integerValues ));
        Assert.isTrue ( new MultiDimensionArrayMatcher( actualData02 ).matches( booleanValues() ));
        Assert.isTrue ( new MultiDimensionArrayMatcher( actualData03 ).matches( multipleParameters() ));
        #end
    }

    @DataProvider("integerValues")
    @Test
    public function testArrayDataProvider( num: Int) :Void
    {
        actualData01.push( [ num ] ) ;
    }

    @DataProvider("booleanValues")
    @Test
    public function testStaticMethodDataProvider( flag: Bool) :Void
    {
        actualData02.push( [ flag ] ) ;
    }

    @DataProvider("multipleParameters")
    @Test
    public function testInstanceMethodDataProvider( argArray: Array<Dynamic>, powerOfFour: Int) :Void
    {
        actualData03.push( [ argArray, powerOfFour ] ) ;
    }
}


// --- NOTE: below class should probably go into hamcrest repo
#if hamcrest

/**
 * A Hamcrest Matcher to match a multi-dimensional array values, in any order.
 */
class MultiDimensionArrayMatcher<T> extends BaseMatcher<T>
{
    private var lhsArray: Array<Dynamic>;

    public function new (data: Array<Dynamic>)
    {
        super();
        lhsArray = (data != null) ? data : [] ;
    }

    override public function matches (data: Dynamic): Bool
    {
        var rhsArray: Array<Dynamic> = cast data;

        if (( null == rhsArray ) || ( lhsArray.length != rhsArray.length ))
        {
            return false;
        }

        var matcher: MultiDimensionArrayMatcher<Array<Dynamic>>;

        var isAMatch: Bool = true;

        for ( i in 0...rhsArray.length )
        {
            if ( Std.is( rhsArray[i], Array ))
            {
                matcher = new MultiDimensionArrayMatcher( lhsArray[i] );
                isAMatch = isAMatch && matcher.matches( rhsArray[i] );
            }
            else
            {
                isAMatch = isAMatch && ( lhsArray[i] == rhsArray[i] ) ;
            }

            if (! isAMatch)
            {
                return false;
            }
        }

        return true;
    }

    override public function describeTo (description: Description): Void
    {
        description.appendText("an n-dimensional array that has same values, in any order ").appendValue( lhsArray) ;
    }
}
#end
