package;

import hscript.Interp;
import hscript.Parser;
import openfl.utils.Assets;
import hscript.Expr;
import Type;

class ScriptHost
{
    private static final loadedScripts:Map<String, Array<Expr>> = [];
    
    public static var interpreter:Null<Interp> = null;
    
    public static inline function runScripts(event:String)
    {
        if (loadedScripts.exists(event))
        {
            runScriptsInternal(event);
        }
    }
    
    private static function runScriptsInternal(event:String)
    {
        var scripts = loadedScripts.get(event);
        for (script in scripts)
        {
            interpreter.execute(script);
        }
    }
    
    public static function loadScripts()
    {
        var parser = new Parser();
        
        var events = CoolUtil.coolTextFile(Paths.txt("script-registry/eventList"));
        for (event in events)
        {
            var scriptPaths = CoolUtil.coolTextFile(Paths.txt('script-registry/$event'));
            var scripts:Array<Expr> = [];
            for (path in scriptPaths)
            {
                var scriptText = Assets.getText(Paths.script(path));
                var script = parser.parseString(scriptText, Paths.script(path));
                scripts.push(script);
            }
            if (scripts.length > 0)
            {
                loadedScripts.set(event, scripts);
            }
        }
        
        interpreter = new Interp();
        interpreter.variables.set("host", {
            requestClass: function requestClass(className:String):Bool
            {
                var resolved = Type.resolveClass(className);
                if (resolved != null)
                {
                    var pathComponents = className.split(".");
                    interpreter.variables.set(pathComponents[pathComponents.length - 1], resolved);
                    return true;
                }
                else
                {
                    return false;
                }
            },
            requestEnum: function requestEnum(enumName:String):Bool
            {
                var resolved = Type.resolveEnum(enumName);
                if (resolved != null)
                {
                    var pathComponents = enumName.split(".");
                    interpreter.variables.set(pathComponents[pathComponents.length - 1], resolved);
                    return true;
                }
                else
                {
                    return false;
                }
            }
        });
    }
}