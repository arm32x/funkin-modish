package funkin.gui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import funkin.gui.MenuItem.MenuBuilder;
import funkin.gui.MenuItem.MenuItemAlignment;
import haxe.Exception;

class SubMenu extends FlxSpriteGroup implements MenuItem
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
    
    private final hitbox:FlxRect = FlxRect.get();
    private final anchor:FlxRect = FlxRect.get();
    
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
            
            if (item is SubMenu)
            {
                var menu = cast(item, SubMenu);
                menu.setBestPosition(hitbox, alignment);
            }
            if (item is FlxSprite)
                add(cast(item, FlxSprite));
        }
    }
    
    public function setAnchorRect(anchor:FlxRect)
    {
        // The 'anchor' parameter will likely be put() after this call.
        this.anchor.copyFrom(anchor);
    }
    
    public function setBestPosition(anchor:FlxRect, alignment:MenuItemAlignment = RightDown)
    {
        setAnchorRect(anchor);
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
            case RightDown: setExactPosition(anchor.right, anchor.top, alignment);
            case LeftDown: setExactPosition(anchor.left, anchor.top, alignment);
            case RightUp: setExactPosition(anchor.right, anchor.bottom, alignment);
            case LeftUp: setExactPosition(anchor.left, anchor.bottom, alignment);
        }
    }
    
    public function setExactPosition(x:Float, y:Float, alignment:MenuItemAlignment = RightDown)
    {
        this.alignment = alignment;
        // Set position based on alignment.
        switch (alignment)
        {
            case RightDown: setPosition(x, y);
            case LeftDown: setPosition(x - background.width, y);
            case RightUp: setPosition(x, y - background.height);
            case LeftUp: setPosition(x - background.width, y - background.height);
        }
    }
    
    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        
        // The menu should be automatically closed when (a) the mouse is no
        // longer hovering over it, (b) none of its sub-menus are open, and
        // (c) its anchor rect (the menu item that opened it) is not hovered.
        background.getHitbox(hitbox);
        if (isOpen
            && FlxG.mouse.justMoved
            && !HelperFunctions.isHovered(hitbox)
            && !HelperFunctions.isHovered(anchor))
        {
            var anySubMenuIsOpen = false;
            for (item in items)
            {
                if (item.item is SubMenu && cast(item.item, SubMenu).isOpen)
                    anySubMenuIsOpen = true;
            }
            if (!anySubMenuIsOpen)
                close();
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
