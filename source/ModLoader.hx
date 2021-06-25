package;

import haxe.Exception;
import lime.utils.AssetLibrary;
#if sys
import sys.FileSystem;
#end

class ModLoader
{
    public function load(id:String)
    {
        #if sys
        if (FileSystem.exists('./mods/$id') && FileSystem.isDirectory('./mods/$id'))
        {
            throw new Exception("Not yet implemented.");
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
