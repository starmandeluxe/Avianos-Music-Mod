if (subState == 0)
{
    scrBGM(bgm50_stingWin, false);
    subState++;
    controller = 1;
    wonCampaign = false;
    
    if (winner == 1)
        loser = 2;
    else
        loser = 1;
    
    scrMessageSet("");
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
    recruitChioce = false;
    
    if (numPlayers == 1)
    {
        if (winner == 1)
        {
            if (scenarioY != 2)
                endMsg = scrStringExt("you_won", "*", 22, 4);
            else
                endMsg = scrStringExt("you_won_campaign", "*", 22, 4);
            
            if (winStyle == 1)
            {
                if (NUM_CONTROL_POINTS == 0)
                    endSubMsg = scrStringExt("conquered", CASTLES_TO_WIN, 40, 0);
                else
                    endSubMsg = scrStringExt("conquered_alt", CASTLES_TO_WIN, 40, 0);
            }
            else if (NUM_CONTROL_POINTS == 0)
            {
                endSubMsg = scrString("enemy_lost_all");
            }
            else
            {
                endSubMsg = scrString("enemy_lost_all_alt");
            }
            
            if (!custom)
            {
                scenarioWins[scenarioY] = true;
                
                if (scenarioY == 2)
                {
                    scrWin(1);
                    wonCampaign = true;
                }
                
                if (scenarioY == (NUM_SCENARIOS - 1))
                    scrWin(2);
                
                scrSaveGame(0);
            }
        }
        else
        {
            endMsg = scrStringExt("you_lost", "*", 22, 4);
            
            if (winStyle == 1)
            {
                if (NUM_CONTROL_POINTS == 0)
                    endSubMsg = scrStringExt("enemy_conquered", CASTLES_TO_WIN, 40, 0);
                else
                    endSubMsg = scrStringExt("enemy_conquered_alt", CASTLES_TO_WIN, 40, 0);
            }
            else if (NUM_CONTROL_POINTS == 0)
            {
                endSubMsg = scrStringExt("lost_all", "*", 40, 0);
            }
            else
            {
                endSubMsg = scrStringExt("lost_all_alt", "*", 40, 0);
            }
            
            scrSaveGame(0);
        }
    }
    else if (numPlayers == 2)
    {
        endMsg = scrStringExt("player_won", winner, 22, 4);
        
        if (winStyle == 1)
        {
            if (NUM_CONTROL_POINTS == 0)
                endSubMsg = scrStringExt("conquered", CASTLES_TO_WIN, 40, 0);
            else
                endSubMsg = scrStringExt("conquered_alt", CASTLES_TO_WIN, 40, 0);
        }
        else if (NUM_CONTROL_POINTS == 0)
        {
            endSubMsg = scrStringExt("player_lost_all", loser, 40, 0);
        }
        else
        {
            endSubMsg = scrStringExt("player_lost_all_alt", loser, 40, 0);
        }
    }
}

if (subState == 1)
{
    if (fire2pressed || aiVersus)
    {
        muteBGM();
        ingameMusicPlaying = false;
        subState = 2;
    }
}

if (subState == 2)
{
    if (stateTimer++ >= 30)
    {
        if (custom)
            futureState = STATE_CUSTOM;
        else if (wonCampaign)
            futureState = STATE_ENDING;
        else if (numPlayers == 1)
            futureState = STATE_SCENARIO_SELECT;
        else
            scrExitToTitleScreen();
    }
}
