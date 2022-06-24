package funkin;

import flixel.input.keyboard.FlxKey;
import funkin.ChartConverter.BasegameChartImporter;
import haxe.Exception;
import haxe.xml.Access;
import lime.utils.Assets;

#if sys
import sys.FileSystem;
#end

class ModLoader
{
    // The mod API is not stable yet, so this number will stay at 0 for a while.
    // Once the API is deemed stable, this number will increment to 1 and will
    // continue to increment with each breaking change.
    // TODO: Replace this integer version number with a SemVer range in the
    //       dependencies section of modish.xml (once that exists).
    inline private static final CURRENT_FORMAT:Int = 0;
    
    public static function load(id:String, sparse:Bool = false, preloadAssets:Bool = false, ?progressFunction:(Int, Int)->Void)
    {
        trace('Loading mod "$id"...');
        
        if (!Identifier.isValidPart(id))
        {
            throw new Exception('Invalid mod ID "$id".');
        }
        if (Assets.hasLibrary(id))
        {
            throw new Exception('Mod "$id" already loaded!');
        }

        #if sys
        if (FileSystem.exists('./mods/$id') && FileSystem.isDirectory('./mods/$id'))
        {
            var library = new DirectoryAssetLibrary('./mods/$id');
            Assets.registerLibrary(id, library);
        }
        else if (FileSystem.exists('./mods/$id.zip') && !FileSystem.isDirectory('./mods/$id.zip'))
        {
            throw new Exception("Not yet implemented.");
        }
        else #end if (Assets.exists('default:mods/$id/modish.xml'))
        {
            var library = new ProxyAssetLibrary(Assets.getLibrary("default"), 'mods/$id/');
            Assets.registerLibrary(id, library);
        }
        else
        {
            throw new Exception('Mod "$id" not found.');
        }
        
        var xml = new Access(Xml.parse(Assets.getText('$id:modish.xml')).firstElement());

        if (xml.att.id != id)
        {
            throw new Exception('Mod "${xml.att.id}" was loaded with incorrect ID "$id". Try renaming the mod folder or ZIP to "${xml.att.id}".');
        }

        var format = Std.parseInt(xml.att.format);
        if (format < CURRENT_FORMAT)
        {
            throw new Exception('Outdated mod: "$id" uses mod format $format, current version is $CURRENT_FORMAT.');
        }
        else if (format > CURRENT_FORMAT)
        {
            throw new Exception('Mod too new: "$id" uses mod format $format, current version is $CURRENT_FORMAT.');
        }
        
        Registry.mods.push({
            id: id,
            name: xml.node.name.innerData,
            version: xml.hasNode.version ? xml.node.version.innerData : null,
            description: xml.hasNode.description ? xml.node.description.innerData : null
        });
        
        if (!sparse && xml.hasNode.exports)
        {
            var totalExports = 0;
            if (progressFunction != null)
            {
                for (export in xml.node.exports.elements)
                {
                    totalExports++;
                }
            }
            
            var exportsProcessed = 0;
            for (export in xml.node.exports.elements)
            {
                if (progressFunction != null)
                {
                    progressFunction(exportsProcessed, totalExports);
                    exportsProcessed++;
                }
                
                switch (export.name)
                {
                    case "character":
                        var id = Identifier.parse(export.att.id);
                        Registry.characters.register(id, {
                            icon: export.has.icon ? Identifier.parse(export.att.icon) : id
                        });
                    case "introText":
                        Registry.introTexts.push([export.att.top, export.att.bottom]);
                    case "healthIcon":
                        Registry.healthIcons.register(Identifier.parse(export.att.id), {
                            antialiasing: export.has.antialiasing ? (export.att.antialiasing.toLowerCase() == "true") : true
                        });
                    case "keybinding":
                        Registry.keybindings.register(Identifier.parse(export.att.id), {
                            name: export.att.name,
                            // TODO: Throw an error if an invalid key name is
                            //       specified instead of using FlxKey.NONE.
                            defaults: export.att.defaults
                                .split(" ")
                                .filter(keyStr -> keyStr != "")
                                .map(FlxKey.fromString)
                        });
                    case "menuCharacter":
                        Registry.menuCharacters.register(Identifier.parse(export.att.id), {});
                    case "noteType":
                        Registry.noteTypes.register(Identifier.parse(export.att.id), {
                            animationSuffix: export.has.animationSuffix ? export.att.animationSuffix : null
                        });
                    case "song":
                        Registry.songs.register(Identifier.parse(export.att.id), {
                            name: export.att.name,
                            icon: Identifier.parse(export.att.icon),
                            week: export.has.week ? Identifier.parse(export.att.week) : null,
                            hasVocals: export.has.hasVocals ? export.att.hasVocals.toLowerCase() == "true" : true
                        });
                    case "stage":
                        Registry.stages.register(Identifier.parse(export.att.id), {});
                    case "week":
                        Registry.weeks.register(Identifier.parse(export.att.id), {
                            name: export.att.name,
                            leftCharacter: export.has.left ? Identifier.parse(export.att.left) : null,
                            middleCharacter: export.has.middle ? Identifier.parse(export.att.middle) : null,
                            rightCharacter: export.has.right ? Identifier.parse(export.att.right) : null,
                            playlist: export.nodes.song
                                .map(node -> Identifier.parse(node.att.id)),
                            locked: export.has.locked ? (export.att.locked.toLowerCase() == "true") : false
                        });
                    default:
                        throw new Exception('Invalid export type "${export.name}" in mod "$id".');
                }
                
                if (preloadAssets)
                {
                    var id = export.has.id ? Identifier.parse(export.att.id) : null;
                    // The Assets class has an internal cache.
                    switch (export.name)
                    {
                        case "character":
                            Assets.getImage(id.getAssetPath("characters", null, "png"));
                        case "healthIcon":
                            Assets.getImage(id.getAssetPath("health-icons", null, "png"));
                        case "menuCharacter":
                            Assets.getImage(id.getAssetPath("menu-characters", null, "png"));
                        case "song":
                            Assets.getAudioBuffer(id.getAssetPath("songs", "instrumental", Paths.SOUND_EXT));
                            if (Registry.songs.get(id).hasVocals)
                                Assets.getAudioBuffer(id.getAssetPath("songs", "vocals", Paths.SOUND_EXT));
                            // #if sys
                            // var library = Assets.getLibrary(id.namespace);
                            // var converter = new BasegameChartImporter();
                            // for (difficulty in ["easy", "normal", "hard"])
                            // {
                            //     var originalPath = id.getAssetPath("songs", difficulty, "json");
                            //     if (Assets.exists(originalPath))
                            //     {
                            //         var original = haxe.Json.parse(Assets.getText(originalPath));
                            //         var converted = converter.convert(original.song, difficulty);
                                    
                            //         var infoPath = library.getPath('songs/${id.path}/${id.path}.json');
                            //         var chartPath = library.getPath('songs/${id.path}/$difficulty.sol');
    
                            //         sys.io.File.saveContent(infoPath, converted.info.toJSON());
                            //         sys.io.File.saveContent(chartPath, haxe.Serializer.run(converted.chart));
                            //     }
                            // }
                            // #end
                        case "week":
                            Assets.getImage(id.getAssetPath("weeks", null, "png"));
                    }
                }
            }
        }
        else if (progressFunction != null)
        {
            progressFunction(0, 0);
        }
    }
}
