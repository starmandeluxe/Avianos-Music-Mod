if (subState == 0)
{
    subState++;
    scrTransition(14, 32, 0, -10, true);
    stalemateTimer = 0;
    combatTimer = 0;
    wakeupTimer = UNSURPRISE_CHANCE;
    myTotalUnitValue = 0;
    oppTotalUnitValue = 0;
    myRPSValue = 0;
    oppRPSValue = 0;
    myCombatValue = 0;
    oppCombatValue = 0;
    myTotalRangeValue = 0;
    oppTotalRangeValue = 0;
    
    for (var i = 0; i < NUM_UNITS; i++)
    {
        myUnits[i] = 0;
        myUnitValues[i] = 0;
        oppUnits[i] = 0;
        oppUnitValues[i] = 0;
    }
    
    if (!global.attractMode)
    {
        attackLoc = map[fromX][fromY];
        defendLoc = map[selX][selY];
        
        if (AI_LEARNING)
        {
            aiKnowledge[fromX][fromY] = true;
            aiKnowledge[selX][selY] = true;
        }
        
        currTerrain = abs(defendLoc.terrain);
        
        for (var i = 0; i < NUM_UNITS; i++)
        {
            attackLoc.units[i] -= movingUnits[i];
            attackers[i] = movingUnits[i];
            movingUnits[i] = 0;
        }
        
        surpriseAttack = false;
        
        if (verify(action) && is_array(params))
        {
            if (action.type == MOVE && params[0][MOVE_ATTACK])
                surpriseAttack = true;
        }
        
        defenders = defendLoc.units;
        
        if (player == 1)
        {
            attackPlayer = 1;
            defendPlayer = 2;
        }
        else
        {
            attackPlayer = 2;
            defendPlayer = 1;
        }
        
        possibleRetreatLocs = false;
        var r = 0;
        
        for (var i = 0; i < GRID_X_NUM; i++)
        {
            for (var j = 0; j < GRID_Y_NUM; j++)
            {
                if ((abs(i - selX) + abs(j - selY)) == 1 && map[i][j].owner == defendPlayer)
                {
                    possibleRetreatLocs[r] = map[i][j];
                    r++;
                }
            }
        }
        
        if (r == 0)
            retreatLoc = -4;
        else
            retreatLoc = possibleRetreatLocs[scrIRandom(r - 1)];
    }
    else
    {
        attackPlayer = scrChoose(1, 2);
        attackers[0] = 0;
        attackers[1] = 0;
        attackers[2] = 0;
        attackers[3] = 0;
        attackers[4] = 0;
        var attackMoney = 50;
        var skippedUnit = scrIRandomRange(0, 4);
        
        while (attackMoney >= 3)
        {
            var u;
            
            do
                u = scrIRandomRange(0, 4);
            until (u != skippedUnit);
            
            var c;
            
            if (u == 0)
                c = 2;
            
            if (u == 1)
                c = 3;
            
            if (u == 2 || u == 3)
                c = 4;
            
            if (u == 4)
                c = 5;
            
            if (attackMoney >= c)
            {
                attackMoney -= c;
                attackers[u]++;
            }
        }
        
        if (attackPlayer == 1)
            defendPlayer = 2;
        else
            defendPlayer = 1;
        
        defenders[0] = 0;
        defenders[1] = 0;
        defenders[2] = 0;
        defenders[3] = 0;
        defenders[4] = 0;
        var defendMoney = 50;
        skippedUnit = scrIRandomRange(0, 4);
        
        while (defendMoney >= 3)
        {
            var u;
            
            do
                u = scrIRandomRange(0, 4);
            until (u != skippedUnit);
            
            var c;
            
            if (u == 0)
                c = 2;
            
            if (u == 1)
                c = 3;
            
            if (u == 2 || u == 3)
                c = 4;
            
            if (u == 4)
                c = 5;
            
            if (defendMoney >= c)
            {
                defendMoney -= c;
                defenders[u]++;
            }
        }
        
        retreatLoc = -4;
        defendLoc = instance_create(0, 0, o50_Location);
        player = 2;
        surpriseAttack = scrChoose(false, false, false, false, true);
        currTerrain = scrIRandomRange(1, 8);
    }
    
    if (currTerrain == CASTLE_P1)
        terrainX = 768;
    else if (currTerrain == CASTLE_P2)
        terrainX = 384;
    else if (currTerrain == GRASS)
        terrainX = 1152;
    else if (currTerrain == FOREST)
        terrainX = 1536;
    else if (currTerrain == MOUNTAIN)
        terrainX = 1920;
    else if (currTerrain == CHASM)
        terrainX = 2304;
    else if (currTerrain == ROCKS)
        terrainX = 2688;
    else if (currTerrain == BONES)
        terrainX = 3072;
    else
        terrainX = 1152;
    
    set_view(terrainX, 0);
    instance_deactivate_object(o50__Spawn);
    instance_deactivate_object(o50__ObstacleHigh);
    instance_deactivate_object(o50__ObstacleMid);
    instance_deactivate_object(o50__ObstacleNoPlat);
    instance_deactivate_object(o50__SideHigh);
    instance_deactivate_object(o50__SideMid);
    instance_deactivate_object(o50__SideShortHigh);
    instance_deactivate_object(o50__HighPlatWide);
    instance_deactivate_object(o50__MidPlatWide);
    instance_deactivate_object(o50__MidPlatNarrow);
    scrActivateRegion(terrainX, 0, 383, 215, true);
    mp_grid_destroy(mapGrid);
    mp_grid_destroy(pathGrid);
    mp_grid_destroy(flightGrid);
    mapGrid = mp_grid_create(COMBAT_LEFT + terrainX, COMBAT_TOP, COMBAT_GRID_X, COMBAT_GRID_Y, COMBAT_RES, COMBAT_RES);
    pathGrid = mp_grid_create(COMBAT_LEFT + terrainX, COMBAT_TOP, COMBAT_GRID_X, COMBAT_GRID_Y, COMBAT_RES, COMBAT_RES);
    flightGrid = mp_grid_create(COMBAT_LEFT + terrainX, COMBAT_TOP, COMBAT_GRID_X, COMBAT_GRID_Y, COMBAT_RES, COMBAT_RES);
    exit;
}

