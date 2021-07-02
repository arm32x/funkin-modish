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

	public function new(id:Identifier, isPlayer:Bool = false)
	{
		super();
		this.isPlayer = isPlayer;
		
		antialiasing = true;
		loadIcon(id);
		animation.play(id.toString());
		
		scrollFactor.set();
	}
	
	public function loadIcon(id:Identifier)
	{
		var data = Registry.healthIcons.get(id);
		if (data == null) {
			throw new Exception('Health icon "$id" does not exist.');
		}

		loadGraphic(id.getAssetPath("health-icons", null, "png"), true, 150, 150);
		animation.add(id.toString(), [0, 1], 0, false, isPlayer);
		antialiasing = data.antialiasing;
	}
	
	public function setIcon(id:Identifier)
	{
		loadIcon(id);
		animation.play(id.toString());
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
