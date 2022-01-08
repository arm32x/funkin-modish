package funkin;

import flixel.FlxSubState;
import funkin.song.Conductor;

class MusicBeatSubstate extends FlxSubState
{
	private var oldStep:Int = 0;

	private var curStep(get, never):Int;
	private var curBeat(get, never):Int;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function update(elapsed:Float)
	{
		if (oldStep != curStep && curStep > 0)
			stepHit();
		oldStep = curStep;

		super.update(elapsed);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}
	
	private inline function get_curStep():Int
	{
		return Conductor.curStep;
	}
	private inline function get_curBeat():Int
	{
		return Conductor.curBeat;
	}
}
