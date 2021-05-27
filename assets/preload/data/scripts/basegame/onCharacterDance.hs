host.requestClass("StringTools");

var char = data.character;
var storageKey = char.curCharacter + "-danced";

if (StringTools.startsWith(char.curCharacter, "gf"))
{
    if (!StringTools.startsWith(char.animation.curAnim.name, "hair"))
    {
        host.storage.set(storageKey, !host.storage.get(storageKey));
        char.playAnim(host.storage.get(storageKey) ? "danceRight" : "danceLeft");
    }
}
else if (char.curCharacter == "spooky")
{
    host.storage.set(storageKey, !host.storage.get(storageKey));
    char.playAnim(host.storage.get(storageKey) ? "danceRight" : "danceLeft");
}
else
{
    char.playAnim("idle");
}