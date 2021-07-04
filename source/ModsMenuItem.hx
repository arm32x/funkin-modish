package;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import openfl.utils.Assets;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.FlxG;
import flixel.FlxObject;

class ModsMenuItem extends FlxSpriteGroup
{
    inline private static final BEND_RADIUS = 500;
    inline private static final X_AT_CENTER = 100;
    
    public var mod:Registry.ModMetadata;
    
    override public function new(y:Float, mod:Registry.ModMetadata)
    {
        super(0, y);
        this.mod = mod;
        
        var iconPath = Assets.exists('${mod.id}:modish-icon.png') ? '${mod.id}:modish-icon.png' : Paths.image("mod-missing-icon");
        var iconSprite = new FlxSprite(0, -64, iconPath);
        iconSprite.setGraphicSize(128, 128);
        iconSprite.updateHitbox();
        add(iconSprite);
        
        var modIdText = new FlxText(156, -62, mod.version != null ? '${mod.id} @ ${mod.version}' : mod.id);
        modIdText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE);
        add(modIdText);
        
        var modNameText = new Alphabet(160, -88, mod.name, false, false, false, true);
        add(modNameText);
        
        var modDescriptionText = new FlxText(156, 36, mod.description != null ? mod.description : "");
        modDescriptionText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE);
        add(modDescriptionText);
    }
    
    override public function update(elapsed:Float)
    {
        x = Math.sqrt(BEND_RADIUS * BEND_RADIUS - (y - FlxG.height / 2) * (y - FlxG.height / 2)) - BEND_RADIUS + X_AT_CENTER;
        super.update(elapsed);
    }
}
