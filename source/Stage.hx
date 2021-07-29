package;

import flixel.util.FlxDestroyUtil;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import lime.utils.Assets;
import haxe.Json;
import haxe.extern.EitherType;
import flixel.group.FlxGroup;

// See 'mods/basegame/stages/stage-schema.json' for full schema.
typedef StageData =
{
    var ?sprites:Array<{
        var ?type:String;
        var position:Array<Float>;
        var ?scrollFactor:Array<Float>;
        var ?scale:Array<Float>;
        var ?id:Null<String>;
        var graphic:String;
        var ?group:Null<String>;
        var ?distraction:Bool;
        var ?antialiasing:Bool;
        var ?alpha:Float;
        var ?visible:Bool;
        var ?animated:Bool;
        var ?animations:Array<{
            var name:String;
            var ?prefix:String;
            var ?indices:Array<Int>;
            var ?postfix:String;
            var ?frameRate:Int;
            var ?looped:Bool;
        }>;
        var ?startingAnimation:{
            var name:String;
            var ?force:Bool;
            var ?reversed:Bool;
            var ?frame:Int;
        };
    }>;
    var ?zoom:Float;
};

class Stage extends FlxGroup
{
    public final id:Identifier;
    
    public var zoom(default, null):Float = 1.0;
    public var playerPosition(default, null):FlxPoint = FlxPoint.get();
    public var girlfriendPosition(default, null):FlxPoint = FlxPoint.get();
    public var opponentPosition(default, null):FlxPoint = FlxPoint.get();
    
    private var spritesById:Map<String, FlxSprite> = [];
    private var groupsById:Map<String, FlxTypedGroup<FlxSprite>> = [];
    
    private var script:Null<Script> = null;
    
    public function new(id:Identifier) {
        super();
        this.id = id;
    }
    
    public function load(runScripts:Bool = false)
    {
        var data:StageData = Json.parse(Assets.getText(id.getAssetPath("stages", null, "json")));

        if (data.zoom != null)
        {
            zoom = data.zoom;
        }

        if (data.sprites != null)
        {
            for (spr in data.sprites)
            {
                switch (spr.type)
                {
                    case "player":
                        playerPosition.set(spr.position[0], spr.position[1]);
                    case "girlfriend":
                        girlfriendPosition.set(spr.position[0], spr.position[1]);
                    case "opponent":
                        opponentPosition.set(spr.position[0], spr.position[1]);
                    default:
                        if (spr.distraction == true && !FlxG.save.data.distractions)
                        {
                            continue;
                        }

                        var sprite = new FlxSprite(spr.position[0], spr.position[1]);
                        
                        if (spr.animated == true)
                        {
                            sprite.frames = HelperFunctions.getAtlas(id, "stages", spr.graphic);

                            for (index => anim in spr.animations)
                            {
                                var frameRate = anim.frameRate != null ? anim.frameRate : 30;
                                var looped = anim.looped != null ? anim.looped : true;
                                
                                switch ([anim.prefix, anim.indices])
                                {
                                    case [null, null]:
                                        trace('Animation "${anim.name}" on sprite ${spr.id != null ? '"${spr.id}"' : Std.string(index)} in stage "$id" is invalid: Neither "prefix" nor "indices" is specified.');
                                        continue;
                                    case [prefix, null]:
                                        sprite.animation.addByPrefix(anim.name, prefix, frameRate, looped);
                                    case [null, indices]:
                                        sprite.animation.add(anim.name, indices, frameRate, looped);
                                    case [prefix, indices]:
                                        var postfix = anim.postfix != null ? anim.postfix : "";
                                        sprite.animation.addByIndices(anim.name, prefix, indices, postfix, frameRate, looped);
                                }
                            }
                            
                            if (spr.startingAnimation != null)
                            {
                                var force = spr.startingAnimation.force != null ? spr.startingAnimation.force : false;
                                var reversed = spr.startingAnimation.reversed != null ? spr.startingAnimation.reversed : false;
                                var frame = spr.startingAnimation.frame != null ? spr.startingAnimation.frame : 0;
                                sprite.animation.play(spr.startingAnimation.name, force, reversed, frame);
                            }
                        }
                        else
                        {
                            sprite.loadGraphic(id.getAssetPath("stages", spr.graphic, "png"));
                        }
                        
                        if (spr.scrollFactor != null)
                        {
                            sprite.scrollFactor.set(spr.scrollFactor[0], spr.scrollFactor[1]);
                        }
                        if (spr.scale != null)
                        {
                            sprite.scale.set(spr.scale[0], spr.scale[1]);
                        }
                        sprite.antialiasing = spr.antialiasing != null ? spr.antialiasing : false;
                        sprite.alpha = spr.alpha != null ? spr.alpha : 1.0;
                        sprite.visible = spr.visible != null ? spr.visible : true;
                        
                        if (spr.id != null)
                        {
                            spritesById.set(spr.id, sprite);
                        }
                        if (spr.group != null)
                        {
                            if (groupsById.exists(spr.group))
                            {
                                var group = groupsById.get(spr.group);
                                group.add(sprite);
                            }
                            else
                            {
                                var group = new FlxTypedGroup<FlxSprite>();
                                groupsById.set(spr.group, group);
                                add(group);
                                group.add(sprite);
                            }
                        }
                        else
                        {
                            add(sprite);
                        }
                }
            }
        }
        
        if (runScripts)
        {
            script = FlxDestroyUtil.destroy(script);
            script = EventTarget.register(new Script("stages", id), "stage");
            script.run([
                "sprites" => spritesById,
                "groups" => groupsById
            ]);
        }
    }
}
