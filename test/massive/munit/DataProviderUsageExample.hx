package massive.munit;

/**
*  Example usage of Data Provider feature.
*/
class DataProviderUsageExample
{
    public function new( )
    {}

    // diverse multiple parameter values data provider
    static public function diverseMultiParamDataProvider() : Array<Array<Dynamic>>
    {
        return  [
                    // has 2 params: one is an Array<Dynamic>, another is Bool
                    [
                        // 1st param : Array<Dynamic>
                        [   new MockData(),
                            1.5,
                            { x : 1234 },
                            function() : String
                            {
                                return "1";
                            }
                            // Note: missing optional entry
                        ],
                        // 2nd param : Bool
                        true
                    ],

                    [
                        [   new MockData(),
                            3.0,
                            { x : 1234 },
                            function() : String
                            {
                                return "2";
                            },
                            true
                        ],
                        true
                    ],

                    [
                        [   new MockData(),
                            4.5,
                            { x : 1234 },
                            function() : String
                            {
                                return "3";
                            },
                            true
                        ],
                        false
                    ]
                ];
    }

    // example that uses above diverse multiple param/value (static) data provider
    @DataProvider("diverseMultiParamDataProvider")
    public function useComplexMultiParamDataProvider( argArray: Array<Dynamic>, flag: Bool ):Void
    {
        var mock : MockData = cast argArray[0];
        Assert.areEqual ( "[ MockData instance ]", mock.toString() );

        var weight : Float = cast argArray[1];

        var values : Dynamic = argArray[2];
        Assert.areEqual ( 1234, values.x );

        var funcHandle : Dynamic = argArray[3];
        Assert.areEqual ( Std.parseInt(Reflect.callMethod(null, funcHandle, [])) * 1.5, weight );

        var optionalFlag : Bool = false; // default value
        if (weight > 1.5)
        {
            optionalFlag = cast argArray[4];
            Assert.areEqual ( true, optionalFlag );
        }
    }
}

class MockData
{
    public function new()
    {}

    public function toString():String
    {
        return "[ MockData instance ]";
    }
}
