package funkin.song;

import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.song.Note.NoteSprite;

class NoteTrack extends FlxTypedGroup<NoteSprite>
{
    public var targetCharacter:Null<String> = null;
    public var tag:Null<String> = null;

    public var variant:Null<String> = null;
    public var defaultNoteType:Identifier = new Identifier("core", "normal");
    public var defaultNoteSkin:Null<Identifier> = null;

    public var notes:Array<Note> = [];

    public function new()
    {
        super();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        for (note in notes)
        {
            if (!note.passed && Conductor.time >= note.time)
            {
                note.passed = true;
                EventTarget.CORE.fire(["song"], new Identifier("core", "note-pass"), {note: note, track: this});
            }
        }
    }
}