if (subState == 1)
{
    subState = 2;
    var defenderCounter = 0;
    
    with (o50__Unit)
        instance_destroy();
    
    with (o50__Spawn)
        used = false;
    
    for (var p = 1; p <= 2; p++)
    {
        var unitsPlaced = 0;
        var totalUnitsToPlace = 0;
        
        for (i = 0; i < NUM_UNITS; i++)
        {
            if (p == attackPlayer)
                unitsToPlace[i] = attackers[i];
            else
                unitsToPlace[i] = defenders[i];
            
            totalUnitsToPlace += unitsToPlace[i];
        }
        
        totalUnitsToPlace = min(totalUnitsToPlace, UNIT_MAX_ALL / 2);
        var i = -1;
        
        while (unitsPlaced < totalUnitsToPlace)
        {
            i++;
            
            if (i >= NUM_UNITS)
                i = 0;
            
            if (unitsToPlace[i] <= 0)
                continue;
            
            if (p == defendPlayer)
                defenderCounter++;
            
            var spawnType;
            
            if (i == SOLDIERS || i == KNIGHTS || i == BOMBERS)
                spawnType = o50_SpawnMelee;
            else
                spawnType = o50_SpawnRange;
            
            if (currTerrain == MOUNTAIN)
            {
                if (p == attackPlayer)
                    spawnType = o50_SpawnRange;
                
                if (p == defendPlayer)
                    spawnType = o50_SpawnMelee;
            }
            
            var totalSpawnPoints = instance_number(spawnType);
            var loopCount = 0;
            var spawnPt;
            
            while (true)
            {
                var inst = scrIRandom(totalSpawnPoints) - 1;
                spawnPt = instance_find(spawnType, inst);
                
                if (verify(spawnPt))
                {
                    if (spawnPt.used == false)
                    {
                        if (p == 1 && spawnPt.x <= (terrainX + 192))
                            break;
                        
                        if (p == 2 && spawnPt.x > (terrainX + 192))
                            break;
                    }
                }
                
                loopCount++;
                
                if (loopCount > (totalSpawnPoints * 5))
                    break;
            }
            
            if (verify(spawnPt))
            {
                var newUnit = instance_create(spawnPt.x, spawnPt.y, UNIT_OBJECTS[i]);
                
                with (newUnit)
                {
                    if (p == 2)
                        faceDirection = -1;
                    
                    if (p == other.defendPlayer && other.surpriseAttack)
                        faceDirection *= -1;
                    
                    team = p;
                    
                    if (p == other.attackPlayer)
                        role = ATTACKER;
                    else
                        role = DEFENDER;
                }
                
                spawnPt.used = true;
                unitsPlaced++;
                unitsToPlace[i]--;
            }
            
            var spawnStillAvail = false;
            
            with (spawnType)
            {
                if (used == false)
                {
                    if (p == 1 && x <= (other.terrainX + 192))
                        spawnStillAvail = true;
                    
                    if (p == 2 && x > (other.terrainX + 192))
                        spawnStillAvail = true;
                }
            }
            
            if (!spawnStillAvail)
                break;
        }
        
        for (i = 0; i < NUM_UNITS; i++)
            extraUnits[p][i] = unitsToPlace[i];
    }
    
    for (var i = 0; i < NUM_UNITS; i++)
    {
        attackers[i] = 0;
        defenders[i] = 0;
        attackRunners[i] = 0;
        defendRunners[i] = 0;
    }
    
    with (o50_Building)
        instance_destroy();
    
    with (o50_BuildingSpawn)
        used = false;
    
    for (var i = 0; i < NUM_BUILDINGS; i++)
    {
        var totalSpawnPoints = instance_number(o50_BuildingSpawn);
        
        for (var numBuildingsHere = defendLoc.buildings[i]; numBuildingsHere; numBuildingsHere--)
        {
            var loopCount = 0;
            var inst = 0;
            var spawnPt;
            
            while (true)
            {
                spawnPt = instance_find(o50_BuildingSpawn, inst);
                
                if (verify(spawnPt))
                {
                    if (spawnPt.used == false)
                    {
                        if (defendPlayer == 1 && spawnPt.x <= (terrainX + 192))
                            break;
                        
                        if (defendPlayer == 2 && spawnPt.x > (terrainX + 192))
                            break;
                    }
                }
                
                inst++;
                
                if (inst >= totalSpawnPoints)
                    inst = 0;
                
                loopCount++;
                
                if (loopCount > (totalSpawnPoints * 5))
                    break;
            }
            
            if (verify(spawnPt))
            {
                var newBuilding = instance_create(spawnPt.x, spawnPt.y, BLD_OBJECTS[i]);
                spawnPt.used = true;
            }
        }
    }
    
    for (var p = 1; p <= 2; p++)
    {
        if (global.attractMode)
        {
            currOrder[p] = ORDER_ATTACK;
            orderSel[p] = ORDER_ATTACK;
            
            if (p != attackPlayer && surpriseAttack)
            {
                currOrder[p] = ORDER_NONE;
                orderSel[p] = ORDER_ATTACK;
            }
        }
        else if (p == attackPlayer)
        {
            currOrder[p] = ORDER_ATTACK;
            orderSel[p] = ORDER_ATTACK;
        }
        else if (surpriseAttack)
        {
            currOrder[p] = ORDER_NONE;
            orderSel[p] = ORDER_ATTACK;
        }
        else if (p == defendPlayer && defendLoc.terrain == p)
        {
            currOrder[p] = ORDER_HOLD;
            orderSel[p] = ORDER_HOLD;
        }
        else
        {
            currOrder[p] = ORDER_ATTACK;
            orderSel[p] = ORDER_ATTACK;
        }
        
        orderFlicker[p] = 0;
    }
    
    mp_grid_clear_all(mapGrid);
    
    for (var i = 0; i < COMBAT_GRID_X; i++)
    {
        for (var j = 0; j < COMBAT_GRID_Y; j++)
        {
            var hereX = COMBAT_LEFT + terrainX + (COMBAT_RES * i);
            var hereY = COMBAT_TOP + (COMBAT_RES * j);
            
            if (position_meeting(hereX, hereY, o50__ObstacleNoPlat) || position_meeting(hereX + 4, hereY, o50__ObstacleNoPlat) || position_meeting(hereX, hereY + 4, o50__ObstacleNoPlat) || position_meeting(hereX + 4, hereY + 4, o50__ObstacleNoPlat))
            {
                mp_grid_add_cell(mapGrid, i, j);
            }
            else if (position_meeting(hereX, hereY, o50__SideHigh) || position_meeting(hereX + 4, hereY, o50__SideHigh) || position_meeting(hereX, hereY + 4, o50__SideHigh) || position_meeting(hereX + 4, hereY + 4, o50__SideHigh))
            {
                mp_grid_add_cell(mapGrid, i, j);
            }
            else
            {
                var numLow = 0;
                
                if (scr50_GetElevation(hereX, hereY) == 0)
                    numLow++;
                
                if (scr50_GetElevation(hereX + 4, hereY) == 0)
                    numLow++;
                
                if (scr50_GetElevation(hereX, hereY + 4) == 0)
                    numLow++;
                
                if (scr50_GetElevation(hereX + 4, hereY + 4) == 0)
                    numLow++;
                
                var numHigh = 0;
                
                if (scr50_GetElevation(hereX, hereY) == 2)
                    numHigh++;
                
                if (scr50_GetElevation(hereX + 4, hereY) == 2)
                    numHigh++;
                
                if (scr50_GetElevation(hereX, hereY + 4) == 2)
                    numHigh++;
                
                if (scr50_GetElevation(hereX + 4, hereY + 4) == 2)
                    numHigh++;
                
                if (numHigh > 0 && numLow >= 2)
                    mp_grid_add_cell(mapGrid, i, j);
            }
        }
    }
    
    if (!global.attractMode && defenderCounter > 0)
        scrBGM(bgm50_battle);
}

