package funkin;

import flixel.FlxG;

using StringTools;

class Highscore
{
	public static var songScores:Map<String, Int> = new Map();
	public static var songCombos:Map<String, String> = new Map();

	public static function saveScore(song:Identifier, score:Int = 0, ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);


		#if !switch
		NGio.postScore(score, song.toString());
		#end

		if(!FlxG.save.data.botplay)
		{
			if (songScores.exists(daSong))
			{
				if (songScores.get(daSong) < score)
					setScore(daSong, score);
			}
			else
				setScore(daSong, score);
		}else trace('BotPlay detected. Score saving is disabled.');
	}

	public static function saveCombo(song:Identifier, combo:String, ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);
		var finalCombo:String = combo.split(')')[0].replace('(', '');

		if(!FlxG.save.data.botplay)
		{
			if (songCombos.exists(daSong))
			{
				if (getComboInt(songCombos.get(daSong)) < getComboInt(finalCombo))
					setCombo(daSong, finalCombo);
			}
			else
				setCombo(daSong, finalCombo);
		}
	}

	public static function saveWeekScore(week:Identifier, score:Int = 0, ?diff:Int = 0):Void
	{
		var daWeek:String = formatSong("week", week, diff);

		#if !switch
		NGio.postScore(score, daWeek);
		#end

		if(!FlxG.save.data.botplay)
		{

			if (songScores.exists(daWeek))
			{
				if (songScores.get(daWeek) < score)
					setScore(daWeek, score);
			}
			else
				setScore(daWeek, score);
		}else trace('BotPlay detected. Score saving is disabled.');
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}

	static function setCombo(song:String, combo:String):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songCombos.set(song, combo);
		FlxG.save.data.songCombos = songCombos;
		FlxG.save.flush();
	}

	// TODO: Make difficulties strings.
	static function formatSong(?prefix:String, song:Identifier, diff:Int):String
	{
		if (prefix != null)
			return '$prefix $song ${CoolUtil.difficultyFromInt(diff).toLowerCase()}';
		else
			return '$song ${CoolUtil.difficultyFromInt(diff).toLowerCase()}';
	}

	static function getComboInt(combo:String):Int
	{
		switch(combo)
		{
			case 'SDCB':
				return 1;
			case 'FC':
				return 2;
			case 'GFC':
				return 3;
			case 'MFC':
				return 4;
			default:
				return 0;
		}
	}

	public static function getScore(song:Identifier, diff:Int):Int
	{
		if (!songScores.exists(formatSong(song, diff)))
			setScore(formatSong(song, diff), 0);

		return songScores.get(formatSong(song, diff));
	}

	public static function getCombo(song:Identifier, diff:Int):String
	{
		if (!songCombos.exists(formatSong(song, diff)))
			setCombo(formatSong(song, diff), '');

		return songCombos.get(formatSong(song, diff));
	}

	public static function getWeekScore(week:Identifier, diff:Int):Int
	{
		if (!songScores.exists(formatSong('week', week, diff)))
			setScore(formatSong('week', week, diff), 0);

		return songScores.get(formatSong('week', week, diff));
	}

	public static function load():Void
	{
		if (FlxG.save.data.songScores != null)
		{
			songScores = FlxG.save.data.songScores;
		}
		if (FlxG.save.data.songCombos != null)
		{
			songCombos = FlxG.save.data.songCombos;
		}
	}
}
