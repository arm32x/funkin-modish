package;

import flixel.FlxSprite;
import format.csv.Data;
import format.csv.Reader;
import haxe.Exception;
import openfl.utils.Assets;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;
	
	private final isPlayer:Bool;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		this.isPlayer = isPlayer;
		
		antialiasing = true;
		loadIcon(char);
		animation.play(char);
		
		scrollFactor.set();
	}
	
	public function loadIcon(char:String)
	{
		var csv = Assets.getText(Paths.csv("healthIcons"));
		var reader = new Reader();
		reader.open(csv);
		
		var charRecord:Null<Record> = null;
		for (record in reader)
		{
			if (record.length >= 1 && record[0] == char)
			{
				charRecord = record;
				break;
			}
		}

		if (charRecord != null)
		{
			if (charRecord.length >= 4)
			{
				loadGraphic(Paths.image(charRecord[1]), true, 150, 150);
				var alive = Std.parseInt(charRecord[2]);
				if (alive == null)
				{
					throw new Exception('Alive icon index for character "$char" must be an integer.');
				}
				var dead = Std.parseInt(charRecord[3]);
				if (dead == null)
				{
					throw new Exception('Alive icon index for character "$char" must be an integer.');
				}
				animation.add(char, [alive, dead], 0, false, isPlayer);
				
				if (charRecord.length >= 5 && charRecord[4] == "noaa")
				{
					antialiasing = false;
				}
			}
			else
			{
				throw new Exception('Character "$char" is missing data in "healthIcons.csv".');
			}
		}
		else
		{
			throw new Exception('Character "$char" has no health icon in "healthIcons.csv".');
		}
	}
	
	public function setIcon(char:String)
	{
		if (animation.getByName(char) == null)
		{
			loadIcon(char);
		}
		animation.play(char);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
