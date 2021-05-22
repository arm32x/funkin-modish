package;

import haxe.Exception;
import haxe.Json;
import openfl.utils.Assets;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

typedef MenuCharacterJSON = {
	var type:String;
	var atlas:String;
	var prefix:String;
	var ?indices:Array<Int>;
	var ?postfix:String;
	var ?frameRate:Int;
	var ?looped:Bool;
	var ?x:Int;
	var ?y:Int;
	var ?scale:Float;
	var ?flipped:Bool;
};

class MenuCharacter extends FlxSprite
{
	// private static var settings:Map<String, CharacterSetting> = [
	// 	'bf' => new CharacterSetting(0, -20, 1.0, true),
	// 	'gf' => new CharacterSetting(50, 80, 1.5, true),
	// 	'dad' => new CharacterSetting(-15, 130),
	// 	'spooky' => new CharacterSetting(20, 30),
	// 	'pico' => new CharacterSetting(0, 0, 1.0, true),
	// 	'mom' => new CharacterSetting(-30, 140, 0.85),
	// 	'parents-christmas' => new CharacterSetting(100, 130, 1.8),
	// 	'senpai' => new CharacterSetting(-40, -45, 1.4)
	// ];
	
	private static var cachedData:Map<String, MenuCharacterJSON> = [];
	private var currentAtlas:Null<String> = null;

	private var initialScale:Float;
	private var flipped:Bool = false;

	public function new(x:Int, y:Int, scale:Float, flipped:Bool)
	{
		super(x, y);
		this.initialScale = scale;
		this.flipped = flipped;

		antialiasing = true;

		// frames = Paths.getSparrowAtlas('campaign_menu_UI_characters');

		// animation.addByPrefix('bf', "BF idle dance white", 24);
		// animation.addByPrefix('bfConfirm', 'BF HEY!!', 24, false);
		// animation.addByPrefix('gf', "GF Dancing Beat WHITE", 24);
		// animation.addByPrefix('dad', "Dad idle dance BLACK LINE", 24);
		// animation.addByPrefix('spooky', "spooky dance idle BLACK LINES", 24);
		// animation.addByPrefix('pico', "Pico Idle Dance", 24);
		// animation.addByPrefix('mom', "Mom Idle BLACK LINES", 24);
		// animation.addByPrefix('parents-christmas', "Parent Christmas Idle", 24);
		// animation.addByPrefix('senpai', "SENPAI idle Black Lines", 24);

		setGraphicSize(Std.int(width * scale));
		updateHitbox();
	}
	
	private function loadCharacter(character:String):MenuCharacterJSON
	{
		var data = cachedData.get(character);
		if (data != null)
		{
			return data;
		}
		else
		{
			var json = Assets.getText(Paths.json('menu-characters/$character'));	
			var newData:MenuCharacterJSON = Json.parse(json);
			cachedData.set(character, newData);
			return newData;
		}
	}

	public function setCharacter(character:String):Void
	{
		if (character == '')
		{
			visible = false;
			return;
		}
		else
		{
			visible = true;
		}

		var data = loadCharacter(character);

		if (data.atlas != currentAtlas)
		{
			if (frames != null)
			{
				frames.destroy();
			}
			animation.destroyAnimations();
			frames = Paths.getAtlas(data.type, data.atlas);
			currentAtlas = data.atlas;
			
			// Setting 'frames' resets the size of the sprite.
			setGraphicSize(Std.int(width * initialScale));
			updateHitbox();
		}
		
		if (animation.getByName(character) == null)
		{
			var frameRate = data.frameRate != null ? data.frameRate : 30;
			var looped = data.looped != null ? data.looped : true;
			if (data.indices != null)
			{
				var postfix = data.postfix != null ? data.postfix : "";
				animation.addByIndices(character, data.prefix, data.indices, postfix, frameRate, looped);
			}
			else
			{
				animation.addByPrefix(character, data.prefix, frameRate, looped);
			}
		}

		animation.play(character);
		
		var x = data.x != null ? data.x : 0;
		var y = data.y != null ? data.y : 0;
		var scale = data.scale != null ? data.scale : 1.0;
		var flipped = data.flipped != null ? data.flipped : false;

		offset.set(x, y);
		setGraphicSize(Std.int(width * scale));
		flipX = flipped != this.flipped;
	}
}
