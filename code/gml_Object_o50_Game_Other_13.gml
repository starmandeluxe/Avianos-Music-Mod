if (subState == 0)
{
    subState = 1;
    scr50_MessageFastLocal("which_god");
    
    with (o50_Move)
        instance_destroy();
    
    ds_list_clear(potMoves);
    metaStep = 1;
    metaCount = 0;
}

if (subState == 1)
{
    if (pressLeft && (metaStep % 2) == 1)
    {
        metaCount++;
        
        if (metaCount == metaStep)
        {
            metaCount = 0;
            metaStep++;
            
            if (metaStep == 4)
                scr50_MessageSlow(scrStringManual("game_meta_message_50", 0));
        }
    }
    else if (pressRight && (metaStep % 2) == 0)
    {
        metaCount++;
        
        if (metaCount == metaStep)
        {
            metaCount = 0;
            metaStep++;
        }
    }
    else if (pressLeft || pressRight)
    {
        metaStep = 1;
        metaCount = 0;
    }
    
    if (pressLeft)
    {
        scr50_Sfx(soundGodNavi, 20);
        scr50_HoldFlicker();
        god--;
        
        if (god < 0)
            god = 4;
        
        var loopCounter = 0;
        
        while (godAvail[god] < GOD_COOLDOWN)
        {
            god--;
            
            if (god < 0)
                god = 4;
            
            if (scr50_LoopIsStuck(loopCounter++, 15))
            {
                god = 0;
                break;
            }
        }
    }
    
    if (pressRight)
    {
        scr50_Sfx(soundGodNavi, 20);
        scr50_HoldFlicker();
        god++;
        
        if (god > 4)
            god = 0;
        
        var loopCounter = 0;
        
        while (godAvail[god] < GOD_COOLDOWN)
        {
            god++;
            
            if (god > 4)
                god = 0;
            
            if (scr50_LoopIsStuck(loopCounter++, 16))
            {
                god = 0;
                break;
            }
        }
    }
    
    if (fire2pressed)
    {
        mute(soundPlayerTransition);
        scrSfx(soundGodSelect, 30);
        scr50_MessageFast("");
        
        if (controller == 3)
            scrMessageSet(scrStringVal("enemy_prays", GOD_NAMES[god]));
        
        godPowerFlicker = 0;
        godPower[player][god]++;
        
        if (godPower[player][god] > GOD_MAX_POWER)
            godPower[player][god] = GOD_MAX_POWER;
        else
            godPowerFlicker = 48;
        
        if (controller != 3 && !SCRAMBLED_ACTIONS)
            godPicks[god]++;
        
        subState = 2;
    }
}

if (subState == 2)
{
    stateTimer++;
    
    if (stateTimer >= 80)
    {
        mute(soundGodSelect);
        
        if (floor(godPower[player][god] / POWER_PER_UPGRADE) > godUpgrades[player][god])
        {
            scr50_Sfx(soundGodUnlockUpgrade, 60);
            stateTimer = 0;
            subState = 3;
            godUpgrades[player][god]++;
            scr50_MessageSlow(scrStringExt("upgrade_unlocked", "*", 35, 0));
        }
        else
        {
            futureState = STATE_ACTIONS;
        }
    }
}

if (subState == 3)
{
    stateTimer++;
    
    if (controller == 3)
        stateTimer = 120;
    
    if (stateTimer >= 120)
    {
        if (controller != 3)
            scrBGM(bgm50_bless);
        
        stateTimer = 0;
        subState = 4;
        upgradeIndex = -1;
        var loopCounter = 0;
        var selectedAction;
        
        do
        {
            upgradeIndex++;
            
            if (upgradeIndex > (NUM_ACTIONS_PER_GOD - 1))
                upgradeIndex = 0;
            
            var prog = godPrograms[player][god];
            selectedAction = prog.actions[upgradeIndex];
            
            if (scr50_LoopIsStuck(loopCounter++, 17))
            {
                futureState = STATE_ACTIONS;
                exit;
            }
        }
        until (selectedAction.level <= 1);
        
        selectedAction.level++;
        scr50_LoadAction(player, god, upgradeIndex, selectedAction.level);
        flicker20 = false;
        scr50_MessageSlow(scrString("which_upgrade"));
    }
}

if (subState == 4)
{
    var prog = godPrograms[player][god];
    var selectedAction = prog.actions[upgradeIndex];
    
    if (pressUp)
    {
        scr50_Sfx(soundMiracleNavi, 20);
        selectedAction.level--;
        scr50_LoadAction(player, god, upgradeIndex, selectedAction.level);
        var loopCounter = 0;
        
        do
        {
            upgradeIndex--;
            
            if (upgradeIndex < 0)
                upgradeIndex = NUM_ACTIONS_PER_GOD - 1;
            
            prog = godPrograms[player][god];
            selectedAction = prog.actions[upgradeIndex];
            
            if (scr50_LoopIsStuck(loopCounter++, 18))
                break;
        }
        until (selectedAction.level <= 1);
        
        selectedAction.level++;
        scr50_LoadAction(player, god, upgradeIndex, selectedAction.level);
    }
    
    if (pressDown)
    {
        scr50_Sfx(soundMiracleNavi, 20);
        selectedAction.level--;
        scr50_LoadAction(player, god, upgradeIndex, selectedAction.level);
        var loopCounter = 0;
        
        do
        {
            upgradeIndex++;
            
            if (upgradeIndex > (NUM_ACTIONS_PER_GOD - 1))
                upgradeIndex = 0;
            
            prog = godPrograms[player][god];
            selectedAction = prog.actions[upgradeIndex];
            
            if (scr50_LoopIsStuck(loopCounter++, 19))
                break;
        }
        until (selectedAction.level <= 1);
        
        selectedAction.level++;
        scr50_LoadAction(player, god, upgradeIndex, selectedAction.level);
    }
    
    if (fire2pressed)
    {
        // if (controller != 3)
        // {
        //     muteBGM();
        //     ingameMusicPlaying = false;
        // }

        scr50_Sfx(soundMiracle, 50);
        scr50_MessageSlow(scrStringExt("action_upgraded", "*", 35, 0));
        subState = 5;
    }
}

if (subState == 5)
{
    stateTimer++;
    
    if ((stateTimer % 4) == 0 && stateTimer <= 80 && controller != 3)
    {
        repeat (4)
        {
            var xPos = scrIRandomRange(HUD_LEFT, (HUD_LEFT + HUD_WIDTH) - 8);
            var yPos = scrIRandomRange(ACTION_TOP + (ACTION_HEIGHT * upgradeIndex), (ACTION_TOP + (ACTION_HEIGHT * upgradeIndex) + ACTION_HEIGHT) - 8);
            scrFX(s50_StarFXBlack, 0.3, scrQuantize(xPos, 8), scrQuantize(yPos, 8));
        }
    }
    
    if (stateTimer >= 144 || controller == 3)
    {
        // Restart in-game music after bless music ends
        if (controller != 3)
        {
            scr50_IngameBGM(false);
            ingameMusicPlaying = true;
        }

        futureState = STATE_ACTIONS;

        for (var g = 0; g < NUM_GODS; g++)
        {
            if (player == 1 || global.numPlayers == 2)
            {
                if (godPower[player][g] == GOD_MAX_POWER)
                    scrWin(global.GARDEN_WIN);
            }
        }
    }
}
