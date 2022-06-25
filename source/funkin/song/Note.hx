package funkin.song;

import flixel.FlxSprite;
import flixel.util.FlxPool;

@:structInit
class Note
{
    public var time:Float;  // In beats.
    public var type:Null<Identifier> = null;
    public var skin:Null<Identifier> = null;
    public var sustainLength:Float = 0.0;  // In beats.
    public var data:Dynamic = null;  // Can be accessed read-only by scripts.

    // Additional states used by note tracks.
    public var passed:Bool = false;
    public var spawned:Bool = false;
}

class NoteSpriteBase extends FlxSprite {}

class NoteSprite extends NoteSpriteBase
{
    public var attachedNote:Note;

    public function new(attachedNote:Note)
    {
        super();
        this.attachedNote = attachedNote;

        frames = Paths.getSparrowAtlas("NOTE_assets", "shared");
        scale.set(0.7, 0.7);
        antialiasing = true;

        animation.addByPrefix("note", "purple0", 0, false);
        animation.addByPrefix("hold-piece", "purple hold piece", 0, false);
        animation.addByPrefix("hold-end", "pruple end hold", 0, false);

        animation.play("note");
    }
}

class StrumNoteSprite extends NoteSpriteBase
{
    public function new()
    {
        super();

        frames = Paths.getSparrowAtlas("NOTE_assets", "shared");
        scale.set(0.7, 0.7);
        antialiasing = true;

        animation.addByPrefix("strum-idle", "arrowLEFT", 0, false);
        animation.addByPrefix("strum-hit", "left confirm", 24, false);
        animation.addByPrefix("strum-press", "left press", 24, false);
    }
}
