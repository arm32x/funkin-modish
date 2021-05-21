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
}