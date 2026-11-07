function scr50_BattleBGM()
{
    // Build the track list once. Every name must exist in the game.
    if (!variable_global_exists("g50_battleTracks"))
    {
        global.g50_battleTracks = [bgm50_battle, bgm50_battle2, bgm50_battle3, bgm50_battle4];
        global.g50_battleCurrent = -1;
        global.g50_battleBag = [];
    }
    
    var count = array_length(global.g50_battleTracks);
    
    // Bag empty: put every track back in
    if (array_length(global.g50_battleBag) == 0)
    {
        for (var i = 0; i < count; i++)
            array_push(global.g50_battleBag, i);
    }
    
    var n = array_length(global.g50_battleBag);
    var slot = get_timer() mod n;
    
    // Never repeat the track that just played (matters at the refill boundary)
    if (n > 1 && global.g50_battleTracks[global.g50_battleBag[slot]] == global.g50_battleCurrent)
        slot = (slot + 1) mod n;
    
    var idx = global.g50_battleBag[slot];
    array_delete(global.g50_battleBag, slot, 1);
    global.g50_battleCurrent = global.g50_battleTracks[idx];
    scrBGM(global.g50_battleCurrent);
}