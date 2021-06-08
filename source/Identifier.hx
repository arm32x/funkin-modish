package;

class Identifier
{
    public final namespace:String;
    public final path:String;
    
    public function new(namespace:String, path:String)
    {
        this.namespace = namespace;
        this.path = path;
    }
    
    public static function parse(identifier:String):Identifier
    {
        var colonIndex = identifier.indexOf(":");
        var namespace = identifier.substring(0, colonIndex);
        var path = identifier.substring(colonIndex + 1);
        return new Identifier(namespace, path);
    }
}