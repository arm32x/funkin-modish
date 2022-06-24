package funkin.keybinding;

import flixel.FlxG;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

class Keybinding
{
    public final id:Identifier;
    
    public var pressed(get, never):Bool;
    public var justPressed(get, never):Bool;
    public var released(get, never):Bool;
    public var justReleased(get, never):Bool;
    
    private var keys:Array<FlxKey> = [];
    private var buttons:Array<FlxGamepadInputID> = [];

    public function new(id:Identifier)
    {
        this.id = id;
    }
    
    public function load():Keybinding
    {
        // TODO: Load keybindings from a preferences file of some kind.
        var meta = Registry.keybindings.get(id);
        this.keys = meta.defaultKeys;
        this.buttons = meta.defaultButtons;
        return this;
    }
    
    private function get_pressed():Bool
    {
        if (FlxG.keys.anyPressed(keys))
            return true;
        
        var gamepad = FlxG.gamepads.lastActive;
        if (gamepad != null && gamepad.anyPressed(buttons))
            return true;
        
        return false;
    }
    
    private function get_justPressed():Bool
    {
        if (FlxG.keys.anyJustPressed(keys))
            return true;
        
        var gamepad = FlxG.gamepads.lastActive;
        if (gamepad != null && gamepad.anyJustPressed(buttons))
            return true;
        
        return false;
    }
    
    private function get_released():Bool
    {
        return !pressed;
    }
    
    private function get_justReleased():Bool
    {
        if (FlxG.keys.anyJustReleased(keys))
            return true;
        
        var gamepad = FlxG.gamepads.lastActive;
        if (gamepad != null && gamepad.anyJustReleased(buttons))
            return true;
        
        return false;
    }
}
