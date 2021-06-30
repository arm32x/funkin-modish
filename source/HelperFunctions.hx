import haxe.Exception;
import flixel.math.FlxMath;

class HelperFunctions
{
    public static function truncateFloat( number : Float, precision : Int): Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
	}
	
	public static function sanitizeString(str:String)
	{
		str = ~/[^a-zA-Z0-9_]/g.replace(str, "_");
		str = ~/_+/g.replace(str, "_");
		str = ~/^_+|_+$/g.replace(str, "");
		return str;
	}
	
	// TODO: Replace difficulties with strings throughout the codebase.
	public static inline function difficultyToString(difficultyNumber:Int):String
	{
		switch (difficultyNumber)
		{
			case 0:
				return "easy";
			case 1:
				return "normal";
			case 2:
				return "hard";
			default:
				throw new Exception('Unknown difficulty number $difficultyNumber.');
		}
	}

	public static function GCD(a, b) {
		return b == 0 ? FlxMath.absInt(a) : GCD(b, a % b);
	}
	
	public static function collectToArray<T>(it:Iterator<T>):Array<T>
	{
		var result = [];
		while (it.hasNext())
		{
			result.push(it.next());
		}
		return result;
	}
}
