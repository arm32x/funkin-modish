package funkin.song;

import haxe.ds.ArraySort;
import haxe.Exception;
import flixel.FlxG;

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

	@:deprecated
	public static function mapBPMChanges(song:Song)
	{
		bpmChanges = song.bpmChanges;
	}

    public static function setConstantBPM(bpm:Float):Float
    {
        extendedBPMChanges = [{milliseconds: 0, time: 0, bpm: bpm}];
        updateTime();
        return bpm;
    }


    // Using these functions repeatedly may cause floating point rounding error.
    public static inline function beatsToMilliseconds(bpm:Float, beats:Float):Float
    {
        return beats * (60 / bpm * 1000);
    }
    public static inline function millisecondsToBeats(bpm:Float, millis:Float):Float
    {
        return millis / (60 / bpm * 1000);
    }

    private static inline function get_bpmChanges():Array<BPMChange>
    {
        return extendedBPMChanges;
    }

    private static function set_bpmChanges(changes:Array<BPMChange>):Array<BPMChange>
    {
        ArraySort.sort(changes, (a, b) -> Reflect.compare(a.time, b.time));
        if (changes.length == 0 || changes[0].time != 0)
            throw new Exception("There must be a BPM change at time 0");

        var currentBPM:Float = 0;
        var currentTime:Float = 0;
        var currentPosition:Float = 0;

        extendedBPMChanges = [];

        for (change in changes)
        {
            if (currentBPM != 0)
                currentPosition += beatsToMilliseconds(currentBPM, change.time - currentTime);
            currentTime = change.time;
            currentBPM = change.bpm;

            extendedBPMChanges.push({milliseconds: currentPosition, time: currentTime, bpm: currentBPM});
        }

        updateTime();
        return extendedBPMChanges;
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
