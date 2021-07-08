package;

import lime.app.Future;
import lime.media.AudioBuffer;
import lime.utils.Bytes;
import lime.text.Font;
import lime.graphics.Image;
import haxe.io.Path;
import lime.utils.AssetLibrary;

using StringTools;

class ProxyAssetLibrary extends AssetLibrary
{
    private final library:AssetLibrary;
    private final basePath:String;
    
    public function new(library:AssetLibrary, basePath:String)
    {
        super();
        this.library = library;
        this.basePath = basePath;
    }
    
    override public function exists(id:String, type:String):Bool
    {
        return library.exists(getId(id), type);
    }
    
    override public function getAudioBuffer(id:String):AudioBuffer
    {
        return library.getAudioBuffer(getId(id));
    }
    
    override public function getBytes(id:String):Bytes
    {
        return library.getBytes(getId(id));
    }
    
    override public function getFont(id:String):Font
    {
        return library.getFont(getId(id));
    }
    
    override public function getImage(id:String):Image
    {
        return library.getImage(getId(id));
    }
    
    override public function getPath(id:String):String
    {
        return library.getPath(getId(id));
    }
    
    override public function getText(id:String):String
    {
        return library.getText(getId(id));
    }
    
    override public function list(type:String):Array<String>
    {
        var output = library.list(type);
        return output
            .filter(id -> id.startsWith(basePath))
            .map(id -> id.substring(basePath.length))
            .map(id -> id.startsWith("/") ? id.substring(1) : id);
    }
    
    override public function load():Future<AssetLibrary>
    {
        return library.load();
    }

    override public function loadAudioBuffer(id:String):Future<AudioBuffer>
    {
        return library.loadAudioBuffer(getId(id));
    }
    
    override public function loadBytes(id:String):Future<Bytes>
    {
        return library.loadBytes(getId(id));
    }
    
    override public function loadFont(id:String):Future<Font>
    {
        return library.loadFont(getId(id));
    }
    
    override public function loadImage(id:String):Future<Image>
    {
        return library.loadImage(getId(id));
    }

    override public function loadText(id:String):Future<String>
    {
        return library.loadText(getId(id));
    }
    
    private function getId(id:String):String
    {
        return Path.join([basePath, id]);
    }
}
