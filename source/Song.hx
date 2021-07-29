package;

import haxe.Exception;
import haxe.Unserializer;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

typedef SongData =
{
	var ?id:String;
	var ?song:String;
	var ?notes:Array<SwagSection>;
	var ?bpm:Float;
	var ?needsVoices:Bool;
	var ?speed:Float;

	var ?player1:String;
	var ?player2:String;
	var ?gfVersion:String;
	var ?noteStyle:String;
	var ?stage:String;
	var ?validScore:Bool;
}

class Song implements IFlxDestroyable
{
	public var id(default, null):Identifier;
	
	public var name:String = "Untitled";
	public var notes:Array<SwagSection> = [];
	public var bpm:Float = 150;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;

	public var player1:Identifier = new Identifier("basegame", "bf");
	public var player2:Identifier = new Identifier("basegame", "dad");
	public var gfVersion:Identifier = new Identifier("basegame", "gf");
	public var noteStyle:String = 'normal'; // TODO: Replace with Identifier.
	public var stage:Identifier = new Identifier("basegame", "stage");
	public var validScore:Bool = true; // TODO: Remove.
	
	public var script(default, null):Null<Script> = null;

	public function new(id:Identifier)
	{
		this.id = id;
	}

	public function load(difficulty:String):Song
	{
		var serializedData = Assets.getText(id.getAssetPath("songs", difficulty, "sol"));
		loadFromSerialized(serializedData, false);
		
		if (script == null || id != script.id)
		{
			EventTarget.unregister(script);
			script = EventTarget.register(new Script("songs", id), "song");
			script.run();
		}
		
		return this;
	}

	private function loadFromSerialized(serializedData:String, ?allowOverwritingId:Bool):Song
	{
		var data:SongData = cast Unserializer.run(serializedData).song;
		return loadFromData(data, allowOverwritingId);
	}
	
	public function loadFromData(data:SongData, allowOverwritingId:Bool = true):Song
	{
		if (allowOverwritingId && data.id != null) id = Identifier.parse(data.id);
		if (data.song != null) name = data.song;
		if (data.notes != null) notes = data.notes;
		if (data.bpm != null) bpm = data.bpm;
		if (data.needsVoices != null) needsVoices = data.needsVoices;
		if (data.speed != null) speed = data.speed;
		if (data.player1 != null) player1 = Identifier.parse(data.player1);
		if (data.player2 != null) player2 = Identifier.parse(data.player2);
		if (data.gfVersion != null) gfVersion = Identifier.parse(data.gfVersion);
		if (data.noteStyle != null) noteStyle = data.noteStyle;
		if (data.stage != null) stage = Identifier.parse(data.stage);
		return this;
	}
	
	public function destroy()
	{
		script = FlxDestroyUtil.destroy(script);
	}
}
