var baseState = 200 + (10 * OFFERING);

if (subState == baseState)
{
    scr50_Sfx(soundGodNavi, 25);
    mirChoice = true;
    subState++;
    subChoice = 4;
    fire2pressed = false;
    scr50_MessageFastLocal("who_offering");
}

if (subState == (baseState + 1))
{
    if (pressLeft)
    {
        scr50_Sfx(soundGodNavi, 20);
        mirX--;
        
        if (mirX < 0)
            mirX = NUM_GODS - 1;
        
        scr50_HoldFlicker();
    }
    
    if (pressRight)
    {
        scr50_Sfx(soundGodNavi, 20);
        mirX++;
        
        if (mirX >= NUM_GODS)
            mirX = 0;
        
        scr50_HoldFlicker();
    }
    
    if (fire1pressed)
    {
        mirChoice = false;
        subChoice = true;
        subState = 51;
        subState = 298;
    }
    else if (fire2pressed)
    {
        scr50_Sfx(soundGodSelect, 50);
        scr50_MessageSlow(scrStringVal("gained_favor", GOD_NAMES[mirX]));
        godPower[player][mirX]++;
        
        if (godPower[player][mirX] > GOD_MAX_POWER)
            godPower[player][mirX] = GOD_MAX_POWER;
        
        if (controller != 3)
        {
            if (floor(godPower[player][mirX] / POWER_PER_UPGRADE) > godUpgrades[player][mirX])
            {
                scr50_Sfx(soundGodUnlockUpgrade, 60);
                stateTimer = 0;
                subState++;
                godUpgrades[player][mirX]++;
                scr50_MessageSlow(scrStringExt("upgrade_unlocked", "*", 35, 0));
                subChoice = false;
                mirChoice = false;
            }
            else
            {
                mirChoice = false;
                subState = 299;
            }
        }
        else
        {
            stateTimer = 0;
            subState = 51;
            mirChoice = false;
        }
    }
}

if (subState == (baseState + 2))
{
    stateTimer++;
    
    if (stateTimer >= 120)
    {
        mirChoice = false;
        scrBGM(bgm50_bless);
        stateTimer = 0;
        subState++;
        upgradeIndex = -1;
        var loopCounter = 0;
        var selectedAction;
        
        do
        {
            upgradeIndex++;
            
            if (upgradeIndex > (NUM_ACTIONS_PER_GOD - 1))
                upgradeIndex = 0;
            
            var prog = godPrograms[player][mirX];
            selectedAction = prog.actions[upgradeIndex];
            
            if (scr50_LoopIsStuck(loopCounter++, 21))
                break;
        }
        until (selectedAction.level <= 1);
        
        selectedAction.level++;
        scr50_LoadAction(player, mirX, upgradeIndex, selectedAction.level);
        flicker20 = false;
        scr50_MessageSlow(scrString("which_upgrade"));
    }
}

if (subState == (baseState + 3))
{
    var prog = godPrograms[player][mirX];
    var selectedAction = prog.actions[upgradeIndex];
    
    if (pressUp)
    {
        scr50_Sfx(soundMiracleNavi, 20);
        selectedAction.level--;
        scr50_LoadAction(player, mirX, upgradeIndex, selectedAction.level);
        var loopCounter = 0;
        
        do
        {
            upgradeIndex--;
            
            if (upgradeIndex < 0)
                upgradeIndex = NUM_ACTIONS_PER_GOD - 1;
            
            prog = godPrograms[player][mirX];
            selectedAction = prog.actions[upgradeIndex];
            
            if (scr50_LoopIsStuck(loopCounter++, 22))
                break;
        }
        until (selectedAction.level <= 1);
        
        selectedAction.level++;
        scr50_LoadAction(player, mirX, upgradeIndex, selectedAction.level);
    }
    
    if (pressDown)
    {
        scr50_Sfx(soundMiracleNavi, 20);
        selectedAction.level--;
        scr50_LoadAction(player, mirX, upgradeIndex, selectedAction.level);
        var loopCounter = 0;
        
        do
        {
            upgradeIndex++;
            
            if (upgradeIndex > (NUM_ACTIONS_PER_GOD - 1))
                upgradeIndex = 0;
            
            prog = godPrograms[player][mirX];
            selectedAction = prog.actions[upgradeIndex];
            
            if (scr50_LoopIsStuck(loopCounter++, 23))
                break;
        }
        until (selectedAction.level <= 1);
        
        selectedAction.level++;
        scr50_LoadAction(player, mirX, upgradeIndex, selectedAction.level);
    }
    
    if (fire2pressed)
    {
        // muteBGM();
        ingameMusicPlaying = false;
        scr50_Sfx(soundMiracle, 50);
        scr50_MessageSlow(scrStringExt("action_upgraded", "*", 35, 0));
        subState++;
    }
}

