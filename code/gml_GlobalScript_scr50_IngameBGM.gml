function scr50_IngameBGM(arg0)
{
    // arg0 = true: pick the next track. arg0 = false: replay the current one.
    if (!variable_global_exists("g50_ingameTracks"))
    {
        global.g50_ingameTracks = [bgm50_ingame1, bgm50_ingame2, bgm50_ingame3, bgm50_ingame4];
        global.g50_ingameCurrent = -1;
        global.g50_ingameBag = [];
    }
    
    var count = array_length(global.g50_ingameTracks);
    
    if (global.g50_ingameCurrent == -1)
    {
        // First play since launch: always ingame1, the others go in the bag
        global.g50_ingameCurrent = global.g50_ingameTracks[0];
        global.g50_ingameBag = [];
        
        for (var i = 1; i < count; i++)
            array_push(global.g50_ingameBag, i);
    }
    else if (arg0)
    {
        // Bag empty: put every track back in
        if (array_length(global.g50_ingameBag) == 0)
        {
            for (var i = 0; i < count; i++)
                array_push(global.g50_ingameBag, i);
        }
        
        var n = array_length(global.g50_ingameBag);
        var slot = get_timer() mod n;
        
        // Never repeat the track that just played
        if (n > 1 && global.g50_ingameTracks[global.g50_ingameBag[slot]] == global.g50_ingameCurrent)
            slot = (slot + 1) mod n;
        
        var idx = global.g50_ingameBag[slot];
        array_delete(global.g50_ingameBag, slot, 1);
        global.g50_ingameCurrent = global.g50_ingameTracks[idx];
    }
    
    scrBGM(global.g50_ingameCurrent, true);
}