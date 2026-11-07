if (subState == 0)
{
    newBuildTimer = 0;
    newUnitTimer = 0;
    scr50_MessageFast("");
    pauseAmount = 32;
    selectMode = 0;
    subChoice = false;
    subY = 0;
    
    for (var i = 0; i < GRID_X_NUM; i++)
    {
        for (var j = 0; j < GRID_Y_NUM; j++)
            selectable[i][j] = false;
    }
    
    numSelectable = 0;
    mirX = 0;
    mirChoice = false;
    aiToX = -1;
    aiToY = -1;
    aiFromX = -1;
    aiFromY = -1;
    aiToXalt = -1;
    aiToYalt = -1;
    
    with (o50_Buy)
        instance_destroy();
    
    ds_list_clear(potBuys);
    
    with (o50_Move)
        instance_destroy();
    
    ds_list_clear(potMoves);
    
    if (dontGoToNextAction)
        dontGoToNextAction = false;
    else
        actionIndex++;
    
    actionHighlight = actionIndex + 1;
    program = godPrograms[player][god];
    
    if (!verify(program))
    {
        futureState = STATE_END_TURN;
        exit;
    }
    
    if (actionIndex >= program.NUM_ACTIONS)
    {
        futureState = STATE_END_TURN;
        exit;
    }
    
    action = program.actions[actionIndex];
    
    if (!verify(action))
    {
        futureState = STATE_END_TURN;
        exit;
    }
    
    params = action.params;
    
    if (!is_array(params))
    {
        futureState = STATE_END_TURN;
        exit;
    }
    
    if (action.type == PRODUCE)
    {
        subState = 10;
    }
    else if (action.type == MOVE)
    {
        subState = 20;
    }
    else if (action.type == RECRUIT)
    {
        subState = 30;
    }
    else if (action.type == BUILD)
    {
        subState = 40;
    }
    else if (action.type == MIRACLE)
    {
        subState = 50;
    }
    else if (action.type == TRADE)
    {
        subState = 60;
    }
    else if (action.type == MUSTER)
    {
        subState = 70;
    }
    else
    {
        actionHighlight = NUM_ACTIONS_PER_GOD + 1;
        futureState = STATE_END_TURN;
        exit;
    }
}

if (subState == 10)
{
    for (var i = 0; i < NUM_RESOURCES; i++)
        resourceCounter[i] = 0;
    
    for (var k = 0; k < action.NUM_STEPS; k++)
    {
        if (params[k][0] == -1)
            continue;
        
        var resAmount = params[k][0];
        var resType = params[k][1];
        var sourceType = params[k][2];
        var multiplier;
        
        if (sourceType != -1)
        {
            multiplier = 0;
            
            for (var i = 0; i < GRID_X_NUM; i++)
            {
                for (var j = 0; j < GRID_Y_NUM; j++)
                {
                    var loc = map[i][j];
                    
                    if (loc.owner == player)
                        multiplier += loc.buildings[sourceType];
                }
            }
        }
        else
        {
            multiplier = 1;
        }
        
        var amountProduced = resAmount * multiplier;
        resourceCounter[resType] += amountProduced;
    }
    
    var numResTypes = 0;
    
    for (var i = 0; i < NUM_RESOURCES; i++)
    {
        if (resourceCounter[i])
            numResTypes++;
    }
    
    var str;
    
    if (numResTypes == 0)
        str = scrString("gained_nothing");
    
    if (numResTypes == 1)
        str = scrString("gained");
    
    if (numResTypes == 2)
        str = scrString("gained_2");
    
    if (numResTypes == 3)
        str = scrString("gained_3");
    
    for (var i = 0; i < NUM_RESOURCES; i++)
    {
        resources[player][i] += resourceCounter[i];
        resourceDelta[player][i] += resourceCounter[i];
        
        if (resourceCounter[i] > 0)
        {
            str = string_replace(str, "#", resourceCounter[i]);
            
            if (numResTypes < 3)
                str = string_replace(str, "*******", RES_NAMES[i]);
            else
                str = string_replace(str, "*", RES_ICONS[i]);
        }
    }
    
    scr50_MessageSlow(str);
    
    for (var i = 0; i < NUM_RESOURCES; i++)
    {
        if (resources[player][i] > RES_MAX[i])
        {
            resources[player][i] = RES_MAX[i];
            resourceDelta[player][i] = 0;
            scr50_MessageFast(scrStringVal("maxed_out", RES_NAMES[i]));
        }
    }
    
    subState = 100;
}

