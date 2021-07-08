package;

import Registry.SongMetadata;
import Controls.KeyboardScheme;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
#if sys
import sys.io.File;
#end

class LoadReplayState extends MusicBeatState
{
	var selector:FlxText;
	var curSelected:Int = 0;

    var songs:Array<Registry.Entry<SongMetadata>> = [];

	var controlsStrings:Array<String> = [];
    var actualNames:Array<String> = [];

	private var grpControls:FlxTypedGroup<Alphabet>;
	var versionShit:FlxText;
	var poggerDetails:FlxText;
	override function create()
	{
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        #if desktop
		controlsStrings = sys.FileSystem.readDirectory(Sys.getCwd() + "/assets/replays/");
        #end
		trace(controlsStrings);

        controlsStrings.sort(Reflect.compare);

		songs = Registry.songs.getAllEntries();

        for(i in 0...controlsStrings.length)
        {
            var string:String = controlsStrings[i];
            actualNames[i] = string;
			var rep:Replay = Replay.LoadReplay(string);
            controlsStrings[i] = string.split("time")[0] + " " + CoolUtil.difficultyFromInt(rep.replay.songDiff).toUpperCase();
        }

        if (controlsStrings.length == 0)
            controlsStrings.push("No Replays...");

		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...controlsStrings.length)
		{
				var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, controlsStrings[i], true, false);
				controlLabel.isMenuItem = true;
				controlLabel.targetY = i;
				grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}


		versionShit = new FlxText(5, FlxG.height - 34, 0, "Replay Loader (ESCAPE TO GO BACK)\nNOTICE!!!! Replays are in a beta stage, and they are probably not 100% correct. expect misses and other stuff that isn't there!\n", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		
		poggerDetails = new FlxText(5, 34, 0, "Replay Details - \nnone", 12);
		poggerDetails.scrollFactor.set();
		poggerDetails.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(poggerDetails);

		changeSelection(0);

		super.create();
	}

    public function getWeekIdFromSongId(songId:Identifier):Null<Identifier>
    {
        var week:Identifier = null;
        for (i in 0...songs.length)
        {
            var pog = songs[i];
            if (pog.id.equals(songId))
                week = pog.item.week;
        }
        return week;
    }

    public function getSongNameFromSongId(songId:Identifier):String
    {
        var name:String = "Unknown";
        for (i in 0...songs.length)
        {
            var pog = songs[i];
            if (pog.id.equals(songId))
                name = pog.item.name;
        }
        return name;
    }

	// public function addSong(songId:Identifier, songName:String, weekNum:Int, songIcon:Identifier)
    //     {
    //         songs.push(new FreeplayState.SongMetadata(songId, songName, weekNum, songIcon));
    //     }
    
    //     public function addWeek(songIds:Array<Identifier>, songs:Array<String>, weekNum:Int, ?songIcons:Array<Identifier>)
    //     {
    //         if (songIcons == null)
    //             songIcons = [new Identifier("basegame", "bf")];
    
    //         var num:Int = 0;
    //         for (index => id in songIds)
    //         {
    //             addSong(id, songs[index], weekNum, songIcons[num]);
    
    //             if (songIcons.length != 1)
    //                 num++;
    //         }
    //     }
    

	override function update(elapsed:Float)
	{
		super.update(elapsed);

			if (controls.BACK)
				FlxG.switchState(new OptionsMenu());
			if (controls.UP_P)
				changeSelection(-1);
			if (controls.DOWN_P)
				changeSelection(1);
		

			if (controls.ACCEPT && grpControls.members[curSelected].text != "No Replays...")
			{
                trace('loading ' + actualNames[curSelected]);
                PlayState.rep = Replay.LoadReplay(actualNames[curSelected]);

                PlayState.loadRep = true;

				if (PlayState.rep.replay.replayGameVer == Replay.version)
				{
					PlayState.SONG = new Song(Identifier.parse(PlayState.rep.replay.songId)).load(CoolUtil.difficultyFromInt(PlayState.rep.replay.songDiff).toLowerCase());
					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = PlayState.rep.replay.songDiff;
					PlayState.storyWeek = getWeekIdFromSongId(Identifier.parse(PlayState.rep.replay.songId));
					LoadingState.loadAndSwitchState(new PlayState());
				}
				else
				{
					PlayState.rep = null;
					PlayState.loadRep = false;
				}
			}
	}

	var isSettingControl:Bool = false;

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent('Fresh');
		#end
		
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		var rep:Replay = Replay.LoadReplay(actualNames[curSelected]);

		poggerDetails.text = "Replay Details - \nDate Created: " + rep.replay.timestamp + "\nSong: " + getSongNameFromSongId(Identifier.parse(rep.replay.songId)) + "\nReplay Version: " + (rep.replay.replayGameVer != Replay.version ? "OUTDATED not useable!" : "Latest");

		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
