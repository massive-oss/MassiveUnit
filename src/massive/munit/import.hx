package massive.munit;

#if haxe4
#if (haxe >= version("4.1.0"))
import Std.isOfType as isTypeof;
#else
import Std.is as isTypeof;
#end
#else
import Std.is as isTypeof;
#end