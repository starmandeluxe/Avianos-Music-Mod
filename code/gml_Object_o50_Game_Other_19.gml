if (subState == 0)
{
    scrBGM(bgm50_stingEnd, false);
    subState++;
    set_view(0, 0);
    
    with (o50__Unit)
        instance_destroy();
    
    with (o50_Building)
        instance_destroy();
    
    scrTransition(13, 32, 0, -10, true);
    
    if (action.type == MIRACLE)
        dontGoToNextAction = true;
    
    if (combatWinner == ATTACKER)
    {
        for (var i = 0; i < NUM_UNITS; i++)
            defendLoc.units[i] = attackers[i];
        
        defendLoc.owner = player;
        
        if (defendLoc.terrain == CASTLE || defendLoc.terrain == CASTLE_P1 || defendLoc.terrain == CASTLE_P2)
            defendLoc.terrain = player;
        
        for (var i = 0; i < NUM_UNITS; i++)
            attackLoc.units[i] += attackRunners[i];
        
        if (verify(retreatLoc))
        {
            for (var i = 0; i < NUM_UNITS; i++)
                retreatLoc.units[i] += defendRunners[i];
        }
        
        if (numPlayers == 1 || !fogOfWar || (actionIndex == 2 && action.type != MIRACLE))
            scr50_MessageSlow(scrString("attack_successful"));
        else
            scr50_MessageSlow(scrStringExt("look_away", !(player - 1) + 1, 42, 0));
    }
    
    if (combatWinner == DEFENDER)
    {
        for (var i = 0; i < NUM_UNITS; i++)
            defendLoc.units[i] = defenders[i];
        
        for (var i = 0; i < NUM_UNITS; i++)
            attackLoc.units[i] += attackRunners[i];
        
        for (var i = 0; i < NUM_UNITS; i++)
            defendLoc.units[i] += defendRunners[i];
        
        if (numPlayers == 1 || !fogOfWar || (actionIndex == 2 && action.type != MIRACLE))
            scr50_MessageSlow(scrString("attack_failed"));
        else
            scr50_MessageSlow(scrStringExt("look_away", !(player - 1) + 1, 42, 0));
    }
}

if (subState == 1)
{
    stateTimer++;
    
    if (numPlayers == 1 || !fogOfWar)
    {
        if (stateTimer >= 152)
        {
            muteBGM();
            ingameMusicPlaying = false;

            if (numPlayers == 2)
                controller = player;
            else if (numPlayers == 1 && player == 2)
                controller = 3;
            else if (numPlayers == 1 && player == 1)
                controller = 1;

            if (aiVersus)
                controller = 3;

            // Restart in-game music after combat
            scr50_IngameBGM(true);
            ingameMusicPlaying = true;

            futureState = STATE_ACTIONS;
            exit;
        }
    }
    else if (actionIndex != 2 || action.type == MIRACLE)
    {
        if (stateTimer >= 40 && fire2pressed)
        {
            if (numPlayers == 2)
                controller = player;
            else if (numPlayers == 1 && player == 2)
                controller = 3;
            else if (numPlayers == 1 && player == 1)
                controller = 1;

            if (aiVersus)
                controller = 3;

            // Restart in-game music after combat
            scr50_IngameBGM(true);
            ingameMusicPlaying = true;

            futureState = STATE_ACTIONS;
            exit;
        }
    }
    else if (stateTimer >= 152)
    {
        if (numPlayers == 2)
            controller = player;
        else if (numPlayers == 1 && player == 2)
            controller = 3;
        else if (numPlayers == 1 && player == 1)
            controller = 1;
        
        if (aiVersus)
            controller = 3;
        
        selectMode = 0;
        subChoice = false;
        subY = 0;
        
        for (var i = 0; i < GRID_X_NUM; i++)
        {
            for (j = 0; j < GRID_Y_NUM; j++)
                selectable[i][j] = false;
        }
        
        numSelectable = 0;
        mirX = 0;
        mirChoice = false;
        futureState = STATE_END_TURN;
        exit;
    }
}
