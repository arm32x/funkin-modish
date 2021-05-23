host.requestClass("StringTools");

var char = data.character;

if (StringTools.startsWith(char.curCharacter, "gf"))
{
    if (!StringTools.startsWith(char.animation.curAnim.name, "hair"))
    {
        char.danced = !char.danced;
        char.playAnim(char.danced ? "danceRight" : "danceLeft");
    }
}
else if (char.curCharacter == "spooky")
{
    char.danced = !char.danced;
    char.playAnim(char.danced ? "danceRight" : "danceLeft");
}
else
{
    char.playAnim("idle");
}