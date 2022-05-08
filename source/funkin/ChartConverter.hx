package funkin;

import funkin.Character.Position;
import funkin.song.Song.SongChart;
import funkin.song.Song.SongInfo;

interface ChartConverter<I, O>
{
    public function convert(data:I, difficulty:String):O;
}

typedef ChartImporter<I> = ChartConverter<I, {info:SongInfo, chart:SongChart}>;
typedef ChartExporter<O> = ChartConverter<{info:SongInfo, chart:SongChart}, O>;

typedef BasegameSong =
{
    var song:String;
	var notes:Array<{
        var sectionNotes:Array<Array<Dynamic>>;
        var lengthInSteps:Int;
        var typeOfSection:Int;
        var mustHitSection:Bool;
        var bpm:Float;
        var changeBPM:Bool;
        var altAnim:Bool;
    }>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var noteStyle:String;
	var stage:String;
	var validScore:Bool;
}

class BasegameChartImporter implements ChartImporter<BasegameSong>
{
    public function new() {}

    public function convert(data:BasegameSong, difficulty:String):{info:SongInfo, chart:SongChart}
    {
        return {
            info: new SongInfo(
                new Identifier("basegame", data.player1 != null ? data.player1 : "bf"),
                new Identifier("basegame", data.player2 != null ? data.player2 : "dad"),
                new Identifier("basegame", data.gfVersion != null ? data.gfVersion : "gf"),
                new Identifier("basegame", data.noteStyle != null ? data.noteStyle : "normal"),
                new Identifier("basegame", data.stage != null ? data.stage : "stage")
            ),
            chart: {
                sections: data.notes.map(section -> {
                    notes: section.sectionNotes.map(note -> {
                        strumTime: cast note[0],
                        column: Std.int(
                            if (section.mustHitSection)
                                note[1]
                            else if (note[1] < 4)
                                note[1] + 4
                            else if (note[1] >= 4)
                                note[1] - 4
                            else
                                note[1] // Used by some mods.
                        ),
                        sustainLength: cast note[2],
                        type: (
                            if (section.altAnim)
                                new Identifier("basegame", "alt")
                            else
                                new Identifier("core", "normal")
                        ),
                        data: null
                    }),
                    cameraFocus: section.mustHitSection ? Player : Opponent,
                    bpm: section.changeBPM ? section.bpm : null
                }),
                bpm: data.bpm,
                scrollSpeed: data.speed
            }
        }
    }
}