if (subState == (baseState + 4))
{
    stateTimer++;
    
    if ((stateTimer % 4) == 0 && stateTimer <= 80)
    {
        repeat (4)
        {
            var xPos = scrIRandomRange(HUD_LEFT, (HUD_LEFT + HUD_WIDTH) - 8);
            var yPos = scrIRandomRange(ACTION_TOP + (ACTION_HEIGHT * upgradeIndex), (ACTION_TOP + (ACTION_HEIGHT * upgradeIndex) + ACTION_HEIGHT) - 8);
            scrFX(s50_StarFXBlack, 0.3, scrQuantize(xPos, 8), scrQuantize(yPos, 8));
        }
    }
    
    if (stateTimer >= 144)
    {
        stateTimer = 100;
        subState = 299;
        scr50_MessageFast("");
        
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

baseState = 200 + (10 * REVEAL);

if (subState == baseState)
{
    numSelectable = 0;
    
    for (var i = 0; i < GRID_X_NUM; i++)
    {
        for (var j = 0; j < GRID_Y_NUM; j++)
        {
            var loc = map[i][j];
            
            if (loc.owner != 0 && loc.owner != player && !loc.revealed)
            {
                numSelectable++;
                selectable[i][j] = true;
            }
            else
            {
                selectable[i][j] = false;
            }
        }
    }
    
    if (numSelectable == 0)
    {
        scr50_Sfx(soundActionFizzled, 30);
        scr50_MessageFastLocal("no_reveal");
        subState = 51;
        selectMode = false;
        var refundType = action.params[subY][2];
        var refundAmount = action.params[subY][1];
        resources[player][refundType] += refundAmount;
        exit;
    }
    
    scr50_Sfx(soundMapNaviA, 25);
    scr50_FindSelectableLocation();
    selectMode = 1;
    scr50_MessageFastLocal("which_reveal");
    fire2pressed = false;
    subChoice = 3;
    subState++;
}

if (subState == (baseState + 1))
{
    scr50_MoveSelector();
    
    if (fire1pressed)
    {
        subState = 298;
    }
    else if (fire2pressed)
    {
        scr50_Sfx(soundMiracle, 50);
        map[selX][selY].revealed = 7;
        scr50_MessageSlow(scrString("revealed"));
        subState = 299;
        selectMode = 2;
        
        if (controller != 3)
            map[selX][selY].sparkleTimer = 48;
    }
}

baseState = 200 + (10 * FREEZE);

if (subState == baseState)
{
    numSelectable = 0;
    
    for (var i = 0; i < GRID_X_NUM; i++)
    {
        for (var j = 0; j < GRID_Y_NUM; j++)
        {
            var loc = map[i][j];
            
            if (loc.owner != 0 && loc.owner != player && !loc.frozen)
            {
                numSelectable++;
                selectable[i][j] = true;
            }
            else
            {
                selectable[i][j] = false;
            }
        }
    }
    
    if (numSelectable == 0)
    {
        scr50_Sfx(soundActionFizzled, 30);
        scr50_MessageFastLocal("no_freeze");
        subState = 51;
        selectMode = false;
        var refundType = action.params[subY][2];
        var refundAmount = action.params[subY][1];
        resources[player][refundType] += refundAmount;
        exit;
    }
    
    scr50_Sfx(soundMapNaviA, 25);
    scr50_FindSelectableLocation();
    selectMode = 1;
    scr50_MessageFastLocal("which_freeze");
    fire2pressed = false;
    subChoice = 3;
    subState++;
}

if (subState == (baseState + 1))
{
    scr50_MoveSelector();
    
    if (fire1pressed)
    {
        subState = 298;
    }
    else if (fire2pressed)
    {
        var unitsFrozen = 0;
        var loc = map[selX][selY];
        
        for (var i = 0; i < NUM_UNITS; i++)
            unitsFrozen += loc.units[i];
        
        if (unitsFrozen == 0)
        {
            scr50_Sfx(soundActionFizzled, 30);
            scr50_MessageSlow(scrString("no_enemy_units"));
        }
        else
        {
            scrSfx(soundMiracle, 50);
            map[selX][selY].frozen = 3;
            
            if (numPlayers == 1 && player == 2)
                scrMessageSet(scrStringVal("snowed_in_by_comp", unitsFrozen));
            else
                scrMessageSet(scrStringVal("snowed_in", unitsFrozen));
            
            map[selX][selY].sparkleTimer = 48;
        }
        
        subState = 299;
        selectMode = 2;
    }
}

baseState = 200 + (10 * LIGHTNING);

if (subState == baseState)
{
    numSelectable = 0;
    
    for (var i = 0; i < GRID_X_NUM; i++)
    {
        for (var j = 0; j < GRID_Y_NUM; j++)
        {
            var loc = map[i][j];
            
            if (loc.owner != 0 && loc.owner != player)
            {
                numSelectable++;
                selectable[i][j] = true;
            }
            else
            {
                selectable[i][j] = false;
            }
        }
    }
    
    if (numSelectable == 0)
    {
        scr50_Sfx(soundActionFizzled, 30);
        scr50_MessageFastLocal("no_strike");
        subState = 51;
        selectMode = false;
        var refundType = action.params[subY][2];
        var refundAmount = action.params[subY][1];
        resources[player][refundType] += refundAmount;
        exit;
    }
    
    scr50_Sfx(soundMapNaviA, 25);
    scr50_FindSelectableLocation();
    selectMode = 1;
    scr50_MessageFastLocal("where_struck");
    fire2pressed = false;
    subChoice = 3;
    subState++;
}

if (subState == (baseState + 1))
{
    scr50_MoveSelector();
    
    if (fire1pressed)
    {
        subState = 298;
    }
    else if (fire2pressed)
    {
        var unitsStruck = 0;
        var loc = map[selX][selY];
        
        for (var i = 0; i < NUM_UNITS; i++)
        {
            unitsStruck += min(loc.units[i], 2);
            loc.units[i] -= 2;
            
            if (loc.units[i] < 0)
                loc.units[i] = 0;
        }
        
        if (unitsStruck == 0)
        {
            scr50_Sfx(soundActionFizzled, 30);
            scr50_MessageSlow(scrString("no_enemy_units"));
        }
        else
        {
            scrSfx(soundMiracle, 50);
            
            if (numPlayers == 1 && player == 2)
                scrMessageSet(scrStringVal("killed_by_comp", unitsStruck));
            else
                scr50_MessageSlow(scrStringVal("enemy_units_killed", unitsStruck));
            
            map[selX][selY].sparkleTimer = 48;
        }
        
        subState = 299;
        selectMode = 2;
    }
}

baseState = 200 + (10 * EARTH_MOVE);

if (subState == baseState)
{
    numSelectable = 0;
    
    for (var i = 0; i < GRID_X_NUM; i++)
    {
        for (var j = 0; j < GRID_Y_NUM; j++)
        {
            var loc = map[i][j];
            
            if (abs(loc.terrain) == MOUNTAIN)
            {
                numSelectable++;
                selectable[i][j] = true;
            }
            else
            {
                selectable[i][j] = false;
            }
        }
    }
    
    if (numSelectable == 0)
    {
        scr50_Sfx(soundActionFizzled, 30);
        scr50_MessageFastLocal("no_earth_move");
        subState = 51;
        selectMode = false;
        var refundType = action.params[subY][2];
        var refundAmount = action.params[subY][1];
        resources[player][refundType] += refundAmount;
        exit;
    }
    
    scr50_Sfx(soundMapNaviA, 25);
    scr50_FindSelectableLocation();
    selectMode = 1;
    scr50_MessageFastLocal("which_earth_move");
    fire2pressed = false;
    subChoice = 3;
    subState++;
}

if (subState == (baseState + 1))
{
    scr50_MoveSelector();
    
    if (fire1pressed)
    {
        subState = 298;
    }
    else if (fire2pressed)
    {
        selectMode = 2;
        fromX = selX;
        fromY = selY;
        subState++;
    }
}

if (subState == (baseState + 2))
{
    numSelectable = 0;
    
    for (var i = 0; i < GRID_X_NUM; i++)
    {
        for (var j = 0; j < GRID_Y_NUM; j++)
        {
            var loc = map[i][j];
            
            if (abs(loc.terrain) != MOUNTAIN)
            {
                numSelectable++;
                selectable[i][j] = true;
            }
            else
            {
                selectable[i][j] = false;
            }
        }
    }
    
    if (numSelectable == 0)
    {
        scr50_Sfx(soundActionFizzled, 30);
        scr50_MessageFastLocal("no_destinations");
        subState = 51;
        selectMode = false;
        var refundType = action.params[subY][2];
        var refundAmount = action.params[subY][1];
        resources[player][refundType] += refundAmount;
        exit;
    }
    
    scr50_FindSelectableLocation();
    selectMode = 3;
    scr50_MessageFastLocal("where_earth_move");
    fire2pressed = false;
    subState++;
}

if (subState == (baseState + 3))
{
    scr50_MoveSelector();
    
    if (fire1pressed)
    {
        subState = 298;
    }
    else if (fire2pressed)
    {
        scrSfx(soundMiracle, 50);
        scrMessageSet(scrString("earth_moved"));
        map[fromX][fromY].terrain = sign(map[fromX][fromY].terrain) * ROCKS;
        map[fromX][fromY].sparkleTimer = 48;
        
        if (map[selX][selY].terrain <= 2)
            map[selX][selY].terrain = -MOUNTAIN;
        else
            map[selX][selY].terrain = MOUNTAIN;
        
        map[selX][selY].sparkleTimer = 48;
        selectMode = 4;
        subState = 299;
    }
}

baseState = 200 + (10 * TELEPORT);

if (subState == baseState)
{
    numSelectable = 0;
    
    for (var i = 0; i < GRID_X_NUM; i++)
    {
        for (var j = 0; j < GRID_Y_NUM; j++)
        {
            var loc = map[i][j];
            
            if (loc.owner == player)
                selectable[i][j] = true;
            else
                selectable[i][j] = false;
            
            var totalUnitsHere = 0;
            
            for (var k = 0; k < NUM_UNITS; k++)
                totalUnitsHere += loc.units[k];
            
            if (totalUnitsHere == 0)
                selectable[i][j] = false;
            
            if (loc.frozen)
                selectable[i][j] = false;
            
            if (selectable[i][j])
                numSelectable++;
        }
    }
    
    if (numSelectable == 0)
    {
        scr50_Sfx(soundActionFizzled, 30);
        scr50_MessageFastLocal("no_units");
        subState = 51;
        selectMode = false;
        var refundType = action.params[subY][2];
        var refundAmount = action.params[subY][1];
        resources[player][refundType] += refundAmount;
        exit;
    }
    
    scr50_Sfx(soundMapNaviA, 25);
    scr50_FindSelectableLocation();
    selectMode = 1;
    scr50_MessageFastLocal("where_from");
    fire2pressed = false;
    subChoice = 3;
    subState++;
}

if (subState == (baseState + 1))
{
    scr50_MoveSelector();
    
    if (fire1pressed)
    {
        subState = 298;
    }
    else if (fire2pressed)
    {
        scr50_Sfx(soundMapSelect, 50);
        fromX = selX;
        fromY = selY;
        fire2pressed = false;
        scr50_MessageFastLocal("which_units");
        scr50_InitTransfer();
        subState++;
    }
}

if (subState == (baseState + 2))
{
    scr50_TransferUnits();
    selectMode = 2;
    
    if (fire1pressed)
    {
        scr50_Sfx(soundUndo, 30);
        subState = baseState;
        transfer = false;
        exit;
    }
    
    if (fire2pressed)
    {
        var movingAtLeastOne = false;
        
        for (var i = 0; i < NUM_UNITS; i++)
        {
            if (movingUnits[i] > 0)
                movingAtLeastOne = true;
        }
        
        if (!movingAtLeastOne)
        {
            scr50_Sfx(soundActionFizzled, 30);
            scr50_MessageFastLocal("no_transfer");
            exit;
        }
        
        transfer = false;
        subState++;
        fire2pressed = false;
    }
}

if (subState == (baseState + 3))
{
    numSelectable = 0;
    
    for (var i = 0; i < GRID_X_NUM; i++)
    {
        for (var j = 0; j < GRID_Y_NUM; j++)
        {
            var dist = abs(fromX - i) + abs(fromY - j);
            
            if (dist >= 1 && dist <= TELEPORT_RANGE)
            {
                numSelectable++;
                selectable[i][j] = true;
            }
            else
            {
                selectable[i][j] = false;
            }
        }
    }
    
    scr50_FindSelectableLocation();
    selectMode = 3;
    scr50_MessageFastLocal("move_where");
    fire2pressed = false;
    subState++;
}

if (subState == (baseState + 4))
{
    scr50_MoveSelector();
    
    if (fire1pressed)
    {
        scr50_Sfx(soundUndo, 30);
        subState = baseState + 2;
        selectMode = 2;
        scr50_MessageFastLocal("which_units");
        scr50_InitTransfer();
        exit;
    }
    else if (fire2pressed)
    {
        scrSfx(soundMiracle, 50);
        map[fromX][fromY].sparkleTimer = 48;
        map[selX][selY].sparkleTimer = 48;
        fire2pressed = false;
        subState = 25;
    }
}

baseState = 200 + (10 * HAUNT);

if (subState == baseState)
{
    numSelectable = 0;
    
    for (var i = 0; i < GRID_X_NUM; i++)
    {
        for (var j = 0; j < GRID_Y_NUM; j++)
        {
            var loc = map[i][j];
            
            if (loc.owner != 0 && loc.owner != player)
            {
                var numUnits = 0;
                
                for (var k = 0; k < NUM_UNITS; k++)
                    numUnits += loc.units[k];
                
                if (numUnits >= 1)
                {
                    numSelectable++;
                    selectable[i][j] = true;
                }
                else
                {
                    selectable[i][j] = false;
                }
            }
            else
            {
                selectable[i][j] = false;
            }
        }
    }
    
    if (numSelectable == 0)
    {
        scr50_Sfx(soundActionFizzled, 30);
        scr50_MessageFastLocal("no_haunt");
        subState = 51;
        selectMode = false;
        var refundType = action.params[subY][2];
        var refundAmount = action.params[subY][1];
        resources[player][refundType] += refundAmount;
        exit;
    }
    
    scr50_FindSelectableLocation();
    selectMode = 1;
    scr50_MessageFastLocal("where_haunt");
    fire2pressed = false;
    subChoice = 3;
    subState++;
}

if (subState == (baseState + 1))
{
    scr50_MoveSelector();
    
    if (fire1pressed)
    {
        subState = 298;
    }
    else if (fire2pressed)
    {
        scrSfx(soundMiracle, 50);
        var numUnits = 0;
        var loc = map[selX][selY];
        
        for (var i = 0; i < NUM_UNITS; i++)
            numUnits += loc.units[i];
        
        if (numUnits > 1)
            numUnits = 1;
        
        var uType;
        
        repeat (numUnits)
        {
            uType = scrIRandomRange(0, NUM_UNITS - 1);
            
            repeat (5)
            {
                if (loc.units[uType] > 0)
                {
                    loc.units[uType]--;
                    break;
                }
                
                uType++;
                
                if (uType == NUM_UNITS)
                    uType = 0;
            }
        }
        
        scr50_MessageSlow(scrStringVal("enemy_units_scared", UNIT_NAMES[uType]));
        map[selX][selY].sparkleTimer = 48;
        subState = 299;
        selectMode = 2;
    }
}

baseState = 200 + (10 * CONJURE);

if (subState == baseState)
{
    numSelectable = 0;
    
    for (var i = 0; i < GRID_X_NUM; i++)
    {
        for (var j = 0; j < GRID_Y_NUM; j++)
        {
            var loc = map[i][j];
            
            if (loc.owner == player)
            {
                numSelectable++;
                selectable[i][j] = true;
            }
            else
            {
                selectable[i][j] = false;
            }
        }
    }
    
    if (numSelectable == 0)
    {
        scr50_Sfx(soundActionFizzled, 30);
        scr50_MessageFastLocal("no_conjure");
        subState = 51;
        selectMode = false;
        var refundType = action.params[subY][2];
        var refundAmount = action.params[subY][1];
        resources[player][refundType] += refundAmount;
        exit;
    }
    
    scr50_FindSelectableLocation();
    selectMode = 1;
    scr50_MessageFastLocal("where_conjure");
    fire2pressed = false;
    subChoice = 3;
    subState++;
}

if (subState == (baseState + 1))
{
    scr50_MoveSelector();
    
    if (fire1pressed)
    {
        subState = 298;
    }
    else if (fire2pressed)
    {
        var loc = map[selX][selY];
        var uType = scrIRandomRange(0, NUM_UNITS - 1);
        loc.units[uType]++;
        scr50_MessageSlow(scrStringVal("unit_conjured", UNIT_NAMES[uType]));
        map[selX][selY].sparkleTimer = 48;
        loc.unitFlashTimer[uType] = 96;
        scrSfx(soundMiracle, 50);
        subState = 299;
        selectMode = 2;
    }
}

if (subState == 299)
{
    stateTimer++;
    subChoice = 3;
    
    if (stateTimer >= 96)
    {
        mute(soundGodSelect);
        scr50_Sfx(soundNavi, 20);

        // Restart in-game music after bless music ends (miracle offering upgrade)
        if (!ingameMusicPlaying) scr50_IngameBGM(false);
        ingameMusicPlaying = true;

        stateTimer = 0;
        subState = 51;
        selectMode = false;
    }
}

if (subState == 298)
{
    scr50_Sfx(soundUndo, 30);
    selectMode = false;
    subState = 51;
    selectMode = false;
    var refundType = action.params[subY][2];
    var refundAmount = action.params[subY][1];
    resources[player][refundType] += refundAmount;
    scr50_MessageFastLocal("what_miracle");
}
