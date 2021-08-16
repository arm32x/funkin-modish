package funkin;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.keyboard.FlxKey;
import haxe.io.Path;
import lime.utils.Assets;

#if sys
import sys.FileSystem;
import sys.io.Process;
#end

class ReloadManager extends FlxBasic
{
    private static final FULL_RELOAD_ACTION = new FlxActionDigital();
    private static final QUICK_RELOAD_ACTION = new FlxActionDigital();
    
    public function new()
    {
        super();
        FULL_RELOAD_ACTION.addKey(FlxKey.F5, JUST_PRESSED);
        QUICK_RELOAD_ACTION.addKey(FlxKey.F6, JUST_PRESSED);
    }
    
    override public function update(elapsed:Float)
    {
        if (FULL_RELOAD_ACTION.check())
        {
            quickReload();
            for (mod in Registry.mods)
            {
                Assets.unloadLibrary(mod.id);
            }
            Registry.clearAll();
            ModLoadingState.nextState = Type.getClass(FlxG.state);
            @:privateAccess TitleState.initialized = false;
            FlxG.switchState(new ModLoadingState());
            if (FlxG.sound.music == null || !FlxG.sound.music.playing)
            {
                FlxG.sound.playMusic(Paths.music('freakyMenu'));
            }
        }
        else if (QUICK_RELOAD_ACTION.check())
        {
            quickReload();
        }
    }
    
    private function quickReload()
    {
        #if sys
        // Check if the game is being run in a development environment.
        if (FileSystem.exists("../../../../Project.xml"))
        {
            trace("Copying files from development environment...");
            var target = Path.withoutDirectory(FileSystem.fullPath(".."));
            var configuration = Path.withoutDirectory(FileSystem.fullPath("../.."));
            var args = ["update", "../../../../Project.xml", target, '-$configuration'];
            trace('Running "lime" command with args $args');
            var process = new Process("lime", args);
            var exitCode = process.exitCode(true);
            if (exitCode != 0)
            {
                trace('Failed to copy files (exit code $exitCode)!');
            }
        }
        #end
        Assets.cache.clear();
    }
}
