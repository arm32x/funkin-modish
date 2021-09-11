package funkin.gui;

import flixel.math.FlxRect;
import funkin.gui.SubMenu.SubMenuBuilder;

interface MenuItem
{
    public final label:String;
    
    public function activate():Bool;
}

enum MenuItemAlignment
{
    RightDown;
    LeftDown;
    RightUp;
    LeftUp;
}

abstract class MenuBuilder<B:MenuBuilder<B>>
{
    private var items:Array<MenuItem> = [];

    // This function's only use is to prevent the Haxe compiler going apeshit.
    private abstract function chain():B;

    private function withItem(item:MenuItem):B
    {
        items.push(item);
        return chain();
    }

    public function withAction(label:String, action:()->Void):B
    {
        return this.withItem(new MenuAction(label, action));
    }
    
    public function withSubMenu(label:String):SubMenuBuilder<B>
    {
        return SubMenu.builder()
            .withParent(chain())
            .withLabel(label);
    }
}
