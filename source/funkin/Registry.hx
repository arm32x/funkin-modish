package funkin;

import haxe.ds.HashMap;
import haxe.Exception;

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
};

typedef HealthIconMetadata =
{
    var antialiasing:Bool;
};

typedef MenuCharacterMetadata = {};

typedef NoteTypeMetadata =
{
    var ?animationSuffix:String;
};

typedef SongMetadata =
{
    var name:String;
    var icon:Identifier;
    var ?week:Identifier;
    var hasVocals:Bool;
};

typedef StageMetadata = {};

typedef WeekMetadata =
{
    var name:String;
    var ?leftCharacter:Identifier;
    var ?middleCharacter:Identifier;
    var ?rightCharacter:Identifier;
    var locked:Bool;
    var playlist:Array<Identifier>;
};

typedef Entry<T> =
{
    var id:Identifier;
    var item:T;
};

class Registry<T>
{
    public static var mods:Array<ModMetadata> = [];

    public static var characters:Registry<CharacterMetadata> = new Registry("characters");
    public static var introTexts:Array<Array<String>> = [];
    public static var healthIcons:Registry<HealthIconMetadata> = new Registry("health-icons");
    public static var menuCharacters:Registry<MenuCharacterMetadata> = new Registry("menu-characters");
    public static var noteTypes:Registry<NoteTypeMetadata> = new Registry("note-types");
    public static var songs:Registry<SongMetadata> = new Registry("songs");
    public static var stages:Registry<StageMetadata> = new Registry("stages");
    public static var weeks:Registry<WeekMetadata> = new Registry("weeks");
    
    public static function clearAll()
    {
        mods = [];
        characters.clear();
        introTexts = [];
        healthIcons.clear();
        menuCharacters.clear();
        noteTypes.clear();
        songs.clear();
        stages.clear();
        weeks.clear();
    }
    
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
    
    public function unregister(id:Identifier) {
        if (!items.exists(id)) 
        {
            throw new Exception('Item "$id" not registered in registry "$name".');
        }
        else {
            ids.remove(id);
            items.remove(id);
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
    
    public function exists(id:Identifier):Bool
    {
        return items.exists(id);
    }
    
    public function list():Array<Identifier>
    {
        return ids;
    }
    
    public function clear()
    {
        ids = [];
        items.clear();
    }
}
