package funkin;

import funkin.util.AnimationSet;
import funkin.util.AnimationSet.AnimationSetJson;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;
import funkin.song.Conductor;
import haxe.Exception;
import haxe.Json;
import openfl.utils.Assets;

using StringTools;

@:nullSafety(Strict)
typedef CharacterJSON = {
	> AnimationSetJson,
	var version:Int;
	var ?animationMode:String;
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
	var ?replacesGF:Bool;
	var ?positionOffset:Array<Float>;
	var ?cameraOffset:Array<Float>;
};

enum AnimationMode
{
	Idle;
	Dance;
}

enum Position
{
	Player;
	Girlfriend;
	Opponent;
}

class Character extends FlxSprite
{
	static final CURRENT_FORMAT:Int = 3;
	static final MIN_SUPPORTED_FORMAT:Int = 2;

	public var debugMode:Bool = false;

	public var curPosition:Position;
	public var curCharacter:Identifier;

	public var isPlayer(get, never):Bool;

	public var holdTimer:Float = 0;

	public var replacesGF:Bool = false;

	public var positionOffset:FlxPoint = FlxPoint.get();
	public var cameraOffset:FlxPoint = FlxPoint.get();

	public var script:Script;

	var animationMode:AnimationMode = Idle;

	public function new(x:Float, y:Float, character:Identifier, position:Position, runScripts:Bool = false)
	{
		super(x, y);

		curCharacter = character;
		curPosition = position;

		antialiasing = true;

		debugBoundingBoxColor = 0xFFFABD2F;

		var data = getCharacterJSON(character);
		if (data.version > CURRENT_FORMAT)
		{
			throw new Exception('Error loading character "$character": Unsupported format ${data.version}, current version is $CURRENT_FORMAT.');
		}
		else if (data.version < MIN_SUPPORTED_FORMAT)
		{
			throw new Exception('Error loading character "$character": Outdated format ${data.version}, minimum supported version is $MIN_SUPPORTED_FORMAT.');
		}

		trace('Loading character "$character" from JSON.');

		frames = HelperFunctions.getAtlas(character, "characters", null);

		if (data.animations != null)
			animation = AnimationSet.fromJson(this, data);

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

		if (data.animationMode != null)
		{
			switch (data.animationMode)
			{
				case "idle":
					animationMode = Idle;
				case "dance":
					animationMode = Dance;
			}
		}

		if (data.replacesGF != null)
		{
			replacesGF = data.replacesGF;
		}

		if (data.positionOffset != null)
		{
			while (data.positionOffset.length < 2)
			{
				data.positionOffset.push(0);
			}
			positionOffset.set(data.positionOffset[0], data.positionOffset[1]);
		}
		if (data.cameraOffset != null)
		{
			while (data.cameraOffset.length < 2)
			{
				data.cameraOffset.push(0);
			}
			cameraOffset.set(data.cameraOffset[0], data.cameraOffset[1]);
		}

		dance();

		// TODO: Figure out what this does and remove it.
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

		if (runScripts)
		{
			script = EventTarget.register(new Script("characters", curCharacter), switch(curPosition)
			{
				case Player: "player";
				case Girlfriend: "girlfriend";
				case Opponent: "opponent";
			});
			script.run([
				"sprite" => this,
				"playAnim" => this.playAnim
			]);
		}
	}

	public function applyOffset()
	{
		x += positionOffset.x;
		y += positionOffset.y;
	}

	public function getCameraPosition(?point:FlxPoint):FlxPoint
	{
		return getMidpoint(point).addPoint(cameraOffset);
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

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance(?force:Bool, ?reversed:Bool, ?frame:Int)
	{
		if (!debugMode)
		{
			switch (animationMode)
			{
				case Idle:
					playAnim('idle', force, reversed, frame);
				case Dance:
					if (!animation.curAnim.name.startsWith('hair') || animation.curAnim.name == "hairFall" && animation.curAnim.finished)
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}
			}
		}
	}

	public function playAnim(animName:String, force:Bool = false, reversed:Bool = false, frame:Int = 0, ?forcedPriority:Int):Void
	{
		animation.play(animName, force, reversed, frame);

		if (animationMode == Dance)
		{
			if (animName == 'singLEFT')
			{
				danced = true;
			}
			else if (animName == 'singRIGHT')
			{
				danced = false;
			}

			if (animName == 'singUP' || animName == 'singDOWN')
			{
				danced = !danced;
			}
		}
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

	public static inline function getCharacterJSON(character:Identifier):CharacterJSON
	{
		return Json.parse(Assets.getText(character.getAssetPath("characters", null, "json")));
	}

	override public function destroy()
	{
		script = FlxDestroyUtil.destroy(script);
	}

	function get_isPlayer():Bool {
		return curPosition == Player;
	}
}
