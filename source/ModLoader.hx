package;

import lime.utils.Assets;
import haxe.Exception;
import lime.utils.AssetLibrary;
#if sys
import sys.FileSystem;
#end

class ModLoader
{
    public static function load(id:String)
    {
        if (Assets.hasLibrary(id))
        {
            throw new Exception('Mod "$id" already loaded!');
        }
        #if sys
        if (FileSystem.exists('./mods/$id') && FileSystem.isDirectory('./mods/$id'))
        {
            var library = new DirectoryAssetLibrary('./mods/$id', 'assets/$id/');
            Assets.registerLibrary(id, library);
        }
        else if (FileSystem.exists('./mods/$id.zip') && !FileSystem.isDirectory('./mods/$id.zip'))
        {
            throw new Exception("Not yet implemented.");
        }
        else
        {
            throw new Exception('Mod "$id" not found.');
        }
        #else
        throw new Exception("Mod loading is not implemented on non-sys targets.");
        #end
    }
}