if (subState == 20)
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
        scr50_MessageFastLocal("no_units");
        subState = 100;
        exit;
    }
    
    selectMode = 1;
    scr50_FindSelectableLocation();
    scr50_MessageFastLocal("where_from");
    mute(soundNextAction);
    scr50_Sfx(soundMapNaviA, 20);
    subState = 21;
}

if (subState == 21)
{
    scr50_MoveSelector();
    
    if (fire1pressed)
    {
        scr50_Sfx(soundNextAction, 50);
        subState = 101;
        selectMode = 0;
        subChoice = false;
        exit;
    }
    
    if (fire2pressed)
    {
        scr50_Sfx(soundMapSelect, 50);
        fire2pressed = false;
        subState = 22;
        fromX = selX;
        fromY = selY;
        selectMode = 2;
        scr50_MessageFastLocal("which_units");
        scr50_InitTransfer();
    }
}

if (subState == 22)
{
    scr50_TransferUnits();
    
    if (fire1pressed)
    {
        scr50_Sfx(soundUndo, 30);
        subState = 20;
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
        subState = 23;
        fire2pressed = false;
    }
}

if (subState == 23)
{
    numSelectable = 0;
    
    for (var i = 0; i < GRID_X_NUM; i++)
    {
        for (var j = 0; j < GRID_Y_NUM; j++)
        {
            var loc = map[i][j];
            
            if (abs(loc.terrain) == MOUNTAIN && params[0][MOVE_MOUNTAIN] != 1)
            {
                selectable[i][j] = false;
            }
            else if (i == fromX && j == fromY)
            {
                selectable[i][j] = false;
            }
            else if (params[0][MOVE_DIAGONAL] != 1 && (abs(i - fromX) + abs(j - fromY)) != 1)
            {
                selectable[i][j] = false;
            }
            else if (params[0][MOVE_DIAGONAL] == 1 && (abs(i - fromX) > 1 || abs(j - fromY) > 1))
            {
                selectable[i][j] = false;
            }
            else
            {
                selectable[i][j] = true;
                numSelectable++;
            }
        }
    }
    
    if (numSelectable == 0)
    {
        scr50_MessageFastLocal("nowhere_to_move");
        subState = 100;
        exit;
    }
    
    scr50_MessageFastLocal("move_where");
    selectMode = 3;
    scr50_FindSelectableLocation();
    scr50_HoldFlicker();
    scr50_Sfx(soundMapNaviB, 20);
    subState = 24;
}

if (subState == 24)
{
    scr50_MoveSelector();
    
    if (fire1pressed)
    {
        scr50_Sfx(soundUndo, 30);
        subState = 22;
        selectMode = 2;
        scr50_MessageFastLocal("which_units");
        scr50_InitTransfer();
        exit;
    }
    
    if (fire2pressed)
    {
        subState = 25;
        fire2pressed = false;
    }
}

if (subState == 25)
{
    selectMode = 4;
    actionHighlight = NUM_ACTIONS_PER_GOD + 1;
    var toLoc = map[selX][selY];
    var fromLoc = map[fromX][fromY];
    
    if (toLoc.owner && toLoc.owner != player)
    {
        scrBGM(bgm50_stingStart, false);
        subState = 27;
        combatFlash = true;
        scr50_HoldFlicker();
        
        if (numPlayers == 1)
            controller = 1;
        
        if (numPlayers == 1 && player == 1)
            scrMessageSet(scrString("you_attacked"));
        else if (numPlayers == 1 && player == 2)
            scrMessageSet(scrString("they_attacked"));
        else if (numPlayers == 2 && !fogOfWar)
            scrMessageSet(scrStringExt("player_attacked", player, 35, 0));
        else
            scrMessageSet(scrStringExt("player_attacked_fog", player, 35, 0));
    }
    else
    {
        if (controller == 3 && toLoc.owner != player)
        {
            scrSfx(soundMoveUnits, 70);
            scrMessageSet(scrString("enemy_expand"));
        }
        else if (controller != 3)
        {
            scrSfx(soundMoveUnits, 70);
        }
        
        for (var i = 0; i < NUM_UNITS; i++)
        {
            fromLoc.units[i] -= movingUnits[i];
            toLoc.units[i] += movingUnits[i];
        }
        
        toLoc.owner = player;
        
        if (toLoc.terrain == CASTLE || toLoc.terrain == CASTLE_P1 || toLoc.terrain == CASTLE_P2)
            toLoc.terrain = player;
        
        if (scr50_VictoryCheck())
            exit;
        
        var hasResources = false;
        
        for (var i = 0; i < NUM_RESOURCES; i++)
        {
            if (toLoc.resources[i])
                hasResources = true;
        }
        
        if (hasResources)
        {
            subState = 26;
        }
        else
        {
            if (action.type == MOVE)
            {
                pauseAmount = 48;
                subState = 101;
            }
            else if (action.type == MIRACLE)
            {
                subState = 299;
            }
            
            exit;
        }
    }
}

