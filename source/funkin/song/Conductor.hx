package funkin.song;

import haxe.Exception;
import flixel.FlxG;
import funkin.Song;

/**
 * ...
 * @author
 */

typedef BPMChange =
{
    // The time of the BPM change, in beats.
    var time:Float;
    // The BPM to change to.
    var bpm:Float;
};

typedef ExtendedBPMChange =
{
    > BPMChange,
    // The time of the BPM change, in milliseconds.
    var milliseconds:Float;
};

class Conductor
{
    // The current BPM of the song.
    // 
    // This is dependent on the current song time, and will update according to
    // the currently effective BPM.
    // 
    // Setting this variable clears the current BPM map and sets the BPM to a
    // constant number.
    public static var bpm(default, null):Float;
    // A list of BPM changes in the current song.
    public static var bpmChanges(get, set):Array<BPMChange>;
    private static var extendedBPMChanges:Array<ExtendedBPMChange> = [];
    
    // The current song time, in beats.
    public static var time(default, null):Float = 0;
    // The current song time, in milliseconds.
    public static var songPosition(default, set):Float = 0;

    // Convenience properties for accessing rounded versions of the song time.
    public static var curBeat(get, never):Int;
    public static var curStep(get, never):Int;

	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds
	public static var lastSongPos:Float;
	public static var offset:Float = 0;

	public static var safeFrames:Int = 10;
	public static var safeZoneOffset:Float = Math.floor((safeFrames / 60) * 1000); // is calculated in create(), is safeFrames in milliseconds
	public static var timeScale:Float = Conductor.safeZoneOffset / 166;

	public function new()
	{
	}

    private static function updateTime()
    {
        // This code assumes extendedBPMChanges is sorted.
        var lastChange = null;
        for (change in extendedBPMChanges)
        {
            if (songPosition >= change.milliseconds)
                lastChange = change;
        }
        
        if (lastChange != null)
        {
            bpm = lastChange.bpm;
            crochet = beatsToMilliseconds(bpm, 1);
            stepCrochet = beatsToMilliseconds(bpm, 0.25);
            
            time = (songPosition - lastChange.milliseconds) / crochet + lastChange.time;
        }
        else
            trace("Warning: Conductor updated without setting BPM first");
    }
    
    private static inline function set_songPosition(songPosition:Float):Float
    {
        Conductor.songPosition = songPosition;
        updateTime();
        return songPosition;
    }

	public static function recalculateTimings()
	{
		Conductor.safeFrames = FlxG.save.data.frames;
		Conductor.safeZoneOffset = Math.floor((Conductor.safeFrames / 60) * 1000);
		Conductor.timeScale = Conductor.safeZoneOffset / 166;
	}

	public static function mapBPMChanges(song:Song)
	{
		extendedBPMChanges = [{bpm: song.chart.bpm, time: 0, milliseconds: 0}];

		var curBPM:Float = song.chart.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;

		for (section in song.chart.sections)
		{
			if(section.bpm != null && section.bpm != curBPM)
			{
				curBPM = section.bpm;
				var event:ExtendedBPMChange = {
					time: totalSteps / 4,
					milliseconds: totalPos,
					bpm: curBPM
				};
				extendedBPMChanges.push(event);
			}

			var deltaSteps:Int = 16;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
		trace("new BPM map BUDDY " + extendedBPMChanges);
        updateTime();
	}

    public static function setConstantBPM(bpm:Float):Float
    {
        extendedBPMChanges = [{milliseconds: 0, time: 0, bpm: bpm}];
        updateTime();
        return bpm;
    }


    // Using these functions repeatedly may cause floating point rounding error.
    private static inline function beatsToMilliseconds(bpm:Float, beats:Float):Float
    {
        return beats * (60 / bpm * 1000);
    }
    private static inline function millisecondsToBeats(bpm:Float, millis:Float):Float
    {
        return millis / (60 / bpm * 1000);
    }
    
    private static inline function get_bpmChanges():Array<BPMChange>
    {
        return extendedBPMChanges;
    }
    
    private static function set_bpmChanges(changes:Array<BPMChange>):Array<BPMChange>
    {
        throw new Exception("Not yet implemented");
        // extendedBPMChanges = addMillisecondsToBPMChanges(changes);
        // updateTime();
        // return extendedBPMChanges;
    }
    
    private static inline function get_curBeat():Int
    {
        return Math.floor(time);
    }

    private static inline function get_curStep():Int
    {
        return Math.floor(time * 4);
    }
}
