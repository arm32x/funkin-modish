package funkin;

import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import funkin.Character.Position;
import funkin.Registry.SongMetadata;
import haxe.Json;
import haxe.Unserializer;
import lime.utils.Assets;

using StringTools;

class SongInfo
{
	public var player:Identifier;
	public var opponent:Identifier;
	public var girlfriend:Identifier;
	public var uiStyle:Identifier;
	public var stage:Identifier;
	
	public function new(player:Identifier, opponent:Identifier, girlfriend:Identifier, ?uiStyle:Identifier, stage:Identifier)
	{
		this.player = player;
		this.opponent = opponent;
		this.girlfriend = girlfriend;
		this.uiStyle = uiStyle != null ? uiStyle : new Identifier("basegame", "normal");
		this.stage = stage;
	}
	
	public static function fromJSON(json:String):SongInfo
	{
		var data:{
			var player:String;
			var opponent:String;
			var girlfriend:String;
			var ?uiStyle:String;
			var stage:String;
		} = Json.parse(json);
		return new SongInfo(
			Identifier.parse(data.player),
			Identifier.parse(data.opponent),
			Identifier.parse(data.girlfriend),
			data.uiStyle != null ? Identifier.parse(data.uiStyle) : null,
			Identifier.parse(data.stage)
		);
	}
	
	public function toJSON():String
	{
		return Json.stringify({
			"player": player.toString(),
			"opponent": opponent.toString(),
			"girlfriend": girlfriend.toString(),
			"uiStyle": uiStyle.toString(),
			"stage": stage.toString()
		}, null, "    ");
	}
}

typedef SongChart =
{
	var sections:Array<Section>;
	var bpm:Float;
	var scrollSpeed:Float;
}

class Song implements IFlxDestroyable
{
	public final id:Identifier;
	public var difficulty(default, null):Null<String> = null;
	
	public final meta:Null<SongMetadata>;
	public final info:SongInfo;
	public var chart(default, null):Null<SongChart> = null;
	
	public var script(default, null):Null<Script> = null;

	public function new(id:Identifier)
	{
		this.id = id;
		this.meta = Registry.songs.get(id);
		this.info = SongInfo.fromJSON(Assets.getText(id.getAssetPath("songs", null, "json")));
	}

	public function load(difficulty:String, runScripts:Bool = false):Song
	{
		this.difficulty = difficulty;
		
		var unserializer = new Unserializer(Assets.getText(id.getAssetPath("songs", difficulty, "sol")));
		unserializer.setResolver({
			resolveClass: function resolveClass(name:String):Null<Class<Dynamic>>
			{
				switch (name)
				{
					case "Identifier" | "funkin.Identifier":
						return Identifier;
					default:
						return null;
				}	
			},
			resolveEnum: function resolveEnum(name:String):Null<Enum<Dynamic>>
			{
				switch (name)
				{
					case "Position" | "Character.Position" | "funkin.Character.Position" | "funkin.Position":
						return Position;
					default:
						return null;
				}	
			}
		});
		chart = unserializer.unserialize();
		
		script = FlxDestroyUtil.destroy(script);
		if (runScripts)
		{
			script = EventTarget.register(new Script("songs", id), "song");
			script.run();
		}
		
		return this;
	}

	public function destroy()
	{
		script = FlxDestroyUtil.destroy(script);
	}
}
