package funkin.gui;

import funkin.gui.MenuItem.PositionedMenuItem;
import funkin.gui.MenuItem.MenuBuilder;
import funkin.gui.SubMenu.SubMenuBuilder;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRect;
import flixel.text.FlxText;

class MenuBar extends FlxSpriteGroup
{
    private static inline final ACTION_MARGIN = 0;
    private static inline final ACTION_PADDING = 8;
    private static inline final BAR_PADDING = 4;
    
    private final items:Array<{
        item:MenuItem,
        text:FlxText,
        background:FlxSprite
    }> = [];
    
    public function new(items:Array<MenuItem>)
    {
        super(0, 0);
        
        var background = new FlxSprite(0, 0).makeGraphic(FlxG.width, 20, 0x3F000000);
        add(background);
        
        var x = BAR_PADDING + ACTION_MARGIN;
        this.items = items.map(function (item)
        {
            var labelText = new FlxText(x + ACTION_PADDING, 0, 0, item.label, 12);
            labelText.font = Paths.font("monoid.ttf");
            add(labelText);
            
            var labelBackground = new FlxSprite(x, 0).makeGraphic(1, 1, 0xFFFFFFFF);
            labelBackground.setGraphicSize(Std.int(labelText.width) + ACTION_PADDING * 2, 20);
            labelBackground.updateHitbox();
            labelBackground.alpha = 0.0;
            add(labelBackground);
            
            if (item is PositionedMenuItem)
            {
                var positioned = cast(item, PositionedMenuItem);
                var anchor = FlxRect.get(0, 20, x, FlxG.height); // Force into specific position.
                positioned.setAnchorRect(anchor);
                anchor.put();
            }
            if (item is FlxSprite)
                add(cast(item, FlxSprite));

            x += Std.int(labelBackground.width) + ACTION_MARGIN;
            
            return {item: item, text: labelText, background: labelBackground};
        });
    }
    
    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        
        var mousePosition = FlxG.mouse.getPosition();
        
        var hitbox = FlxRect.get();
        for (item in items)
        {
            item.background.alpha = 0.0;

            item.background.getHitbox(hitbox);
            if (hitbox.containsPoint(mousePosition))
            {
                item.background.color = 0xFFFFFF;
                item.background.alpha = 0.15;
                if (!item.item.isOpen)
                    item.item.open();
            }
            else if (item.item.isOpen)
                item.item.close();
        }
    }
    
    public static inline function builder():MenuBarBuilder
    {
        return new MenuBarBuilder();
    }
}

@:allow(funkin.gui.MenuBar)
class MenuBarBuilder extends MenuBuilder<MenuBarBuilder>
{
    private function new() {}

    private function chain() { return this; }
    
    public function build()
    {
        return new MenuBar(items);
    }
}