if (subState == 26)
{
    stateTimer++;
    
    if (stateTimer == 32)
    {
        var toLoc = map[selX][selY];
        var numResources = 0;
        
        for (var i = 0; i < NUM_RESOURCES; i++)
        {
            if (toLoc.resources[i])
                numResources++;
        }
        
        var collectString;
        
        if (numResources == 1)
            collectString = scrString("found");
        else
            collectString = scrString("found_2");
        
        for (var i = 0; i < NUM_RESOURCES; i++)
        {
            if (toLoc.resources[i])
            {
                resources[player][i] += toLoc.resources[i];
                resourceDelta[player][i] += toLoc.resources[i];
                scr50_HoldFlicker();
                flicker20 = false;
                collectString = string_replace(collectString, "#", string(toLoc.resources[i]));
                collectString = string_replace(collectString, "*******", string(RES_NAMES[i]));
                
                if (resources[player][i] > RES_MAX[i])
                {
                    resources[player][i] = RES_MAX[i];
                    resourceDelta[player][i] = 0;
                }
            }
        }
        
        scr50_MessageSlow(collectString);
        
        if (controller == 3)
            stateTimer = 132;
    }
    
    if (stateTimer == 132)
    {
        stateTimer = 0;
        
        if (action.type == MOVE)
            subState = 101;
        else if (action.type == MIRACLE)
            subState = 299;
        
        var toLoc = map[selX][selY];
        
        for (var i = 0; i < NUM_RESOURCES; i++)
            toLoc.resources[i] = 0;
        
        exit;
    }
}

if (subState == 27)
{
    if (fire2pressed || aiVersus)
    {
        // muteBGM();
        // ingameMusicPlaying = false;
        scrSfx(soundBattleTransition, 80);
        scrTransition(13, 32, 0, -10, false);
        subState = 28;
    }
}

if (subState == 28)
{
    if (scrTransitionDone())
    {
        combatFlash = false;
        futureState = STATE_COMBAT;
        exit;
    }
}

if (subState == 30)
{
    numSelectable = 0;
    
    for (var i = 0; i < GRID_X_NUM; i++)
    {
        for (var j = 0; j < GRID_Y_NUM; j++)
        {
            var loc = map[i][j];
            
            if (loc.owner == player && (loc.terrain <= 2 || loc.buildings[NEST]))
                selectable[i][j] = true;
            else
                selectable[i][j] = false;
            
            if (selectable[i][j])
                numSelectable++;
        }
    }
    
    if (numSelectable == 0)
    {
        scr50_MessageFastLocal("no_place_recruit");
        subState = 100;
        exit;
    }
    
    numAffordable = 0;
    
    for (var i = 0; i < action.NUM_STEPS; i++)
    {
        var resType = params[i][2];
        var resCost = params[i][1];
        var buyType = params[i][0];
        
        if (buyType != -1)
        {
            if (resources[player][resType] >= resCost)
                numAffordable++;
        }
    }
    
    if (numAffordable == 0)
    {
        scr50_MessageFastLocal("cant_afford_recruit");
        subState = 100;
        exit;
    }
    
    if (numSelectable == 1)
    {
        mute(soundNextAction);
        scr50_Sfx(soundMapSelect, 50);
        selectMode = 2;
        scr50_MessageFastLocal("who_recruit");
        subChoice = true;
        subY = 0;
        subState = 32;
        scr50_FindSelectableLocation();
        scr50_HoldFlicker();
        exit;
    }
    
    if (NUM_CONTROL_POINTS == 0)
        recruitString = scrStringExt("where_recruit", TER_ICONS[0], 35, 0);
    else
        recruitString = scrStringExt("where_recruit", TER_ICONS[1], 35, 0);
    
    var recruitString = string_replace(recruitString, "@", BLD_ICONS[NEST]);
    scr50_MessageFast(recruitString);
    selectMode = 1;
    scr50_FindSelectableLocation();
    scr50_HoldFlicker();
    mute(soundNextAction);
    scr50_Sfx(soundMapNaviA, 20);
    subState++;
}

