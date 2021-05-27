host.requestClass("StringTools");

var char = data.character;
var danced = char.storage.get("danced");

if (StringTools.startsWith(char.curCharacter, "gf"))
{
    if (!StringTools.startsWith(char.animation.curAnim.name, "hair"))
    {
        char.storage.set("danced", !danced);
        char.playAnim(danced ? "danceRight" : "danceLeft");
    }
}
else if (char.curCharacter == "spooky")
{
    char.storage.set("danced", !danced);
    char.playAnim(danced ? "danceRight" : "danceLeft");
}
else
{
    char.playAnim("idle");
}