package;

import flixel.FlxG;
import flixel.math.FlxRect;

class TouchControls
{
    public static function areaJustTouched(rect:FlxRect):Bool
    {
        #if !FLX_NO_TOUCH
        for (touch in FlxG.touches.justStarted())
        {
            var position = touch.getScreenPosition();
            trace('Testing touch at $position against rect $rect.');
            if (position.inRect(rect))
                return true;
        }
        #end
        return false;
    }
}
