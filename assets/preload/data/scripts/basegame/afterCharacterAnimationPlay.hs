var char = data.character;

if (char.curCharacter == "gf")
{
    if (data.animName == "singLEFT")
    {
        char.danced = true;
    }
    else if (data.animName == "singRIGHT")
    {
        char.danced = false;
    }
    else if (data.animName == "singUP" || data.animName == "singDOWN")
    {
        char.danced = !char.danced;
    }
}