state("GoriCuddlyCarnage-Win64-Shipping"){}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
        vars.Helper.GameName = "Gori: Cuddly Carnage";
    if (timer.CurrentTimingMethod == TimingMethod.RealTime)
    {
        var timingMessage = MessageBox.Show 
        (
            "This game uses Time without Loads (Game Time) as the main timing method.\n"+
            "\n" +
            "LiveSplit is currently set to show Real Time (RTA).\n" +
            "\n" +
            "Would you like to set the timing method to Game Time?",
            "LiveSplit | Gori: Cuddly Carnage",
            MessageBoxButtons.YesNo, MessageBoxIcon.Question
        );

        if (timingMessage == DialogResult.Yes)
            timer.CurrentTimingMethod = TimingMethod.GameTime;
    }

    settings.Add("levels", false, "Individual Level Timer");
    settings.Add("Chapters", true, "Chapter Splits");
        settings.Add("ch_01", true, "Chapter 1", "Chapters");
        settings.Add("ch_02", true, "Chapter 2", "Chapters");
        settings.Add("ch_03", true, "Chapter 3", "Chapters");
        settings.Add("ch_04", true, "Chapter 4", "Chapters");
        settings.Add("ch_05", true, "Chapter 5", "Chapters");
        settings.Add("ch_06", true, "Chapter 6", "Chapters");
        settings.Add("ch_07", true, "Chapter 7", "Chapters");
        settings.Add("ch_08", true, "Chapter 8", "Chapters");
    settings.Add("reset", true, "Reset");
}

init
{
    var gWorld = vars.Helper.ScanRel(3, "48 8B 05 ???????? 48 3B C? 48 0F 44 C? 48 89 05 ???????? E8");
    if (gWorld == IntPtr.Zero)
        throw new InvalidOperationException("GWorld not yet found.");

    vars.Helper["LevelID"] = vars.Helper.Make<int>(gWorld, 0x1B8, 0x1E8);
    vars.Helper["LevelTime"] = vars.Helper.Make<float>(gWorld, 0x1B8, 0x1e0, 0x298, 0x14c);
    vars.Helper["IsInIntro"] = vars.Helper.Make<bool>(gWorld, 0x1B8, 0x274);
    vars.Helper["IsInMenu"] = vars.Helper.Make<bool>(gWorld, 0x1B8, 0x273);
    vars.Helper["IsLoading"] = vars.Helper.Make<byte>(gWorld, 0x1B8, 0x298, 0xE1);
    vars.Helper["InCutscene"] = vars.Helper.Make<bool>(gWorld, 0x1b8, 0x38, 0x0, 0x30, 0x338, 0x20B0);

    vars.Helper["ch1Time"] = vars.Helper.Make<float>(gWorld, 0x1B8, 0x1E0, 0x2A0, 0xE0, 0x4);
    vars.Helper["ch2Time"] = vars.Helper.Make<float>(gWorld, 0x1B8, 0x1E0, 0x2A0, 0xE0, 0x34);
    vars.Helper["ch3Time"] = vars.Helper.Make<float>(gWorld, 0x1B8, 0x1E0, 0x2A0, 0xE0, 0x64);
    vars.Helper["ch4Time"] = vars.Helper.Make<float>(gWorld, 0x1B8, 0x1E0, 0x2A0, 0xE0, 0x94);
    vars.Helper["ch5Time"] = vars.Helper.Make<float>(gWorld, 0x1B8, 0x1E0, 0x2A0, 0xE0, 0xc4);
    vars.Helper["ch6Time"] = vars.Helper.Make<float>(gWorld, 0x1B8, 0x1E0, 0x2A0, 0xE0, 0xf4);
    vars.Helper["ch7Time"] = vars.Helper.Make<float>(gWorld, 0x1B8, 0x1E0, 0x2A0, 0xE0, 0x124);
    vars.Helper["ch8Time"] = vars.Helper.Make<float>(gWorld, 0x1B8, 0x1E0, 0x2A0, 0xE0, 0x154);

    vars.Helper["LoactionX"] = vars.Helper.Make<double>(gWorld, 0x1b8, 0x38, 0x0 , 0x30, 0x338, 0x328, 0x128);
    vars.Helper["LoactionY"] = vars.Helper.Make<double>(gWorld, 0x1b8, 0x38, 0x0 , 0x30, 0x338, 0x328, 0x130);
    vars.Helper["LoactionZ"] = vars.Helper.Make<double>(gWorld, 0x1b8, 0x38, 0x0 , 0x30, 0x338, 0x328, 0x138);


}

update{
    vars.Helper.Update();
    vars.Helper.MapPointers();
}

start
{
    if(settings["levels"])
    {
        //set timer to negative value
        return (current.LevelID != 1 && current.IsLoading < 32 && old.IsLoading >= 32);
    }
    return (current.LevelTime != 0 && current.ch1Time < 1 && current.LevelID == 3);
}

split
{
    if (old.ch1Time != current.ch1Time && settings["ch_01"])
        return true;
    if (old.ch2Time != current.ch2Time && settings["ch_02"])
        return true;
    if (old.ch3Time != current.ch3Time && settings["ch_03"])
        return true;
    if (old.ch4Time != current.ch4Time && settings["ch_04"])
        return true;
    if (old.ch5Time != current.ch5Time && settings["ch_05"])
        return true;
    if (old.ch6Time != current.ch6Time && settings["ch_06"])
        return true;
    if (old.ch7Time != current.ch7Time && settings["ch_07"])
        return true;

    //final split dumb dumb split, make better please somehow
    if  (current.ch8Time == 0 && 
        (current.InCutscene) && 
        (current.LevelID == 10) && 
        (settings["ch_08"]) &&
        (current.LoactionX > 11000 && current.LoactionX < 300000) && 
        (current.LoactionY > -11000 && current.LoactionY < -5000) && 
        (current.LoactionZ > 2000 && current.LoactionZ < 6000))
            return true;

}

gameTime{
    if(settings["levels"])
        return TimeSpan.FromSeconds(current.LevelTime);
}

isLoading
{
    //set is loading all the time if levels is enabled, otherwise do normal load removal
    return (current.IsLoading >= 32) || settings["levels"];
}

reset
{
    return (current.IsLoading >= 32 && settings["levels"]) || (current.IsInMenu && settings["reset"]);
}

exit
{
    timer.IsGameTimePaused = true;
}
