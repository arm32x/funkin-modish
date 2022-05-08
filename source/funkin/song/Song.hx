package funkin.song;

import funkin.song.NoteTrack;
import funkin.song.Conductor.BPMChange;
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
    public var meta:Null<SongMetadata>;

    public var characters:Map<String, Identifier> = [];
    public var stage:Null<Identifier> = null;

    public var bpmChanges:Array<BPMChange> = [{time: 0, bpm: 160}];
    public var offset:Float = 0.0;
    public var scrollSpeed:Float = 1.0;
    public var tracks:Array<NoteTrack> = [];

    // TODO: Remove these.
    public var info(default, null):Null<SongInfo> = null;
    public var chart(default, null):Null<SongChart> = null;

    public var script(default, null):Null<Script> = null;

    public function new(id:Identifier)
    {
        this.id = id;
        this.meta = Registry.songs.get(id);
    }

    public function load(difficulty:String, runScripts:Bool = false):Song
    {
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
        info = SongInfo.fromJSON(Assets.getText(id.getAssetPath("songs", null, "json")));
        chart = unserializer.unserialize();

        // This chart conversion is very temporary. Eventually songs will be
        // loaded from the new format (see song-schema.json).

        // TODO: Support changing the UI style.
        characters = [
            "player" => info.player,
            "girlfriend" => info.girlfriend,
            "opponent" => info.opponent
        ];
        stage = info.stage;

        scrollSpeed = chart.scrollSpeed;

        for (index in 0...8)
        {
            var track = new NoteTrack();
            track.targetCharacter = index < 4 ? "player" : "opponent";
            track.variant = ["left", "down", "up", "right"][index % 4];
            tracks.push(track);
        }

        bpmChanges = [{bpm: chart.bpm, time: 0}];

        var currentBPM:Float = chart.bpm;
        var currentTime:Float = 0;
        var currentPosition:Float = 0;

        // TODO: Support changing the camera focus (probably with an event).
        for (section in chart.sections)
        {
            if (section.bpm != null && section.bpm != currentBPM)
            {
                currentBPM = section.bpm;
                var change:BPMChange = {
                    time: currentTime,
                    bpm: currentBPM
                };
                bpmChanges.push(change);
            }

            for (note in section.notes)
            {
                var track = tracks[note.column];
                track.notes.push({
                    time: currentTime + Conductor.millisecondsToBeats(currentBPM, note.strumTime - currentPosition),
                    sustainLength: Conductor.millisecondsToBeats(currentBPM, note.sustainLength)
                });
            }

            var deltaTime:Float = 4;
            currentTime += deltaTime;
            currentPosition += (60 / currentBPM) * 1000 * deltaTime;
        }

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
