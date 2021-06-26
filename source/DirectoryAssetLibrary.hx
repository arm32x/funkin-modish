package;

#if sys

import haxe.io.Path;
import lime.app.Future;
import lime.graphics.Image;
import lime.media.AudioBuffer;
import lime.net.HTTPRequest;
import lime.text.Font;
import lime.utils.AssetLibrary;
import lime.utils.Bytes;
import sys.FileSystem;
import sys.io.File;

using StringTools;

// TODO: Add caching.
class DirectoryAssetLibrary extends AssetLibrary
{
    private final directory:String;
    
    public function new(directory:String)
    {
        super();
        this.directory = directory;
    }
    
    override public function exists(id:String, type:String):Bool
    {
        return FileSystem.exists(getPath(id));
    }
    
    override public function getAudioBuffer(id:String):AudioBuffer
    {
        return AudioBuffer.fromFile(getPath(id));
    }
    
    override public function getBytes(id:String):Bytes
    {
        return Bytes.fromFile(getPath(id));
    }
    
    override public function getFont(id:String):Font
    {
        return Font.fromFile(getPath(id));
    }
    
    override public function getImage(id:String):Image
    {
        return Image.fromFile(getPath(id));
    }
    
    override public function getPath(id:String):String
    {
        return Path.join([directory, id]);
    }
    
    override public function getText(id:String):String
    {
        return File.getContent(getPath(id));
    }
    
    override public function list(type:String):Array<String>
    {
        var output = [];
        listInternal(directory, output);
        return output;
    }
    
    private static function listInternal(directory:String, output:Array<String>)
    {
        if (!FileSystem.exists(directory))
        {
            return;
        }
        for (entry in FileSystem.readDirectory(directory))
        {
            var path = Path.join([directory, entry]);
            if (FileSystem.isDirectory(path))
            {
                listInternal(Path.addTrailingSlash(path), output);
            }
            else {
                output.push(path);
            }
        }
    }
    
    override public function load():Future<AssetLibrary>
    {
        return Future.withValue(cast(this, AssetLibrary));
    }
    
    override public function loadAudioBuffer(id:String):Future<AudioBuffer>
    {
        return AudioBuffer.loadFromFile(getPath(id));
    }
    
    override public function loadBytes(id:String):Future<Bytes>
    {
        return Bytes.loadFromFile(getPath(id));
    }
    
    override public function loadFont(id:String):Future<Font>
    {
        return Font.loadFromFile(getPath(id));
    }
    
    override public function loadImage(id:String):Future<Image>
    {
        return Image.loadFromFile(getPath(id));
    }
    
    override public function loadText(id:String):Future<String>
    {
        // I don’t know why this is an HTTP request, but this is how the
        // standard AssetLibrary does it.
        return new HTTPRequest<String>().load(getPath(id));
    }
}

#end
