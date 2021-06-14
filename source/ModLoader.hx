package;

#if sys
import sys.FileSystem;
#end

class ModLoader
{
    public function load(id:String):Bool
    {
        #if sys
        if (FileSystem.exists('./mods/$id') && FileSystem.isDirectory('./mods/$id'))
        {
            trace("Not yet implemented.");
            return false;
        }
        else if (FileSystem.exists('./mods/$id.zip') && !FileSystem.isDirectory('./mods/$id.zip'))
        {
            trace("Not yet implemented.");
            return false;
        }
        else
        {
            trace('Mod "$id" not found.');
            return false;
        }
        #else
        trace("Mod loading is not implemented on non-sys targets.");
        return false;
        #end
    }
}
