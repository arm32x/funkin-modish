var char = data.character;
var danced = char.storage.get("danced");

if (char.curCharacter == "gf")
{
    if (data.animName == "singLEFT")
    {
        char.storage.set("danced", true);
    }
    else if (data.animName == "singRIGHT")
    {
        char.storage.set("danced", false);
    }
    else if (data.animName == "singUP" || data.animName == "singDOWN")
    {
        char.storage.set("danced", !danced);
    }
}