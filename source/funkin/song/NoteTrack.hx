package funkin.song;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import funkin.song.Note.NoteSprite;
import funkin.song.Note.NoteSpriteBase;
import funkin.song.Note.StrumNoteSprite;

class NoteTrack extends FlxTypedSpriteGroup<NoteSpriteBase>
{
    public var targetCharacter:Null<String> = null;
    public var tag:Null<String> = null;

    public var variant:Null<String> = null;
    public var defaultNoteType:Identifier = new Identifier("core", "normal");
    public var defaultNoteSkin:Null<Identifier> = null;

    public var strumLine = new StrumNoteSprite();
    public var notes:Array<Note> = [];

    public function new()
    {
        super();
        add(strumLine);
        strumLine.animation.play("strum-idle");
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        for (note in notes)
        {
            if (Conductor.beatsToMilliseconds(Conductor.bpm, note.time) - Conductor.songPosition + 50 < FlxG.height && !note.spawned)
            {
                trace('addeded note at ' + note.time);
                add(new NoteSprite(note));
                note.spawned = true;
            }

            if (!note.passed && Conductor.time >= note.time)
            {
                note.passed = true;
                EventTarget.CORE.fire(["song"], new Identifier("core", "note-pass"), {note: note, track: this});
            }
        }

        for (member in members)
        {
            if (member is NoteSprite)
            {
                trace('found one');
                var sprite = cast(member, NoteSprite);
                sprite.y = Conductor.beatsToMilliseconds(Conductor.bpm, sprite.attachedNote.time) - Conductor.songPosition + 50;
                if (sprite.attachedNote.passed)
                {
                    sprite.destroy();
                    remove(sprite);
                }
            }
        }

        if (strumLine.animation.finished)
            strumLine.animation.play("strum-idle");
    }
}

