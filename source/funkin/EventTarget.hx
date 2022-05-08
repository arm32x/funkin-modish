package funkin;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import haxe.ds.HashMap;

class Event
{
    public final id:Identifier;
    public final data:Null<Dynamic>;

    public function new(id:Identifier, data:Any)
    {
        this.id = id;
        this.data = data;
    }

    public var defaultPrevented(default, null):Bool = false;

    public function preventDefault():Void
    {
        this.defaultPrevented = true;
    }
}

class EventTarget implements IFlxDestroyable
{
    private static var registry:Map<String, Array<EventTarget>> = [];

    // An EventTarget for events to/from the game's Haxe code.
    public static final CORE:EventTarget = register(new EventTarget(), "core");

    private var handlers:HashMap<Identifier, Array<Event->Void>> = new HashMap();

    public function new() {}

    public function fire(targetSelectors:Array<String>, eventId:Identifier, ?data:Dynamic, ?defaultHandler:Event->Void)
    {
        var event = new Event(eventId, data);
        for (selector in targetSelectors)
        {
            var targets = registry.get(selector);
            if (targets != null)
            {
                for (target in targets)
                {
                    target.handle(event);
                }
            }
        }
        if (defaultHandler != null && !event.defaultPrevented)
        {
            defaultHandler(event);
        }
    }

    public function on(eventId:Identifier, handler:Event->Void)
    {
        if (handlers.exists(eventId))
        {
            handlers.get(eventId).push(handler);
        }
        else
        {
            handlers.set(eventId, [handler]);
        }
    }

    public function forward(targetSelectors:Array<String>):Event->Void
    {
        return e -> fire(targetSelectors, e.id, e.data);
    }

    private function handle(event:Event)
    {
        if (handlers.exists(event.id))
        {
            for (handler in handlers.get(event.id))
            {
                handler(event);
            }
        }
    }

    public static function register<T:EventTarget>(target:T, selector:String):T
    {
        if (registry.exists(selector))
        {
            registry.get(selector).push(target);
        }
        else
        {
            registry.set(selector, [target]);
        }
        if (selector != "all")
        {
            register(target, "all");
        }
        #if debug
        if (target != null)
        {
            target.onRegister(selector);
        }
        #end
        return target;
    }

    public static function unregister<T:EventTarget>(target:T, selector:String = "all"):T
    {
        if (selector != "all")
        {
            registry.get(selector).remove(target);
            registry.get("all").remove(target);
        }
        else
        {
            for (_ => targets in registry)
            {
                targets.remove(target);
            }
        }
        #if debug
        if (target != null)
        {
            target.onUnregister();
        }
        #end
        return target;
    }

    #if debug
    private function onRegister(selector:String) {}
    private function onUnregister() {}
    #end

    public function destroy()
    {
        unregister(this);
    }
}
