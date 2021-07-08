package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup;
import flixel.FlxG;
import flixel.FlxSprite;

class ModsMenuState extends MusicBeatState
{
    private var menuItems = new FlxTypedGroup<ModsMenuItem>();
    private var curSelected = 0;

    override public function create()
    {
        super.create();
        
        var bg = new FlxSprite(0, 0, Paths.image("menuBGBlack"));
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);
        
        for (mod in Registry.mods)
        {
            menuItems.add(new ModsMenuItem(360, mod));
        }
        add(menuItems);
        changeItem(0);
    }
    
    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        
        if (controls.BACK)
        {
            FlxG.switchState(new MainMenuState());
        }
        
        if (controls.UP)
        {
            FlxG.sound.play(Paths.sound('scrollMenu'));
            changeItem(-1);
        }
        else if (controls.DOWN)
        {
            FlxG.sound.play(Paths.sound('scrollMenu'));
            changeItem(1);
        }
    }
    
    private function changeItem(delta:Int)
    {
        curSelected += delta;
        while (curSelected >= menuItems.length)
            curSelected -= menuItems.length;
        while (curSelected < 0)
            curSelected += menuItems.length;

        for (index => item in menuItems.members)
        {
            FlxTween.cancelTweensOf(item);
            FlxTween.tween(item, {y: FlxG.height / 2 + (index - curSelected) * 160}, 0.2, {ease: FlxEase.expoOut});
            FlxTween.tween(item, {alpha: index == curSelected ? 1.0 : 0.5}, 0.2, {ease: FlxEase.expoOut});
        }
    }
}