if (subState == 2)
{
    if (scrTransitionDone())
    {
        subState = 3;
        
        for (var p = 1; p <= 2; p++)
        {
            with (o50__Unit)
            {
                if (team == p)
                {
                    goal = -4;
                    orders = other.currOrder[p];
                }
            }
        }
    }
}

if (subState == 3)
{
    mp_grid_clear_all(pathGrid);
    
    for (var i = 0; i < COMBAT_GRID_X; i++)
    {
        for (var j = 0; j < COMBAT_GRID_Y; j++)
        {
            if (mp_grid_get_cell(mapGrid, i, j) == -1)
                mp_grid_add_cell(pathGrid, i, j);
        }
    }
    
    mp_grid_clear_all(flightGrid);
    
    if (!surpriseAttack)
    {
        with (o50__Unit)
        {
            if (orders == ORDER_NONE && scrIRandomRange(1, other.wakeupTimer) == 1)
            {
                if (other.currOrder[team] == ORDER_NONE)
                    orders = ORDER_ATTACK;
                else
                    orders = other.currOrder[team];
            }
        }
        
        wakeupTimer = max(1, wakeupTimer - 1);
    }
    
    for (var p = 1; p <= 2; p++)
    {
        var inp = p - 1;
        
        if (orderFlicker[p])
            orderFlicker[p]--;
        
        retreatAvail = true;
        
        if (p == defendPlayer && retreatLoc == -4)
            retreatAvail = false;
        
        if (retreatAvail)
            maxOrder = 4;
        else
            maxOrder = 3;
        
        if (p != attackPlayer && surpriseAttack)
        {
            bPressLeft[inp] = false;
            bPressRight[inp] = false;
            bFire2Pressed[inp] = false;
        }
        else
        {
            if ((p > numPlayers || aiVersus) && !global.attractMode)
            {
                bPressLeft[inp] = false;
                bPressRight[inp] = false;
                bFire2Pressed[inp] = false;
                currTeam = p;
                event_user(15);
            }
            
            if (!global.attractMode)
            {
                if (bPressLeft[inp])
                {
                    scr50_Sfx(soundBattleNavi, 60);
                    orderSel[p]--;
                    
                    if (orderSel[p] < 1)
                        orderSel[p] = maxOrder;
                }
                
                if (bPressRight[inp])
                {
                    scr50_Sfx(soundBattleNavi, 60);
                    orderSel[p]++;
                    
                    if (orderSel[p] > maxOrder)
                        orderSel[p] = 1;
                }
                
                if (bFire2pressed[inp] && currOrder[p] != orderSel[p])
                {
                    scr50_Sfx(soundBattleSelect, 65);
                    currOrder[p] = orderSel[p];
                    orderFlicker[p] = 40;
                    
                    with (o50__Unit)
                    {
                        if (team == p && orders != ORDER_NONE)
                        {
                            goal = -4;
                            orders = other.currOrder[p];
                        }
                    }
                }
            }
        }
    }
    
    var totalP1Units = 0;
    var totalP2Units = 0;
    
    with (o50__Unit)
    {
        if (team == 1)
            totalP1Units++;
        else
            totalP2Units++;
    }
    
    willSpawn[1] = false;
    willSpawn[2] = false;
    
    for (var i = 0; i < NUM_UNITS; i++)
    {
        if (extraUnits[1][i] > 0 && currOrder[1] != ORDER_FLEE && totalP1Units < (UNIT_MAX_ALL / 2))
            willSpawn[1] = true;
        
        if (extraUnits[2][i] > 0 && currOrder[2] != ORDER_FLEE && totalP2Units < (UNIT_MAX_ALL / 2))
            willSpawn[2] = true;
    }
    
    for (var p = 1; p <= 2; p++)
    {
        if (willSpawn[p])
        {
            var typeToSpawn = scrIRandomRange(0, NUM_UNITS - 1);
            
            repeat (5)
            {
                if (extraUnits[p][typeToSpawn])
                {
                    var loops = 0;
                    var spawnX, spawnY;
                    
                    do
                    {
                        if (p == 1)
                            spawnX = camera_get_view_x(view_get_camera(0)) + COMBAT_LEFT + 4;
                        else
                            spawnX = (camera_get_view_x(view_get_camera(0)) + COMBAT_RIGHT) - 4;
                        
                        spawnY = scrIRandomRange(COMBAT_TOP + 4, COMBAT_BOTTOM - 8);
                        spawnY = scrQuantize(spawnY, 4);
                        loops++;
                        
                        if (loops >= 40)
                            break;
                    }
                    until (!scr50_ObstacleCheck(spawnX - 3, spawnY - 3, spawnX + 4, spawnY + 4, false, false));
                    
                    if (loops < 40)
                    {
                        var newUnit = instance_create(spawnX, spawnY, UNIT_OBJECTS[typeToSpawn]);
                        
                        with (newUnit)
                        {
                            faceDirection = 1;
                            team = p;
                            
                            if (other.attackPlayer == p)
                                role = ATTACKER;
                            else
                                role = DEFENDER;
                            
                            orders = other.currOrder[p];
                        }
                        
                        extraUnits[p][typeToSpawn]--;
                        break;
                    }
                    else
                    {
                        break;
                    }
                }
                
                typeToSpawn++;
                
                if (typeToSpawn >= NUM_UNITS)
                    typeToSpawn = 0;
            }
        }
    }
    
    stalemateTimer++;
    combatTimer++;
    var attackUnits = 0;
    var defendUnits = 0;
    
    with (o50__Unit)
    {
        if (role == ATTACKER)
            attackUnits++;
        else
            defendUnits++;
    }
    
    for (var i = 0; i < NUM_UNITS; i++)
    {
        if (currOrder[attackPlayer] != ORDER_FLEE)
            attackUnits += extraUnits[attackPlayer][i];
        
        if (currOrder[defendPlayer] != ORDER_FLEE)
            defendUnits += extraUnits[defendPlayer][i];
    }
    
    for (var i = 0; i < NUM_BUILDINGS; i++)
        defendLoc.buildings[i] = instance_number(BLD_OBJECTS[i]);
    
    if (attackUnits > 0 && defendUnits == 0)
    {
        combatWinner = ATTACKER;
        
        with (o50__Unit)
            other.attackers[type]++;
        
        subState = 4;
    }
    else if (attackUnits == 0 || stalemateTimer >= 1500)
    {
        combatWinner = DEFENDER;
        
        with (o50__Unit)
        {
            if (role == ATTACKER)
                o50_Game.attackRunners[type]++;
            
            if (role == DEFENDER)
                o50_Game.defenders[type]++;
        }
        
        subState = 4;
    }
    
    with (o50__Unit)
        event_user(0);
}

