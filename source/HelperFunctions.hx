import haxe.Exception;

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
}