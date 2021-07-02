package;

import haxe.Exception;
import haxe.ds.HashMap;

typedef ModMetadata =
{
    var id:String;
    var name:String;
    var ?version:String;
    var ?description:String;
};

typedef CharacterMetadata =
{
    var icon:Identifier;
}

typedef HealthIconMetadata =
{
    var antialiasing:Bool;
}

typedef SongMetadata =
{
    var name:String;
    var icon:Identifier;
    var ?week:Identifier;
}

typedef WeekMetadata =
{
    var name:String;
    var ?leftCharacter:String;
    var ?middleCharacter:String;
    var ?rightCharacter:String;
    var locked:Bool;
    var playlist:Array<Identifier>;
}

typedef Entry<T> =
{
    var id:Identifier;
    var item:T;
}

class Registry<T>
{
    public static var mods:Array<ModMetadata> = [];

    public static var characters:Registry<CharacterMetadata> = new Registry("characters");
    public static var introTexts:Array<Array<String>> = [];
    public static var healthIcons:Registry<HealthIconMetadata> = new Registry("health-icons");
    public static var songs:Registry<SongMetadata> = new Registry("songs");
    public static var weeks:Registry<WeekMetadata> = new Registry("weeks");
    
    private final name:String;
    
    private var ids:Array<Identifier> = [];
    private var items:HashMap<Identifier, T> = new HashMap();
    
    public function new(name:String)
    {
        this.name = name;
    }
    
    public function register(id:Identifier, item:T)
    {
        if (items.exists(id))
        {
            throw new Exception('Item "$id" already registered in registry "$name".');
        }
        else
        {
            ids.push(id);
            items.set(id, item);
        }
    }
    
    public function get(id:Identifier):Null<T>
    {
        return items.get(id);
    }
    
    public function getEntry(id:Identifier):Null<Entry<T>>
    {
        var item = items.get(id);
        if (item == null)
        {
            return null;
        }
        else {
            return {id: id, item: item};
        }
    }
    
    public function getAllEntries():Array<Entry<T>>
    {
        return list()
            .map(function(id) return {id: id, item: get(id)});
    }
    
    public function list():Array<Identifier>
    {
        return ids;
    }
}
