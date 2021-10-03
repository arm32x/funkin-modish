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
    
    public function withCheckbox(label:String, action:Bool->Void, ?checked:Bool, ?disabled:Bool):B
    {
        return this.withItem(new CheckboxMenuItem(label, action, checked, disabled));
    }
    
    public function withRadioButton(label:String, action:Void->Void, ?checked:Bool, ?disabled:Bool, radioButtonGroup:String):B
    {
        return this.withItem(new RadioButtonMenuItem(label, action, checked, disabled, radioButtonGroup));
    }
    
    public function withRadioButtons(labels:Array<String>, action:Int->Void, ?checkedIndex:Int, ?disabled:Bool, radioButtonGroup:String):B
    {
        for (index => label in labels)
        {
            // This relies on withItem() mutating the current builder instead of
            // returning a completely new one.
            withRadioButton(label, () -> action(Checkbox.getSelectedRadioButton(radioButtonGroup)), index == checkedIndex, disabled, radioButtonGroup);
        }
        return chain();
    }
    
    public function withSubMenu(label:String):SubMenuBuilder<B>
    {
        return SubMenu.builder()
            .withParent(chain())
            .withLabel(label);
    }
}
