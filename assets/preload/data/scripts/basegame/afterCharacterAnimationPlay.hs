var char = data.character;
var storageKey = char.curCharacter + "-danced";

if (char.curCharacter == "gf")
{
    if (data.animName == "singLEFT")
    {
        host.storage.set(storageKey, true);
    }
    else if (data.animName == "singRIGHT")
    {
        host.storage.set(storageKey, false);
    }
    else if (data.animName == "singUP" || data.animName == "singDOWN")
    {
        host.storage.set(storageKey, !host.storage.get(storageKey));
    }
}