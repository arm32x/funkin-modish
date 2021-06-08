package;

import openfl.utils.Assets;

class Identifier
{
    public final namespace:String;
    public final path:String;
    
    public inline function new(?namespace:String = "basegame", path:String)
    {
        this.namespace = namespace;
        this.path = path;
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
        else {
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

    public static final MULTIFILE_TYPES:Array<String> = [
        "character"
    ];
    
    public function getAssetPath(type:String, extension:String):String
    {
        if (MULTIFILE_TYPES.contains(type))
        {
            return '$namespace:assets/$namespace/$type/$path/$path.$extension';
        }
        else
        {
            return '$namespace:assets/$namespace/$type/$path.$extension';
        }
    }
}