package funkin.devtools;

import flixel.FlxState;
import imgui.ImGui;

class ImGuiDemoState extends FlxState
{
    public function new()
    {
        super();
    }
    
    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        
        ImGui.showDemoWindow();
    }
}
