package;

import haxe.Exception;
import haxe.Serializer;
import haxe.Unserializer;

using StringTools;

class Identifier
{
    public var namespace(default, null):String;
    public var path(default, null):String;
    
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
            trace('String "$identifier" parsed as "basegame:$identifier" using default namespace "basegame".');
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
    
    public function getAssetPath(collection:String, file:Null<String>, extension:String):String
    {
        if (file != null)
        {
            return '$namespace:$collection/$path/$file.$extension';
        }
        else
        {
            return '$namespace:$collection/$path/$path.$extension';
        }
    }
    
    private static final VALID_CHARS:String = "0123456789abcdefghijklmnopqrstuvwxyz-";
    
    public static function isValidPart(part:String):Bool
    {
        for (index in 0...part.length)
        {
            var char = part.charAt(index);
            if (!VALID_CHARS.contains(char))
            {
                return false;
            }
        }
        return true;
    }
    
    @:keep function hxSerialize(s:Serializer)
    {
        s.serialize(toString());
    }
    
    @:keep function hxUnserialize(u:Unserializer)
    {
        var parsed = parse(u.unserialize());
        namespace = parsed.namespace;
        path = parsed.path;
    }
}
