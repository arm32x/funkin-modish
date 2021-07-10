package;

import haxe.ds.HashMap;

class Event
{
    public final id:Identifier;
    public final data:Any;
    public final sender:EventTarget;
    
    public function new(id:Identifier, data:Any, sender:EventTarget)
    {
        this.id = id;
        this.data = data;
        this.sender = sender;
    }
    
    public var defaultPrevented(default, null):Bool = false;

    public function preventDefault():Void
    {
        this.defaultPrevented = true;
    }
}

class EventTarget
{
    private var handlers:HashMap<Identifier, Array<Event->Void>> = new HashMap();

    private static var registered:Array<EventTarget> = [];
    
    public function unicast(target:EventTarget, eventId:Identifier, data:Any, ?defaultHandler:Event->Void)
    {
        var event = new Event(eventId, data, this);
        target.handle(event);
        if (defaultHandler != null && !event.defaultPrevented)
        {
            defaultHandler(event);
        }
    }
    
    public function broadcast(eventId:Identifier, data:Any, ?defaultHandler:Event->Void)
    {
        var event = new Event(eventId, data, this);
        for (target in registered)
        {
            if (target != this)
            {
                target.handle(event);
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
    
    public static function register(target:EventTarget)
    {
        registered.push(target);
    }
    
    public static function unregister(target:EventTarget)
    {
        registered.remove(target);
    }
}
