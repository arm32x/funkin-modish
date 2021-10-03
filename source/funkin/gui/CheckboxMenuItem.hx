package funkin.gui;

class CheckboxMenuItem extends Checkbox implements MenuItem
{
    public final label:String;
    private final action:Bool->Void;
    
    public function new(label:String, action:Bool->Void, checked:Bool = false, disabled:Bool = false)
    {
        super(0.0, 0.0, checked, disabled);
        this.label = label;
        this.action = action;
    }
    
    public function activate():Bool
    {
        checked = !checked;
        action(checked);
        return false;
    }
}
