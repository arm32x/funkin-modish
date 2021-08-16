package;

@:deprecated("SwagSection is deprecated in favor of Section")
typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var lengthInSteps:Int;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
}

typedef Section =
{
	var notes:Array<{
		var strumTime:Float;
		var column:Int;
		var sustainLength:Float;
		var type:Identifier;
		var ?data:Dynamic;
	}>;
	// var lengthInSteps:Int; // Every section is 16 steps.
	var ?cameraFocus:Character.Position;
	var ?bpm:Float;
	// var ?scrollSpeed:Float; // TODO: Add support for changing scroll speed.
}
