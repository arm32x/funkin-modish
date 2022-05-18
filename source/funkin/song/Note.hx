package funkin.song;

import flixel.FlxSprite;

@:structInit
class Note
{
    public var time:Float;  // In beats.
    public var type:Null<Identifier> = null;
    public var skin:Null<Identifier> = null;
    public var sustainLength:Float = 0.0;  // In beats.
    public var data:Dynamic = null;  // Can be accessed read-only by scripts.

    // Additional state used by note tracks.
    public var passed:Bool = false;
}

class NoteSprite extends FlxSprite
{

}

