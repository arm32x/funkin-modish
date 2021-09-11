package funkin.gui;

class MenuAction implements MenuItem
{
    public final label:String;
    public final action:()->Void;
    
    public function new(label:String, action:()->Void)
    {
        this.label = label;
        this.action = action;
    }
    
    public function activate()
    {
        this.action();
    }
}
