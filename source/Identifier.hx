package;

import haxe.Exception;
import openfl.utils.Assets;

using StringTools;

class Identifier
{
    public final namespace:String;
    public final path:String;
    
    private var hash:Null<Int> = null;
    
    public inline function new(?namespace:String = "basegame", path:String)
    {
        this.namespace = namespace;
        this.path = path;
        if (!isValidPart(namespace))
        {
            throw new Exception('Invalid Identifier namespace "$namespace".');
        }
        if (!isValidPart(path))
        {
            throw new Exception('Invalid Identifier path "$path".');
        }
    }
    
    public static function parse(identifier:String):Identifier
    {
        var colonIndex = identifier.indexOf(":");
        if (colonIndex != -1)
        {
            var namespace = identifier.substring(0, colonIndex);
            var path = identifier.substring(colonIndex + 1);
            return new Identifier(namespace, path);
        }
        else
        {
            return new Identifier("basegame", identifier);
        }
    }
    
    // FIXME: Operator overloading only works on abstracts, so all usage of
    // A == B needs to be updated to A.equals(B).
    public function equals(other:Identifier):Bool
    {
        return namespace == other.namespace && path == other.path;
    }
    
    public function hashCode():Int
    {
        // Copypasta’d from Java’s implementation.
        var h = hash;
        var value = toString();
        if (h == null && value.length > 0)
        {
            h = 0;
            for (charCode in value)
            {
                h = 31 * h + charCode;
            }
            hash = h;
        }
        return h;
    }
    
    public function toString():String
    {
        return '$namespace:$path';
    }
    
    public function getAssetPath(type:String, file:Null<String>, extension:String):String
    {
        if (file != null)
        {
            return '$namespace:$type/$path/$file.$extension';
        }
        else
        {
            return '$namespace:$type/$path/$path.$extension';
        }
    }
    
    private static final VALID_CHARS:String = "0123456789abcdefghijklmnopqrstuvwxyz-";
    
    public static function isValidPart(part:String):Bool
    {
        // The .. syntax didn’t compile.
        for (index in new IntIterator(0, part.length))
        {
            var char = part.charAt(index);
            if (!VALID_CHARS.contains(char))
            {
                return false;
            }
        }
        return true;
    }
}
