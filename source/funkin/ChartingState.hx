package funkin;

import flixel.FlxG;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.system.FlxSound;
import flixel.util.FlxDestroyUtil;

class ChartingState extends MusicBeatState
{
    private static final PLAY_PAUSE_ACTION:FlxActionDigital = new FlxActionDigital().addKey(SPACE, JUST_PRESSED);
    private static final TOGGLE_METRONOME_ACTION:FlxActionDigital = new FlxActionDigital().addKey(M, JUST_PRESSED);
    
    // These are static so they stay when reloaded with F5.
    private static var startingSongId:Null<Identifier> = null;
    private static var startingDifficulty:String = "normal";
    
    private var song:Null<Song> = null;
    
    private var instrumental:Null<FlxSound> = null;
    private var vocals:Null<FlxSound> = null;
    private var playing(get, never):Bool;
    
    private var metronome:Bool = false;
    private final metronomeHighSound:FlxSound = new FlxSound().loadEmbedded(Paths.sound("metronome-high"));
    private final metronomeLowSound:FlxSound = new FlxSound().loadEmbedded(Paths.sound("metronome-low"));
    
    private function new()
    {
        super();
    }
    
    override public function create()
    {
        super.create();
        
        FlxG.sound.music.stop();
        
        if (startingSongId != null)
        {
            loadSong(startingSongId, startingDifficulty);
        }
    }
    
    public function loadSong(songId:Null<Identifier>, difficulty:String)
    {
        song = FlxDestroyUtil.destroy(song);
        instrumental = FlxDestroyUtil.destroy(instrumental);
        vocals = FlxDestroyUtil.destroy(vocals);
        
        if (songId != null)
        {
            song = new Song(songId).load(difficulty, false);

            // TODO: Render the waveform of the audio behind the editor.
            instrumental = new FlxSound().loadEmbedded(song.id.getAssetPath("songs", "instrumental", Paths.SOUND_EXT));
            FlxG.sound.list.add(instrumental);
            if (song.meta.hasVocals)
            {
                vocals = new FlxSound().loadEmbedded(song.id.getAssetPath("songs", "vocals", Paths.SOUND_EXT));
                FlxG.sound.list.add(vocals);
            }
            
            Conductor.mapBPMChanges(song);
        }
    }
    
    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        
        if (playing)
            Conductor.songPosition = instrumental.time;
        
        if (PLAY_PAUSE_ACTION.check())
        {
            if (playing)
                pause();
            else
                play();
        }
        
        if (TOGGLE_METRONOME_ACTION.check())
        {
            metronome = !metronome;
            trace('metronome ${metronome ? "on" : "off"}');
        }
    }
    
    override public function beatHit()
    {
        super.beatHit();
        
        if (metronome)
        {
            if (curBeat % 4 == 0)
                metronomeHighSound.play(true);
            else
                metronomeLowSound.play(true);
        }
    }
    
    public function play()
    {
        if (instrumental != null)
            instrumental.play();
        if (vocals != null)
            vocals.play();
    }
    
    public function pause()
    {
        if (instrumental != null)
            instrumental.pause();
        if (vocals != null)
            vocals.pause();
    }
    
    private function get_playing():Bool
    {
        return instrumental != null && instrumental.playing;
    }
    
    public static function empty():ChartingState
    {
        startingSongId = null;
        startingDifficulty = "normal";
        return new ChartingState();
    }
    
    public static function withSong(songId:Identifier, difficulty:String):ChartingState
    {
        startingSongId = songId;
        startingDifficulty = difficulty;
        return new ChartingState();
    }
}
