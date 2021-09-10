package funkin.gui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import funkin.gui.MenuItem.MenuBuilder;
import funkin.gui.MenuItem.MenuItemAlignment;
import funkin.gui.MenuItem.PositionedMenuItem;
import haxe.Exception;

class SubMenu extends FlxSpriteGroup implements PositionedMenuItem
{
    private static inline final ACTION_HEIGHT = 24;
    private static inline final ACTION_PADDING = 24;

	public final label:String;
    
    private final background:FlxSprite;
    private final items:Array<{
        item:MenuItem,
        text:FlxText,
        background:FlxSprite
    }> = [];
    
    private var alignment:MenuItemAlignment = RightDown;
    
    public function new(label:String, items:Array<MenuItem>)
    {
        super(0, 0);
        this.label = label;
        this.visible = false;
        
        background = new FlxSprite(0, 0).makeGraphic(1, 1, 0x3F000000);
        
        var y = 0;
        this.items = items.map(function(item)
        {
            var labelText = new FlxText(ACTION_PADDING, y + (ACTION_HEIGHT - 20) / 2, 0, item.label, 12);
            labelText.font = Paths.font("monoid.ttf");
            
            var labelBackground = new FlxSprite(0, y).makeGraphic(1, 1, 0xFFFFFFFF);
            labelBackground.alpha = 0.0;

            y += ACTION_HEIGHT;
            
            return {item: item, text: labelText, background: labelBackground};
        });
        
        var width = 0;
        for (item in this.items)
        {
            if (item.text.width > width)
                width = Std.int(item.text.width);
        }
        width += ACTION_PADDING * 2;
        
        background.setGraphicSize(width, this.items.length * ACTION_HEIGHT);
        background.updateHitbox();
        add(background);
        for (item in this.items)
        {
            item.background.setGraphicSize(width, ACTION_HEIGHT);
            item.background.updateHitbox();
            add(item.background);
            add(item.text);
            
            if (item is PositionedMenuItem)
            {
                var positioned = cast(item, PositionedMenuItem);
                var anchor = item.background.getHitbox();
                positioned.setAnchorRect(anchor, alignment);
                anchor.put();
            }
            if (item is FlxSprite)
                add(cast(item, FlxSprite));
        }
    }
    
    public function setAnchorRect(anchor:FlxRect, alignment:MenuItemAlignment = RightDown)
    {
        // Vertical correction.
        alignment = switch (alignment)
        {
            case RightDown if (anchor.top + background.height >= FlxG.height): RightUp;
            case LeftDown if (anchor.top + background.height >= FlxG.height): LeftUp;
            case RightUp if (anchor.bottom - background.height < 0): RightDown;
            case LeftUp if (anchor.bottom - background.height < 0): LeftDown;
            default: alignment;
        }
        // Horizontal correction.
        alignment = switch (alignment)
        {
            case RightDown if (anchor.right + background.width >= FlxG.width): LeftDown;
            case LeftDown if (anchor.left - background.width < 0): RightDown;
            case RightUp if (anchor.right + background.width >= FlxG.width): LeftUp;
            case LeftUp if (anchor.left - background.width < 0): RightUp;
            default: alignment;
        }
        // Set position based on alignment.
        switch (alignment)
        {
            case RightDown: setPosition(anchor.right, anchor.top);
            case LeftDown: setPosition(anchor.left - background.width, anchor.top);
            case RightUp: setPosition(anchor.right, anchor.bottom - background.height);
            case LeftUp: setPosition(anchor.left - background.width, anchor.bottom - background.height);
        }
    }
    
    public var isOpen(get, never):Bool;

	public function open()
    {
        this.visible = true;
    }

	public function close()
    {
        this.visible = false;
    }
    
    private function get_isOpen()
    {
        return this.visible;
    }

	public function activate() {}
    
    public static inline function builder<P:MenuBuilder<P>>():SubMenuBuilder<P>
    {
        return new SubMenuBuilder();
    }
}

@:allow(funkin.gui.SubMenu)
class SubMenuBuilder<P:MenuBuilder<P>> extends MenuBuilder<SubMenuBuilder<P>>
{
    private var parent:Null<P> = null;

    private var label:Null<String> = null;
    
    private function new() {}
    
    private function chain() { return this; }
    
    @:allow(funkin.gui.MenuBuilder)
    private function withParent(parent:P):SubMenuBuilder<P>
    {
        this.parent = parent;
        return this;
    }
    
    public function withLabel(label:String):SubMenuBuilder<P>
    {
        this.label = label;
        return this;
    }
    
    public function end():P
    {
        if (parent == null)
            throw new Exception('Cannot end() SubMenu without a parent.');
        return parent
            .withItem(build());
    }
    
    public function build():SubMenu
    {
        if (label == null)
            throw new Exception('Cannot build() SubMenu without a label.');
        return new SubMenu(label, items);
    }
}
