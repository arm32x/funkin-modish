package;

import haxe.Exception;
import openfl.utils.Assets;
import haxe.Json;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

@:nullSafety(Strict)
typedef CharacterJSON = {
	var animations:Array<{
		var name:String;
		var prefix:String;
		var ?indices:Array<Int>;
		var ?postfix:String;
		var ?frameRate:Int;
		var ?looped:Bool;
		var ?condition:String;
		var offsets:Array<Float>;
	}>;
	var ?startingAnimation:{
		var name:String;
		var ?force:Bool;
		var ?reversed:Bool;
		var ?frame:Int;
		var ?playOnly:Bool;
	};
	var ?antialiasing:Bool;
	var ?flipX:Bool;
	var ?flipY:Bool;
	var ?size:Array<Null<{
		var operation:String;
		var value:Float;
	}>>;
	var ?graphicSize:Array<Null<{
		var operation:String;
		var value:Float;
	}>>;
};

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:Identifier;

	public var holdTimer:Float = 0;

	public function new(x:Float, y:Float, ?character:Identifier, ?isPlayer:Bool = false)
	{
		super(x, y);
		
		if (character == null) character = new Identifier("basegame", "bf");

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		antialiasing = true;

		var data = getCharacterJSON(character);
		
		trace('Loading character "$character" from JSON.');
		
		frames = getCharacterAtlas(character);
		
		if (data.animations != null)
		{
			for (anim in data.animations)
			{
				// Skip this animation if the condition is not met.
				switch (anim.condition)
				{
					case "player" if (!isPlayer):
						continue;
					case "not-player" if (isPlayer):
						continue;
				}
				
				var frameRate = anim.frameRate != null ? anim.frameRate : 30;
				var looped = anim.looped != null ? anim.looped : true;
				if (anim.indices != null)
				{
					var postfix = anim.postfix != null ? anim.postfix : "";
					animation.addByIndices(anim.name, anim.prefix, anim.indices, postfix, frameRate, looped);
				}
				else
				{
					animation.addByPrefix(anim.name, anim.prefix, frameRate, looped);
				}
				
				while (anim.offsets.length < 2)
				{
					anim.offsets.push(0);
				}
				addOffset(anim.name, anim.offsets[0], anim.offsets[1]);
			}
		}

		if (data.graphicSize != null)
		{
			var widthOp = data.graphicSize.length >= 1 ? data.graphicSize[0] : null;
			var graphicWidth = 0;
			if (widthOp != null)
			{
				graphicWidth = Std.int(applyOperation(width, widthOp));
			}

			var heightOp = data.graphicSize.length >= 2 ? data.graphicSize[1] : null;
			var graphicHeight = 0;
			if (heightOp != null)
			{
				graphicHeight = Std.int(applyOperation(height, heightOp));	
			}
			
			setGraphicSize(graphicWidth, graphicHeight);
			updateHitbox();
		}
		
		if (data.size != null)
		{
			var widthOp = data.size.length >= 1 ? data.size[0] : null;
			if (widthOp != null)
			{
				width = applyOperation(width, widthOp);
			}

			var heightOp = data.size.length >= 2 ? data.size[1] : null;
			if (heightOp != null)
			{
				height = applyOperation(height, heightOp);
			}
		}
		
		antialiasing = data.antialiasing != null ? data.antialiasing : true;
		flipX = data.flipX != null ? data.flipX : false;
		flipY = data.flipY != null ? data.flipY : false;
		
		if (data.startingAnimation != null)
		{
			var force = data.startingAnimation.force != null ? data.startingAnimation.force : false;
			var reversed = data.startingAnimation.reversed != null ? data.startingAnimation.reversed : false;
			var frame = data.startingAnimation.frame != null ? data.startingAnimation.frame : 0;
			var playOnly = data.startingAnimation.playOnly != null ? data.startingAnimation.playOnly : false;
			
			if (playOnly)
			{
				animation.play(data.startingAnimation.name, force, reversed, frame);
			}
			else
			{
				playAnim(data.startingAnimation.name, force, reversed, frame);
			}
		}

		dance();

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.path.startsWith('bf'))
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}

	override function update(elapsed:Float)
	{
		if (!curCharacter.path.startsWith('bf'))
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;

			if (curCharacter.path == 'dad')
				dadVar = 6.1;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				trace('dance');
				dance();
				holdTimer = 0;
			}
		}

		if (curCharacter == new Identifier("basegame", "gf") && animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
			playAnim('danceRight');

		super.update(elapsed);
	}

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode)
		{
			ScriptHost.runScripts("onCharacterDance", {character: this});
		}
	}

	public function playAnim(animName:String, force:Bool = false, reversed:Bool = false, frame:Int = 0):Void
	{
		animation.play(animName, force, reversed, frame);

		var daOffset = animOffsets.get(animName);
		if (animOffsets.exists(animName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		ScriptHost.runScripts("afterCharacterAnimationPlay", {character: this, animName: animName, force: force, reversed: reversed, frame: frame});
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
	
	private static function applyOperation(value:Float, operation:{operation:String, value:Float}) 
	{
		switch (operation.operation)
		{
			case "set":
				return operation.value;
			case "add":
				return value + operation.value;
			case "scale":
				return value * operation.value;
			default:
				throw new Exception('Invalid operation "${operation.operation}".');
		}
	}
	
	public static inline function getCharacterAtlas(character:Identifier):FlxAtlasFrames
	{
		var imagePath = character.getAssetPath("character", "png");
		var atlasPath:String;
		if (Assets.exists(atlasPath = character.getAssetPath("characters", "xml")))
		{
			return FlxAtlasFrames.fromSparrow(imagePath, atlasPath);
		}
		else if (Assets.exists(atlasPath = character.getAssetPath("characters", "txt")))
		{
			return FlxAtlasFrames.fromSpriteSheetPacker(imagePath, atlasPath);
		}
		else if (Assets.exists(atlasPath = character.getAssetPath("characters", "atlas")))
		{
			return FlxAtlasFrames.fromLibGdx(imagePath, atlasPath);
		}
		else
		{
			throw new Exception('Could not find texture atlas for "$character" - tried ".xml", ".txt", and ".atlas" formats.');
		}
	}
	
	public static inline function getCharacterJSON(character:Identifier):CharacterJSON
	{
		return Json.parse(Assets.getText(character.getAssetPath("characters", "json")));
	}

	// Storage for usage by scripts.
	@:keep
	public var storage: Map<String, Dynamic> = [];
}
