package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;

#if (target.threaded)
import sys.thread.Deque;
import sys.thread.Thread;
#end

#if (target.threaded)
enum ProgressUpdate
{
    Begin(total:Int, message:String);
    Update(done:Int);
    End;
}
#end

class ProgressBar extends FlxSpriteGroup
{
    public final total:Int;
    public final message:String;
    
    public var done(default, set):Int = 0;
    
    private var text:FlxText;
    
    public function new(x:Float, y:Float, total:Int, message:String)
    {
        super(x, y);
        this.total = total;
        this.message = message;
        
        text = new FlxText(x, y, total > 0 ? '$message: 0 / $total' : '$message...');
        text.setFormat(FlxAssets.FONT_DEFAULT, 16, FlxColor.WHITE);
        text.alpha = 1.0;
        add(text);
        
        var bar = new FlxBar(x, y + 25, 500, 3, this, "done", 0, total, false);
        bar.createFilledBar(0xFF3C3C3C, 0xFFFABD2F);
        bar.alpha = 1.0;
        add(bar);
    }
    
    private function set_done(value:Int)
    {
        text.text = total > 0 ? '$message: $value / $total' : '$message...';
        return done = value;
    }
}

class ModLoadingState extends FlxState
{
    public static inline final PRELOAD_ASSETS:Bool = false;
    
    public static var nextState:Class<FlxState> = TitleState;
    
    #if (target.threaded)
    private var deque:Deque<ProgressUpdate> = new Deque();
    #end

    private var elements:Array<ProgressBar> = [];
    
    override public function create()
    {
        FlxG.mouse.visible = false;

        FlxG.worldBounds.set(0,0);
        
        Registry.noteTypes.register(new Identifier("core", "normal"), {});

        #if (target.threaded)
        Thread.create(function()
        {
            var modList = CoolUtil.coolTextFile("default:mods/mod-list.txt");
            deque.add(Begin(modList.length, "Loading mods"));
            for (index => mod in modList)
            {
                deque.add(Update(index));
                ModLoader.load(mod, false, PRELOAD_ASSETS, function(done, total)
                {
                    if (done == 0)
                    {
                        deque.add(Begin(total, 'Loading mod "$mod"'));
                    }
                    deque.add(Update(done));
                });
                deque.add(End);
            }
            deque.add(End);
        });
        #else
		var modList = CoolUtil.coolTextFile("default:mods/mod-list.txt");
		for (mod in modList)
		{
			ModLoader.load(mod);
		}
        FlxG.switchState(Type.createInstance(nextState, []));
        #end

        super.create();
    }
    
    override public function update(elapsed:Float)
    {
        #if (target.threaded)
        var update:Null<ProgressUpdate> = null;
        var lastUpdate:Null<ProgressUpdate> = null;
        while ((update = deque.pop(false)) != null)
        {
            lastUpdate = update;
            switch (update)
            {
                case Begin(total, message):
                    trace('$message...');
                    var element = new ProgressBar(10, 10 + 30 * elements.length, total, message);
                    add(element);
                    elements.push(element);
                case Update(done):
                    var element = elements[elements.length - 1];
                    element.done = done;
                case End:
                    var element = elements.pop();
                    trace('${element.message}: Done');
                    remove(element);
                    if (elements.length == 0)
                    {
                        FlxG.switchState(Type.createInstance(nextState, []));
                    }
            }
        }
        if (lastUpdate != null)
        {
            switch (lastUpdate)
            {
                case Update(done):
                    var element = elements[elements.length - 1];
                    trace('${element.message}: $done / ${element.total}');
                default:
            }
        }
        #end

        super.update(elapsed);
    }
}
