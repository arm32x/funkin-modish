package funkin;

import flixel.FlxG;
import flixel.FlxState;
import flixel.system.FlxSound;
import flixel.util.FlxDestroyUtil;
import funkin.song.Conductor;
import funkin.song.Song;

class NoteTracksTestState extends FlxState
{
    private var song:Song;

    private var instrumental:FlxSound;
    private var vocals:FlxSound;

    private var eventTarget:EventTarget;

    public function new()
    {
        super();
        
    }

    override public function create()
    {
        super.create();

        song = new Song(new Identifier("basegame", "blammed")).load("hard");
        for (index => track in song.tracks)
        {
            track.y = 50;
            track.screenCenter(X);
            track.x += (index - 4.5) * 110; // ocd positioning :)
            if (index >= 4)
                track.x += 220;
            add(track);
        }

        Conductor.bpmChanges = song.bpmChanges;

        // TODO: Move this to the Song class.
        if (FlxG.sound.music != null)
            FlxG.sound.music.stop();
        instrumental = new FlxSound().loadEmbedded(song.id.getAssetPath("songs", "instrumental", "ogg"));
        vocals = new FlxSound().loadEmbedded(song.id.getAssetPath("songs", "vocals", "ogg"));
        FlxG.sound.list.add(instrumental);
        instrumental.play();
        FlxG.sound.list.add(vocals);
        vocals.play();
        Conductor.offset = 53;

        eventTarget = EventTarget.register(new EventTarget(), "song");
        eventTarget.on(new Identifier("core", "note-pass"), e -> {
            e.data.track.strumLine.animation.play("strum-hit", true);
        });
    }

    override public function update(elapsed:Float)
    {
        Conductor.songPosition = instrumental.time;

        super.update(elapsed);
    }

    override public function destroy()
    {
        eventTarget = FlxDestroyUtil.destroy(eventTarget);
    }
}

