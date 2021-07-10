import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
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
	
	@:deprecated
	public static function sanitizeString(str:String)
	{
		str = ~/[^a-zA-Z0-9_]/g.replace(str, "_");
		str = ~/_+/g.replace(str, "_");
		str = ~/^_+|_+$/g.replace(str, "");
		return str;
	}
	
	// TODO: Replace difficulties with strings throughout the codebase.
	@:deprecated("'HelperFunctions.difficultyToString()' is deprecated, use 'CoolUtil.difficultyFromInt().toLowerCase()' instead.")
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

	public static inline function getAtlas(id:Identifier, collection:String, ?file:Null<String>):FlxAtlasFrames
	{
		var imagePath = id.getAssetPath(collection, file, "png");
		var atlasPath:String;
		if (Assets.exists(atlasPath = id.getAssetPath(collection, file, "xml")))
		{
			return FlxAtlasFrames.fromSparrow(imagePath, atlasPath);
		}
		else if (Assets.exists(atlasPath = id.getAssetPath(collection, file, "txt")))
		{
			return FlxAtlasFrames.fromSpriteSheetPacker(imagePath, atlasPath);
		}
		else if (Assets.exists(atlasPath = id.getAssetPath(collection, file, "atlas")))
		{
			return FlxAtlasFrames.fromLibGdx(imagePath, atlasPath);
		}
		else
		{
			throw new Exception('Could not find texture atlas for "$id" - tried ".xml", ".txt", and ".atlas" formats.');
		}
	}
}
