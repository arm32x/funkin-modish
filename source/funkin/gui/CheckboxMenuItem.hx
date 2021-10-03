package funkin.gui;

class CheckboxMenuItem extends Checkbox implements MenuItem
{
    public final label:String;
    private final action:Bool->Void;
    
    @:allow(funkin.gui.MenuBuilder)
    private function new(label:String, action:Bool->Void, ?checked:Bool, ?disabled:Bool)
    {
        super(0.0, 0.0, checked, disabled);
        this.label = label;
        this.action = action;
        
        active = false;
    }
    
    public function activate():Bool
    {
        checked = !checked;
        action(checked);
        return false;
    }
}