if (subState == 31)
{
    scr50_MoveSelector();
    
    if (fire1pressed)
    {
        scr50_Sfx(soundNextAction, 50);
        subState = 101;
        selectMode = 0;
        subChoice = false;
        exit;
    }
    
    if (fire2pressed)
    {
        scr50_Sfx(soundMapSelect, 50);
        selectMode = 2;
        fire2pressed = false;
        scr50_MessageFastLocal("who_recruit");
        subChoice = true;
        subY = 0;
        subState++;
        scr50_HoldFlicker();
    }
}

if (subState == 32)
{
    var choice = scr50_MakingSubChoice();
    
    if (choice == 1)
    {
        var resType = params[subY][2];
        var resCost = params[subY][1];
        var buyType = params[subY][0];
        
        if (resources[player][resType] < resCost)
        {
            scr50_Sfx(soundActionFizzled, 30);
            scr50_MessageFast(scrStringVal("not_enough", RES_NAMES[resType]));
        }
        else
        {
            scr50_Sfx(soundRecruitUnit, 60);
            resources[player][resType] -= resCost;
            var loc = map[selX][selY];
            
            if (verify(loc))
                loc.units[buyType]++;
            
            scr50_MessageFast(scrStringVal("recruited", UNIT_NAMES[buyType]));
            loc.unitFlashTimer[buyType] = 80;
            scr50_HoldFlicker();
        }
    }
    
    if (choice == 2)
    {
        scr50_Sfx(soundNextAction, 50);
        subState = 101;
        selectMode = 0;
        subChoice = false;
        exit;
    }
    
    if (choice == 3)
    {
        if (numSelectable > 1)
        {
            scr50_Sfx(soundUndo, 30);
            subState = 30;
            subChoice = false;
            exit;
        }
        else
        {
            scr50_Sfx(soundNextAction, 50);
            subState = 101;
            selectMode = 0;
            subChoice = false;
            exit;
        }
    }
}

if (subState == 40)
{
    numSelectable = 0;
    
    for (var i = 0; i < GRID_X_NUM; i++)
    {
        for (var j = 0; j < GRID_Y_NUM; j++)
        {
            var loc = map[i][j];
            selectable[i][j] = false;
            
            if (loc.owner == player)
            {
                selectable[i][j] = true;
                var totalBuildings = 0;
                
                for (var k = 0; k < NUM_BUILDINGS; k++)
                    totalBuildings += loc.buildings[k];
                
                if (totalBuildings >= MAX_BUILDINGS_PER_LOCATION)
                    selectable[i][j] = false;
            }
            
            if (selectable[i][j])
                numSelectable++;
        }
    }
    
    if (numSelectable == 0)
    {
        scr50_MessageFastLocal("no_room");
        subState = 100;
        exit;
    }
    
    numAffordable = 0;
    
    for (var i = 0; i < action.NUM_STEPS; i++)
    {
        var resType = params[i][2];
        var resCost = params[i][1];
        var buyType = params[i][0];
        
        if (buyType != -1)
        {
            if (resources[player][resType] >= resCost)
                numAffordable++;
        }
    }
    
    if (numAffordable == 0)
    {
        scr50_MessageFastLocal("cant_afford_build");
        subState = 100;
        exit;
    }
    
    if (numSelectable == 1)
    {
        mute(soundNextAction);
        scr50_Sfx(soundMapSelect, 50);
        selectMode = 2;
        scr50_MessageFastLocal("what_build");
        subChoice = true;
        subY = 0;
        subState = 42;
        scr50_FindSelectableLocation();
        scr50_HoldFlicker();
        exit;
    }
    
    scr50_MessageFastLocal("where_build");
    selectMode = 1;
    scr50_FindSelectableLocation();
    scr50_HoldFlicker();
    mute(soundNextAction);
    scr50_Sfx(soundMapNaviA, 20);
    subState++;
}

if (subState == 41)
{
    scr50_MoveSelector();
    
    if (fire1pressed)
    {
        scr50_Sfx(soundNextAction, 50);
        subState = 101;
        selectMode = 0;
        subChoice = false;
        exit;
    }
    
    if (fire2pressed)
    {
        scr50_Sfx(soundMapSelect, 50);
        selectMode = 2;
        fire2pressed = false;
        scr50_MessageFastLocal("what_build");
        subChoice = true;
        subY = 0;
        subState++;
        scr50_HoldFlicker();
    }
}

