package funkin;

import flixel.util.FlxDestroyUtil;

class ChartingState extends MusicBeatState
{
    private var startingSongId:Null<Identifier> = null;
    private var startingDifficulty:String = "normal";
    
    private var song:Null<Song> = null;
    
    override public function create()
    {
        super.create();
        
        if (startingSongId != null)
        {
            loadSong(startingSongId, startingDifficulty);
        }
    }
    
    public function loadSong(songId:Null<Identifier>, difficulty:String)
    {
        song = FlxDestroyUtil.destroy(song);
        if (songId != null)
        {
            song = new Song(songId).load(difficulty, false);
        }
    }
    
    public static function withSong(songId:Identifier, difficulty:String):ChartingState
    {
        var instance = new ChartingState();
        instance.startingSongId = songId;
        instance.startingDifficulty = difficulty;
        return instance;
    }
}
