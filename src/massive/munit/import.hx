package massive.munit;

#if haxe4
    #if (haxe >= version("4.1.0"))
    import Std.isOfType as isOfType;
    #else
    import Std.is as isOfType;
    #end
#else
import Std.is as isOfType;
#end