if (subState == 42)
{
    if (selX == -1 || selY == -1)
    {
        scr50_Sfx(soundNextAction, 50);
        subState = 101;
        selectMode = 0;
        subChoice = false;
        exit;
    }
    
    var loc = map[selX][selY];
    var choice = scr50_MakingSubChoice();
    
    if (choice == 1)
    {
        var resType = params[subY][2];
        var resCost = params[subY][1];
        var buyType = params[subY][0];
        var totalBuildings = 0;
        
        for (var k = 0; k < NUM_BUILDINGS; k++)
            totalBuildings += loc.buildings[k];
        
        if (resources[player][resType] < resCost)
        {
            scr50_Sfx(soundActionFizzled, 30);
            scr50_MessageFast(scrStringVal("not_enough", RES_NAMES[resType]));
        }
        else if (loc.buildings[buyType] >= BUILDINGS_PER_LOCATION)
        {
            scr50_Sfx(soundActionFizzled, 30);
            scr50_MessageFast(scrStringExt("already_here", BUILDINGS_PER_LOCATION, 35, 0));
        }
        else if (totalBuildings >= MAX_BUILDINGS_PER_LOCATION)
        {
            scr50_Sfx(soundActionFizzled, 30);
            scr50_MessageFastLocal("no_room");
        }
        else
        {
            scr50_Sfx(soundBuild, 60);
            resources[player][resType] -= resCost;
            loc.buildings[buyType]++;
            scr50_MessageFast(scrStringVal("built", BLD_NAMES[buyType]));
            newBuildTimer = 120;
            newBuildType = buyType;
            newBuildX = selX;
            newBuildY = selY;
            scr50_HoldFlicker();
        }
    }
    
    if (choice == 2)
    {
        scr50_Sfx(soundNextAction, 50);
        subState = 101;
        selectMode = 0;
        subChoice = false;
        exit;
    }
    
    if (choice == 3)
    {
        if (numSelectable > 1)
        {
            scr50_Sfx(soundUndo, 30);
            subState = 40;
            subChoice = false;
            exit;
        }
        else
        {
            scr50_Sfx(soundNextAction, 50);
            subState = 101;
            selectMode = 0;
            subChoice = false;
            exit;
        }
    }
}

if (subState == 50)
{
    numAffordable = 0;
    
    for (var i = 0; i < action.NUM_STEPS; i++)
    {
        var resType = params[i][2];
        var resCost = params[i][1];
        var buyType = params[i][0];
        
        if (buyType != -1)
        {
            if (resources[player][resType] >= resCost)
                numAffordable++;
        }
    }
    
    if (numAffordable == 0)
    {
        scr50_MessageFastLocal("cant_afford_miracle");
        subState = 100;
        subChoice = false;
        exit;
    }
    
    mute(soundNextAction);
    scr50_Sfx(soundNavi, 20);
    scr50_MessageFastLocal("what_miracle");
    subState = 51;
}

if (subState == 51)
{
    var loc = map[selX][selY];
    subChoice = 2;
    var choice = scr50_MakingSubChoice();
    
    if (choice == 1)
    {
        var resType = params[subY][2];
        var resCost = params[subY][1];
        var buyType = params[subY][0];
        
        if (resources[player][resType] < resCost)
        {
            scr50_Sfx(soundActionFizzled, 30);
            scr50_MessageFast(scrStringVal("not_enough", RES_NAMES[resType]));
        }
        else
        {
            resources[player][resType] -= resCost;
            subState = 200 + (10 * buyType);
            scr50_HoldFlicker();
        }
    }
    
    if (choice == 2)
    {
        scr50_Sfx(soundNextAction, 50);
        subState = 101;
        selectMode = 0;
        subChoice = false;
        exit;
    }
    
    if (choice == 3)
    {
        scr50_Sfx(soundNextAction, 50);
        subState = 101;
        selectMode = 0;
        subChoice = false;
        exit;
    }
}

if (subState >= 200 && subState < 300)
    event_user(STATE_MIRACLE);

