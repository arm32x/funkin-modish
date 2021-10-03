package funkin.gui;

class RadioButtonMenuItem extends Checkbox implements MenuItem
{
    public final label:String;
    private final action:Void->Void;
    
    @:allow(funkin.gui.MenuBuilder)
    private function new(label:String, action:Void->Void, ?checked:Bool, ?disabled:Bool, radioButtonGroup:String)
    {
        super(0.0, 0.0, checked, disabled, radioButtonGroup);
        this.label = label;
        this.action = action;
    }
    
    public function activate():Bool
    {
        checked = true;
        action();
        return false;
    }
}
