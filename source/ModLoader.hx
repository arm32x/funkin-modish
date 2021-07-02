package;

import haxe.ds.HashMap;
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
    inline private static final CURRENT_FORMAT:Int = 0;
    
    public static function load(id:String, sparse:Bool = false)
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
        else
        {
            throw new Exception('Mod "$id" not found.');
        }
        #else
        throw new Exception("Mod loading is not implemented on non-sys targets.");
        #end
        
        var xml = new Access(Xml.parse(Assets.getText('$id:modish.xml')).firstElement());

        if (xml.att.id != id)
        {
            throw new Exception('Mod "${xml.att.id}" was loaded with incorrect ID "$id". Try renaming the mod folder or ZIP to "${xml.att.id}".');
        }
        var name = xml.node.name.innerData;
        var description = xml.hasNode.description ? xml.node.description.innerData : null;

        var format = Std.parseInt(xml.att.format);
        if (format < CURRENT_FORMAT)
        {
            throw new Exception('Outdated mod: "$id" uses mod format $format, current version is $CURRENT_FORMAT.');
        }
        else if (format > CURRENT_FORMAT)
        {
            throw new Exception('Mod too new: "$id" uses mod format $format, current version is $CURRENT_FORMAT.');
        }
        
        Registry.mods.push({id: id, name: name, description: description});
        
        if (!sparse && xml.hasNode.exports)
        {
            for (export in xml.node.exports.elements)
            {
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
                    case "menuCharacter":
                        Registry.menuCharacters.register(Identifier.parse(export.att.id), {});
                    case "song":
                        Registry.songs.register(Identifier.parse(export.att.id), {
                            name: export.att.name,
                            icon: Identifier.parse(export.att.icon),
                            week: export.has.week ? Identifier.parse(export.att.week) : null
                        });
                    case "week":
                        Registry.weeks.register(Identifier.parse(export.att.id), {
                            name: export.att.name,
                            leftCharacter: export.has.left ? Identifier.parse(export.att.left) : null,
                            middleCharacter: export.has.middle ? Identifier.parse(export.att.middle) : null,
                            rightCharacter: export.has.right ? Identifier.parse(export.att.right) : null,
                            playlist: export.nodes.song
                                .map(function(node) return Identifier.parse(node.att.id)),
                            locked: export.has.locked ? (export.att.locked.toLowerCase() == "true") : false
                        });
                    default:
                        throw new Exception('Invalid export type "${export.name}" in mod "$id".');
                }
            }
        }
    }
}
