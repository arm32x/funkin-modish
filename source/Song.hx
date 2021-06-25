package;

import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

typedef SongJSON =
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

class Song
{
	public var id:Identifier;
	
	public var name:String = "Untitled";
	public var notes:Array<SwagSection> = [];
	public var bpm:Float = 150;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;

	public var player1:Identifier = new Identifier("basegame", "bf");
	public var player2:Identifier = new Identifier("basegame", "dad");
	public var gfVersion:Identifier = new Identifier("basegame", "gf");
	public var noteStyle:String = 'normal'; // TODO: Replace with Identifier.
	public var stage:String = 'stage'; // TODO: Replace with Identifier.

	public function new(id:Identifier)
	{
		this.id = id;
	}

	public function load(difficulty:String):Song
	{
		var jsonText = Assets.getText(id.getAssetPath("songs", difficulty, "json"));
		loadFromJSON(jsonText, false);
		return this;
	}

	public function loadFromJSON(jsonText:String, ?allowOverwritingId:Bool = true):Song
	{
		var data:SongJSON = cast Json.parse(jsonText).song;
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
		if (data.stage != null) stage = data.stage;
		return this;
	}
}
