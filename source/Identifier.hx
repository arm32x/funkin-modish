package;

import haxe.Exception;
import openfl.utils.Assets;

using StringTools;

class Identifier
{
    public final namespace:String;
    public final path:String;
    
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
    
    @:op(A == B)
    public function equals(other:Identifier):Bool
    {
        return namespace == other.namespace && path == other.path;
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
