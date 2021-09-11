package funkin;

import funkin.gui.MenuBar;
import flixel.FlxG;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.system.FlxSound;
import flixel.util.FlxDestroyUtil;

class ChartEditorState extends MusicBeatState
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

        FlxG.mouse.visible = true;
        FlxG.mouse.useSystemCursor = true;
        
        bgColor = 0xFF1F1F1F;
        
        var menuBar = MenuBar.builder()
            .withAction("File", () -> trace("Clicked File."))
            .withAction("Edit", () -> trace("Clicked Edit."))
            .withAction("View", () -> trace("Clicked View."))
            .withSubMenu("Test")
                .withAction("Test 1", () -> trace("Clicked Test 1."))
                .withAction("Test 2", () -> trace("Clicked Test 2."))
                .withSubMenu("Test 3")
                    .withAction("Test 4", () -> trace("Clicked Test 4."))
                    .withAction("Test 5", () -> trace("Clicked Test 5."))
                .end()
            .end()
            .withAction("Exit", () -> FlxG.switchState(new TitleState())) // Temporary.
            .build();
        add(menuBar);
        
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
            Conductor.changeBPM(song.chart.bpm);
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
    
    public static function empty():ChartEditorState
    {
        startingSongId = null;
        startingDifficulty = "normal";
        return new ChartEditorState();
    }
    
    public static function withSong(songId:Identifier, difficulty:String):ChartEditorState
    {
        startingSongId = songId;
        startingDifficulty = difficulty;
        return new ChartEditorState();
    }
}