if (subState == 60)
{
    numAffordable = 0;
    
    for (var i = 0; i < action.NUM_STEPS; i++)
    {
        var resType = params[i][2];
        var resCost = params[i][1];
        var buyType = params[i][0];
        
        if (buyType != -1)
        {
            if (resources[player][resType] >= resCost)
                numAffordable++;
        }
    }
    
    if (numAffordable == 0)
    {
        scr50_MessageFastLocal("no_trade");
        subState = 100;
        exit;
    }
    
    mute(soundNextAction);
    scr50_Sfx(soundNavi, 20);
    scr50_MessageFastLocal("what_trade");
    subY = 0;
    subState = 61;
}

if (subState == 61)
{
    var loc = map[selX][selY];
    subChoice = 1;
    var choice = scr50_MakingSubChoice();
    
    if (choice == 1)
    {
        var resType = params[subY][2];
        var resCost = params[subY][1];
        var resType2 = params[subY][4];
        var resCost2 = params[subY][3];
        
        if (resources[player][resType] < resCost)
        {
            scr50_Sfx(soundActionFizzled, 30);
            scr50_MessageFast(scrStringVal("not_enough", RES_NAMES[resType]));
        }
        else if (resources[player][resType2] >= RES_MAX[resType2])
        {
            scr50_Sfx(soundActionFizzled, 30);
            scr50_MessageFast(scrStringVal("maxed_out", RES_NAMES[resType2]));
        }
        else
        {
            resources[player][resType] -= resCost;
            resources[player][resType2] += resCost2;
            resourceDelta[player][resType2] += resCost2;
            scr50_HoldFlicker();
            var str = scrString("gained");
            str = string_replace(str, "#", string(resCost2));
            str = string_replace(str, "*******", RES_NAMES[resType2]);
            scr50_MessageSlow(str);
            
            for (var i = 0; i < NUM_RESOURCES; i++)
            {
                if (resources[player][i] > RES_MAX[i])
                {
                    scr50_Sfx(soundActionFizzled, 30);
                    resources[player][i] = RES_MAX[i];
                    resourceDelta[player][i] = 0;
                    scr50_MessageFast(scrStringVal("maxed_out", RES_NAMES[i]));
                }
            }
        }
    }
    
    if (choice == 2)
    {
        scr50_Sfx(soundNextAction, 50);
        subState = 101;
        selectMode = 0;
        subChoice = false;
        exit;
    }
    
    if (choice == 3)
    {
        scr50_Sfx(soundNextAction, 50);
        subState = 101;
        subChoice = false;
        selectMode = 0;
        exit;
    }
}

if (subState == 70)
{
    for (var i = 0; i < NUM_UNITS; i++)
        unitCounter[i] = 0;
    
    for (var k = 0; k < action.NUM_STEPS; k++)
    {
        if (params[k][0] == -1)
            continue;
        
        var unitAmount = params[k][0];
        var unitType = params[k][1];
        var sourceType = params[k][2];
        
        for (var i = 0; i < GRID_X_NUM; i++)
        {
            for (var j = 0; j < GRID_Y_NUM; j++)
            {
                var loc = map[i][j];
                
                if (loc.owner == player)
                {
                    if (loc.buildings[sourceType])
                    {
                        repeat (loc.buildings[sourceType])
                        {
                            loc.units[unitType] += unitAmount;
                            
                            if (loc.units[unitType] > UNIT_MAX[unitType])
                                loc.units[unitType] = UNIT_MAX[unitType];
                            
                            loc.unitFlashTimer[unitType] = 80;
                            unitCounter[unitType] += unitAmount;
                        }
                    }
                }
            }
        }
    }
    
    var totalMustered = 0;
    
    for (var i = 0; i < NUM_UNITS; i++)
        totalMustered += unitCounter[i];
    
    var str = scrStringVal("mustered", totalMustered);
    scr50_Sfx(soundRecruitUnit, 60);
    scr50_HoldFlicker();
    scr50_MessageFast(str);
    subState = 100;
}

if (subState == 100)
{
    if (!nextActionPrompt)
    {
        scrInputClear();
        nextActionPrompt = true;
        scr50_HoldFlicker();
    }
    
    if (fire2pressed || fire1pressed)
    {
        scr50_Sfx(soundNextAction, 50);
        nextActionPrompt = false;
        
        for (var i = 0; i < NUM_RESOURCES; i++)
            resourceDelta[player][i] = 0;
        
        pauseAmount = 20;
        subState = 101;
    }
}

if (subState == 101)
{
    stateTimer++;
    actionHighlight = NUM_ACTIONS_PER_GOD + 1;
    
    if (stateTimer >= pauseAmount)
    {
        stateTimer = 0;
        subState = 0;
    }
}