if (subState == 4)
{
    with (o50__Unit)
        event_user(0);
    
    if (stateTimer == 0)
    {
        if (!global.attractMode)
        {
            muteBGM();
            ingameMusicPlaying = false;
            scrSfx(soundBattleOver, 79);
        }
    }
    
    stateTimer++;
    
    if (stateTimer >= 180)
    {
        if (!global.attractMode)
            scrSfx(soundBattleTransition, 80);
        
        scrTransition(14, 32, 0, -10, false);
        subState = 5;
        
        if (currOrder[attackPlayer] != ORDER_FLEE)
        {
            for (var i = 0; i < NUM_UNITS; i++)
                attackers[i] += extraUnits[attackPlayer][i];
        }
        else
        {
            for (var i = 0; i < NUM_UNITS; i++)
                attackRunners[i] += extraUnits[attackPlayer][i];
        }
        
        if (currOrder[defendPlayer] != ORDER_FLEE)
        {
            for (var i = 0; i < NUM_UNITS; i++)
                defenders[i] += extraUnits[defendPlayer][i];
        }
        else
        {
            for (var i = 0; i < NUM_UNITS; i++)
                defendRunners[i] += extraUnits[defendPlayer][i];
        }
    }
}

if (subState == 5)
{
    if (scrTransitionDone())
    {
        if (!global.attractMode)
            futureState = STATE_END_COMBAT;
        else
            scrExitToTitleScreen();
    }
}
