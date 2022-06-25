package funkin.util;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.animation.FlxAnimationController;

typedef AnimationSetJson =
{
    var ?animations:Array<{
        var name:String;
        var ?prefix:String;
        var ?indices:Array<Int>;
        var ?postfix:String;
        var ?frameRate:Int;
        var ?looped:Bool;
        var ?offset:Array<Float>;
        var ?priority:Int;
    }>;
    var ?startingAnimation:{
        var name:String;
        var ?force:Bool;
        var ?reversed:Bool;
        var ?frame:Int;
    };
};

class AnimationSet extends FlxAnimationController
{
    private final offsets:Map<String, FlxPoint> = [];
    private final priorities:Map<String, Int> = [];

    public static function fromJson(sprite:FlxSprite, json:AnimationSetJson):AnimationSet
    {
        var animationSet = new AnimationSet(sprite);

        for (anim in json.animations)
        {
            var frameRate = anim.frameRate != null ? anim.frameRate : 30;
            var looped = anim.looped == true;

            switch ([anim.prefix, anim.indices])
            {
                case [null, null]:
                    trace('Animation "${anim.name}" is invalid: Neither "prefix" nor "indices" is specified.');
                    continue;
                case [prefix, null]:
                    animationSet.addByPrefix(anim.name, prefix, frameRate, looped);
                case [null, indices]:
                    animationSet.add(anim.name, indices, frameRate, looped);
                case [prefix, indices]:
                    var postfix = anim.postfix != null ? anim.postfix : "";
                    animationSet.addByIndices(anim.name, prefix, indices, postfix, frameRate, looped);
            }

            if (anim.offset != null)
                animationSet.offsets.set(anim.name, FlxPoint.get(anim.offset[0], anim.offset[1]));
            animationSet.priorities.set(anim.name, anim.priority != null ? anim.priority : 0);
        }

        if (json.startingAnimation != null)
        {
            var force = json.startingAnimation.force != null ? json.startingAnimation.force : false;
            var reversed = json.startingAnimation.reversed != null ? json.startingAnimation.reversed : false;
            var frame = json.startingAnimation.frame != null ? json.startingAnimation.frame : 0;
            animationSet.play(json.startingAnimation.name, force, reversed, frame);
        }

        return animationSet;
    }

    override public function play(animName:String, force:Bool = false, reversed:Bool = false, frame:Int = 0)
    {
		if (curAnim != null
            && !curAnim.finished
            && priorities.get(curAnim.name) > priorities.get(animName))
            return;

        super.play(animName, force, reversed, frame);

        // FIXME: This completely overwrites the sprite's offset.
        var offset = offsets.get(animName);
        if (offset != null)
            _sprite.offset.copyFrom(offset);
        else
            _sprite.offset.set(0, 0);
    }

    override public function destroy()
    {
        super.destroy();

        for (_ => offset in offsets)
            offset.put();
        offsets.clear();

        priorities.clear();
    }
}
