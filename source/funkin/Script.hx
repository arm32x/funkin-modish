package funkin;

import flixel.FlxG;
import flixel.system.FlxSound;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
import lime.utils.Assets;

class Script extends EventTarget
{
    private var expr:Null<Expr> = null;
    private var interp:Interp = new Interp();
    
    public final collection:String;
    public final id:Identifier;
    
    public function new(collection:String, id:Identifier)
    {
        super();
        
        this.collection = collection;
        this.id = id;
        
        var parser = new Parser();
        var path = id.getAssetPath(collection, null, "hxs");
        if (Assets.exists(path))
        {
            var source = Assets.getText(path);
            expr = parser.parseString(source, path);
        }
    }
    
    public function run(?variables:Map<String, Dynamic>):Script
    {
        if (expr == null)
        {
            return this;
        }
        
        // Standard APIs.
        {
            interp.variables.set("Identifier", Identifier);
            
            interp.variables.set("getAssetPath", (file, extension) -> id.getAssetPath(collection, file, extension));
            
            interp.variables.set("fire", this.fire);
            interp.variables.set("on", this.on);
            interp.variables.set("forward", this.forward);
            
            interp.variables.set("FlxG", FlxG);
            interp.variables.set("FlxSound", FlxSound);

            interp.variables.set("Math", Math);
        }

        if (variables != null)
        {
            for (key => value in variables)
            {
                interp.variables.set(key, value);
            }
        }
        interp.execute(expr);
        
        return this;
    }

    #if debug
    override private function onRegister(selector:String)
    {
        trace('Script "$id" registered as "$selector".');
    }
    
    override private function onUnregister()
    {
        trace('Script "$id" unregistered.');
    }
    #end
}
