package funkin.gui;

import haxe.Exception;

class MenuAction implements MenuItem
{
    public final label:String;
    public final action:()->Void;
    
    public function new(label:String, action:()->Void)
    {
        this.label = label;
        this.action = action;
    }
    
    public var isOpen(get, never):Bool;
    
    public function open() {}
    public function close() {}
    
    public function activate()
    {
        this.action();
    }
    
    private function get_isOpen()
    {
        return false;
    }
}
