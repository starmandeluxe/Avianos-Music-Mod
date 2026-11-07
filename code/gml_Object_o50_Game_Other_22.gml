if (subState == 0)
{
    scrBGM(bgm50_intro);
    subState = 1;
    var obj = instance_create(camera_get_view_x(view_get_camera(0)), camera_get_view_y(view_get_camera(0)), oDCut);
    
    with (obj)
    {
        image = s50_CutEnding;
        imageEnd = 3;
        imageLen[0] = 1;
        imageLen[1] = 2;
        imageLen[2] = 1;
        var getStr = scrStringSplit("ending_1", 42, 3);
        str1[0] = getStr[0];
        str2[0] = getStr[1];
        str3[0] = getStr[2];
        getStr = scrStringSplit("ending_2", 42, 3);
        str1[1] = getStr[0];
        str2[1] = getStr[1];
        str3[1] = getStr[2];
        getStr = scrStringSplit("ending_3", 42, 3);
        str1[2] = getStr[0];
        str2[2] = getStr[1];
        str3[2] = getStr[2];
        getStr = scrStringSplit("ending_4", 42, 3);
        str1[3] = getStr[0];
        str2[3] = getStr[1];
        str3[3] = getStr[2];
    }
}

if (subState == 1)
{
    if (!ver(oDCut))
        subState = 2;
}

if (subState == 2)
{
    subState = 3;
    var obj = instance_create(camera_get_view_x(view_get_camera(0)), camera_get_view_y(view_get_camera(0)), oDCut);
    
    with (obj)
    {
        yShift = 48;
        style = 3;
        fontType = 1;
        fontHeight = 16;
        textAdvance = 3;
        scrollLines = 33;
        scrollMax = scrollLines;
        
        for (var n = 0; n < scrollLines; n++)
            strScroll[n] = scrStringManual("game_credits_50_" + string(n + 1), 0);
    }
}
else if (subState == 3)
{
    if (!ver(oDCut))
        subState = 4;
}
else if (subState == 4)
{
    if (fire2pressed)
    {
        muteBGM();
        ingameMusicPlaying = false;
        futureState = STATE_SCENARIO_SELECT;
    }
}
