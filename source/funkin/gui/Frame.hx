package funkin.gui;

import flixel.text.FlxText;
import flixel.graphics.FlxGraphic;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

// TODO: Implement moving and resizing frames with the mouse.
class Frame extends FlxSpriteGroup
{
    public final contents:FlxSpriteGroup;
    
    public function new(x:Float, y:Float, width:Int, height:Int, title:String)
    {
        super(x, y);
        this.width = width;
        this.height = height;
        
        var background = new FlxSprite(0, 0).makeGraphic(1, 1, 0x3F000000);
        background.setGraphicSize(width, height);
        background.updateHitbox();
        add(background);
        
        var titleText = new FlxText(0, -2, width, title, 12, true);
        titleText.font = Paths.font("monoid.ttf");
        titleText.alignment = FlxTextAlign.CENTER;
        add(titleText);
        
        contents = new FlxSpriteGroup(0, 14);
        contents.width = width;
        contents.height = height - 14;
        add(contents);
    }
}
