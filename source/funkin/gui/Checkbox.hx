package funkin.gui;

import flixel.FlxG;
import flixel.math.FlxRect;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxSprite;

class Checkbox extends FlxSprite
{
    private static var radioButtons:Map<String, Array<Checkbox>> = [];
    private final radioButtonGroup:Null<String> = null;
    
    public var checked(default, set):Bool;
    public var disabled(default, set):Bool;
    
    private final hitbox:FlxRect = FlxRect.get();
    
    public function new(x:Float, y:Float, checked:Bool = false, disabled:Bool = false, ?radioButtonGroup:String)
    {
        super(x, y);
        this.radioButtonGroup = radioButtonGroup;
        
        var filename = radioButtonGroup != null ? "radio-button" : "checkbox";
        frames = FlxAtlasFrames.fromLibGdx('core:images/devtools/$filename.png', 'core:images/devtools/$filename.atlas');
        animation.addByPrefix("checked", "checked", 0);
        animation.addByPrefix("unchecked", "unchecked", 0);
        
        this.checked = checked;
        this.disabled = disabled;
        
        if (radioButtonGroup != null)
        {
            if (!radioButtons.exists(radioButtonGroup))
                radioButtons.set(radioButtonGroup, []);
            radioButtons.get(radioButtonGroup).push(this);
        }
    }
    
    override public function update(elapsed:Float)
    {
        if (FlxG.mouse.justPressed
            && HelperFunctions.isHovered(getHitbox(hitbox))
            && !disabled)
        {
            checked = !checked;
        }
    }
    
    private function set_checked(value:Bool):Bool
    {
        if (value == true && radioButtonGroup != null)
        {
            for (checkbox in radioButtons.get(radioButtonGroup))
                checkbox.checked = false; 
        }
        animation.play(value ? "checked" : "unchecked");
        return checked = value;
    }
    
    private function set_disabled(value:Bool):Bool
    {
        alpha = value ? 0.5 : 1.0;
        return disabled = value;
    }
}
