state("gambatte") {}
state("gambatte_qt") {}

startup
{
    //-------------------------------------------------------------//
    settings.Add("battles", true, "Battles");
    settings.Add("other", true, "Other");
    settings.Add("nsc", true, "NSC Only");

    settings.CurrentDefaultParent = "battles";
    settings.Add("nidoran", true, "Catch 2nd Pokemon (Nidoran/Spearow)");
    settings.Add("silphGiovanni", true, "Silph Co. (Giovanni)");
    settings.Add("nuggetBridge", true, "Nugget Bridge (Rocket)");
    settings.Add("gym1", true, "Pewter Gym (Brock)");
    settings.Add("gym2", true, "Cerulean Gym (Misty)");
    settings.Add("gym3", true, "Vermilion Gym (Lt. Surge)");
    settings.Add("gym4", true, "Celadon Gym (Erika)");
    settings.Add("gym5", true, "Fuchsia Gym (Koga)");
    settings.Add("gym6", true, "Saffron Gym (Sabrina)");
    settings.Add("gym7", true, "Cinnabar Gym (Blaine)");
    settings.Add("gym8", true, "Viridian Gym (Giovanni)");
    settings.Add("elite4_1", true, "Lorelei");
    settings.Add("elite4_2", true, "Bruno");
    settings.Add("elite4_3", true, "Agatha");
    settings.Add("elite4_4", true, "Lance");
    settings.Add("elite4_5", true, "Champion");

    settings.CurrentDefaultParent = "other";
    settings.Add("rival", false, "Leave Oak's Lab (after rival fight)");
    settings.Add("enterMtMoon", true, "Enter Mt. Moon");
    settings.Add("exitMtMoon", true, "Exit Mt. Moon");
    settings.Add("exitVictoryRoad", true, "Exit Victory Road");
    settings.Add("hm02", true, "Obtain HM02");
    settings.Add("flute", true, "Obtain Poké Flute");
    settings.Add("hofGlitchless", true, "HoF Fade Out (Glitchless)");

    settings.CurrentDefaultParent = "nsc";
    settings.Add("deathfly", false, "Deathfly");
    settings.Add("bc1", false, "Bug Catcher #1");
    settings.Add("bc2", false, "Bug Catcher #2");
    settings.Add("bc3", false, "Bug Catcher #3");
    settings.Add("hofNSC", false, "HoF Fade Out (NSC)");
    //-------------------------------------------------------------//

    vars.stopwatch = new Stopwatch();

    vars.timer_OnStart = (EventHandler)((s, e) =>
    {
        vars.splits = vars.GetSplitList();
    });
    timer.OnStart += vars.timer_OnStart;

    vars.TryFindOffsets = (Func<Process, bool>)((proc) => 
    {
        print("[Autosplitter] Scanning memory");
        var target = new SigScanTarget(0, "20 ?? ?? ?? 20 ?? ?? ?? 20 ?? ?? ?? 20 ?? ?? ?? 05 00 00");

        int scanOffset = 0;
        foreach (var page in proc.MemoryPages())
        {
            var scanner = new SignatureScanner(proc, page.BaseAddress, (int)page.RegionSize);
            if ((scanOffset = (int)scanner.Scan(target)) != 0)
                break;
        }

        if (scanOffset != 0)
        {
            var wramOffset = scanOffset - 0x10;
            print("[Autosplitter] WRAM Pointer: " + wramOffset.ToString("X8"));

            vars.watchers = vars.GetWatcherList((int)(wramOffset - 0x400000));
            vars.stopwatch.Reset();

            return true;
        }
        else
            vars.stopwatch.Restart();

        return false;
    });

    vars.GetWatcherList = (Func<int, MemoryWatcherList>)((wramOffset) =>
    {   
        return new MemoryWatcherList
        {
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x0001)) { Name = "soundID" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x0C26)) { Name = "cursorIndex" },
            new MemoryWatcher<ushort>(new DeepPointer(wramOffset, 0x0C30)) { Name = "cursorPos" },
            new MemoryWatcher<uint>(new DeepPointer(wramOffset, 0x0D40)) { Name = "hofPlayerShown" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x0FD8)) { Name = "enemyPkmn" },
            new MemoryWatcher<uint>(new DeepPointer(wramOffset, 0x0FDA)) { Name = "enemyPkmnName" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x1016)) { Name = "pkmnHP" },
            new MemoryWatcher<uint>(new DeepPointer(wramOffset, 0x104A)) { Name = "opponentName" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x1163)) { Name = "partyCount" },
            new MemoryWatcher<ushort>(new DeepPointer(wramOffset, 0x117A)) { Name = "pkmnEXP" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x135E)) { Name = "mapIndex" },
            new MemoryWatcher<ushort>(new DeepPointer(wramOffset, 0x1361)) { Name = "playerPos" },
            new MemoryWatcher<ushort>(new DeepPointer(wramOffset, 0x1FD7)) { Name = "hofFade" },
            new MemoryWatcher<ushort>(new DeepPointer(wramOffset, 0x1FFD)) { Name = "stack" },
            new MemoryWatcher<ushort>(new DeepPointer(wramOffset, 0x1FBF)) { Name = "stack2" },
        };
    });

    vars.GetSplitList = (Func<Dictionary<string, Dictionary<string, uint>>>)(() =>
    {
        return new Dictionary<string, Dictionary<string, uint>>
        {
            { "nidoran", new Dictionary<string, uint> { { "partyCount", 2u }, { "stack", 0x03AEu } } },
            { "nuggetBridge", new Dictionary<string, uint> { { "opponentName", 0x8A828E91 }, { "mapIndex", 0x23u }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } },
            { "silphGiovanni", new Dictionary<string, uint> { { "opponentName", 0x958E8886 }, { "mapIndex", 0xEBu }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } },
            { "gym1", new Dictionary<string, uint> { { "opponentName", 0x828E9181 }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } },
            { "gym2", new Dictionary<string, uint> { { "opponentName", 0x9392888C }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } },
            { "gym3", new Dictionary<string, uint> { { "opponentName", 0x92E8938B }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } },
            { "gym4", new Dictionary<string, uint> { { "opponentName", 0x8A889184 }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } },
            { "gym5", new Dictionary<string, uint> { { "opponentName", 0x80868E8A }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } },
            { "gym6", new Dictionary<string, uint> { { "opponentName", 0x91818092 }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } },
            { "gym7", new Dictionary<string, uint> { { "opponentName", 0x88808B81 }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } },
            { "gym8", new Dictionary<string, uint> { { "opponentName", 0x958E8886 }, { "mapIndex", 0x2Du }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } },
            { "elite4_1", new Dictionary<string, uint> { { "opponentName", 0x84918E8B }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } }, //{ "mapIndex", 0xF5u }
            { "elite4_2", new Dictionary<string, uint> { { "opponentName", 0x8D949181 }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } }, //{ "mapIndex", 0xF6u }
            { "elite4_3", new Dictionary<string, uint> { { "opponentName", 0x93808680 }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } }, //{ "mapIndex", 0xF7u }
            { "elite4_4", new Dictionary<string, uint> { { "opponentName", 0x828D808B }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } }, //{ "mapIndex", 0x71u }
            { "elite4_5", new Dictionary<string, uint> { { "enemyPkmnName", 0x948D8495 }, { "mapIndex", 0x78u }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } },

            { "rival", new Dictionary<string, uint> { { "mapIndex", 0u }, { "partyCount", 1u } } },
            { "enterMtMoon", new Dictionary<string, uint> { { "mapIndex", 0x3Bu }, { "playerPos", 0x0E23u } } },
            { "exitMtMoon", new Dictionary<string, uint> { { "mapIndex", 0x0Fu }, { "playerPos", 0x1805u } } },
            { "exitVictoryRoad", new Dictionary<string, uint> { { "mapIndex", 0x22u }, { "playerPos", 0x0E1Fu } } },
            { "hm02", new Dictionary<string, uint> { { "soundID", 0x94u }, { "mapIndex", 0xBCu } } },
            { "flute", new Dictionary<string, uint> { { "soundID", 0x94u }, { "mapIndex", 0x95u } } },
            { "hofGlitchless", new Dictionary<string, uint> { { "mapIndex", 0x76u }, { "hofPlayerShown", 1u }, { "hofFade", 0x0108u } } },

            { "deathfly", new Dictionary<string, uint> { { "mapIndex", 0x33u }, { "playerPos", 0x0112u }, { "pkmnHP", 0u }, { "stack", 0x0939u } } },
            { "bc1", new Dictionary<string, uint> { { "pkmnEXP", 0xE000u }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } },
            { "bc2", new Dictionary<string, uint> { { "pkmnEXP", 0x4301u }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } },
            { "bc3", new Dictionary<string, uint> { { "mapIndex", 0x33u }, { "playerPos", 0x1D21u }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } },
            { "hofNSC", new Dictionary<string, uint> { { "mapIndex", 0x76u }, { "hofPlayerShown", 1u }, { "stack2", 0x0108u } } },
        };
    });
}

init
{
    vars.watchers = new MemoryWatcherList();
    vars.splits = new Dictionary<string, Dictionary<string, uint>>();

    vars.stopwatch.Restart();
}

update
{
    if (vars.stopwatch.ElapsedMilliseconds > 1500)
	{
        if (!vars.TryFindOffsets(game))
            return false;
	}
    else if (vars.watchers.Count == 0)
        return false;
    
    vars.watchers.UpdateAll(game);
}

start
{
    return vars.watchers["cursorIndex"].Current == 0 && vars.watchers["stack"].Current == 0x5B91;
}

reset
{
    return vars.watchers["cursorPos"].Current == 0xC477 && vars.watchers["soundID"].Current == 0x90;
}

split
{
    foreach (var _split in vars.splits)
    {
        if (settings[_split.Key])
        {
            var count = 0;
            foreach (var _condition in _split.Value)
            {
                if (vars.watchers[_condition.Key].Current == _condition.Value)
                    count++;
            }

            if (count == _split.Value.Count)
            {
                print("[Autosplitter] Split: " + _split.Key);
                vars.splits.Remove(_split.Key);
                return true;
            }
        }
    }
}

shutdown
{
    timer.OnStart -= vars.timer_OnStart;
}