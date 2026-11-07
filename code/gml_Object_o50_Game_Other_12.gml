if (subState == 0)
{
    // Start in-game BGM only if not already playing
    if (!ingameMusicPlaying)
    {
        scr50_IngameBGM(true);
        ingameMusicPlaying = true;
    }

    subState++;
    action = -4;
    actionIndex = -1;
    actionHighlight = 0;
    program = -4;
    dontGoToNextAction = false;
    aiTimer = 0;
    aiToX = -1;
    aiToY = -1;
    aiFromX = -1;
    aiFromY = -1;
    aiToXalt = -1;
    aiToYalt = -1;
    aiFromXalt = -1;
    aiFromYalt = -1;
    alternator = false;
    unitsBought = 0;
    miracleAttempts = 0;
    
    for (var i = 0; i < NUM_GODS; i++)
    {
        if (godAvail[i] < GOD_COOLDOWN)
            godAvail[i]++;
    }
    
    for (var i = 0; i < GRID_X_NUM; i++)
    {
        for (var j = 0; j < GRID_Y_NUM; j++)
        {
            if (map[i][j].revealed)
                map[i][j].revealed--;
            
            if (map[i][j].frozen)
                map[i][j].frozen--;
        }
    }
    
    god = scrIRandomRange(0, NUM_GODS - 1);
    var loopCounter = 0;
    
    do
    {
        god++;
        
        if (god >= NUM_GODS)
            god = 0;
        
        if (scr50_LoopIsStuck(loopCounter++, 14))
        {
            god = 0;
            break;
        }
    }
    until (godAvail[god] >= GOD_COOLDOWN);
    
    hudShiftX = -HUD_WIDTH;
}

if (subState == 1)
{
    stateTimer++;
    
    if ((stateTimer % 2) == 0)
        hudShiftX += 8;
    
    if (hudShiftX >= 0)
    {
        if (scr50_VictoryCheck())
            exit;
        
        futureState = STATE_GOD_SELECT;
    }
}
