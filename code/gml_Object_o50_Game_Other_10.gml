if (subState == 0)
{
    scrBGM(bgm50_intro);
    subState = 1;
    var obj = instance_create(camera_get_view_x(view_get_camera(0)), camera_get_view_y(view_get_camera(0)), oDCut);
    
    with (obj)
    {
        image = s50_CutIntro;
        imageEnd = 4;
        imageLen[0] = 1;
        imageLen[1] = 1;
        imageLen[2] = 1;
        imageLen[3] = 1;
        
        if (global.attractMode)
            autoPlay = true;
        
        var getStr = scrStringSplit("intro_1", 42, 3);
        str1[0] = getStr[0];
        str2[0] = getStr[1];
        str3[0] = getStr[2];
        getStr = scrStringSplit("intro_2", 42, 3);
        str1[1] = getStr[0];
        str2[1] = getStr[1];
        str3[1] = getStr[2];
        getStr = scrStringSplit("intro_3", 42, 3);
        str1[2] = getStr[0];
        str2[2] = getStr[1];
        str3[2] = getStr[2];
        getStr = scrStringSplit("intro_4", 42, 3);
        str1[3] = getStr[0];
        str2[3] = getStr[1];
        str3[3] = getStr[2];
    }
}

if (subState == 1)
{
    if (!ver(oDCut))
    {
        muteBGM();
        ingameMusicPlaying = false;

        with (oDCut)
            instance_destroy();
        
        with (oTextBox)
            instance_destroy();
        
        subState = 2;
    }
}

if (subState == 2)
{
    if (stateTimer++ >= 30)
        futureState = STATE_SCENARIO_SELECT;
}
