; ╔═════════════════════════════════════════╗
; ║        MHI - FH6 Wheelspin Macro		║
; ║        Cyber Noir Edition v1.4.0        ║
; ╚═════════════════════════════════════════╝

#Requires AutoHotkey v2.0

#Include Engine.ahk

; ══════════════════════════════════════════════
;  PALETTE COMPOSER
; ══════════════════════════════════════════════
GetPalette() {
    global DarkMode
    p := Map()

    if DarkMode {
        p["bg"]       := "0B0F14"
        p["panel"]    := "111826"
        p["accent"]   := "00E5FF"
        p["accent2"]  := "7C4DFF"
        p["text"]     := "E6F1FF"
        p["textDim"]  := "6B7C93"
        p["editBg"]   := "0F1624"
        p["btnBg"]    := "111826"
        p["btnText"]  := "00E5FF"
        p["btnBg2"]   := "0C1320"
        p["btnText2"] := "6B7C93"
        p["divider"]  := "1F2A3A"
        p["cActive"]    := "00E5FF"
        p["cHighlight"] := "39FF14"
        p["cPaused"]     := "FFD54F"
        p["cIdle"]      := "6B7C93"
        p["cTextDim"]   := "6B7C93"
        p["footer"]     := "1F2A3A"
        p["header"]     := "4289B6"
    } else {
        p["bg"]       := "F5F7FA"
        p["panel"]    := "E8EEF5"
        p["accent"]   := "0066FF"
        p["accent2"]  := "7C4DFF"
        p["text"]     := "0B1220"
        p["textDim"]  := "4B5B73"
        p["editBg"]   := "FFFFFF"
        p["btnBg"]    := "DCE8FF"
        p["btnText"]  := "003A99"
        p["btnBg2"]   := "CFE0FF"
        p["btnText2"] := "4B5B73"
        p["divider"]  := "C9D6E5"
        p["cActive"]    := "0066FF"
        p["cHighlight"] := "1DB954"
        p["cPaused"]    := "C68400"
        p["cIdle"]      := "4B5B73"
        p["cTextDim"]   := "4B5B73"
        p["footer"]     := "C9D6E5"
        p["header"]     := "4289B6"
    }
    return p
}

; ══════════════════════════════════════════════
;  INTERFACE GENERATION ENGINE
; ══════════════════════════════════════════════
BuildGui(savedVals := "") {
    global MyGui, StatusText, PointsCount_UI, CarCount_UI, SWheelCount_UI, WheelCount_UI, CreditCount_UI
    global TotalRunTime_UI, RaceRunTime_UI, BuyRunTime_UI, UnlockRunTime_UI, SectorCount_UI
    global PointsLabel_UI, TimeLabel_UI, CarsLabel_UI, CodeSelect_UI, DelaySlider_UI, SpeedLabel_UI, SectorLabel_UI
    global Key_UI, Process_UI, CodeTune_UI, CodeEventLab_UI, CarSelect_UI, PremiumCheck_UI
    global SkillPtsCount_In, SkillPtsWant_In, CarCount_In, LoopCount_In, AveragePoints, MaxPoints, PointsTotal, PointsGain, TimeTotal
    global ActiveMode, DarkMode, cActive, cHighlight, cIdle, cTextDim, cPaused, cStat, SectorCount, CodeEventLab, CodeTune

    p := GetPalette()
    cActive    := p["cActive"]
    cHighlight := p["cHighlight"]
    cIdle      := p["cIdle"]
    cTextDim   := p["cTextDim"]
    cPaused    := p["cPaused"]
    cStat      := ActiveMode ? p["accent"] : p["textDim"]
    sLabel     := ActiveMode ? "⬤   Running..." : "⬤   Stopped"
    
    MyGui := Gui("+AlwaysOnTop -MaximizeBox -DPIScale", "MHI | FH6 MACRO")
    MyGui.BackColor := p["bg"]

    ; ── Title Header ──────────────────────────
    SetFixedFont(MyGui, 14, "bold", "Light")
    MyGui.Add("Text", "x0 y+15 w270 Center BackgroundTrans c" p["accent"], "WHEELSPIN MACRO")
    SetFixedFont(MyGui, 7, "norm")
    MyGui.Add("Text", "x0 y+1 w270 Center BackgroundTrans c" p["textDim"], "FORZA HORIZON 6   ✦   AFK FARM")

    ; ── Status ────────────────────────────────
    SetFixedFont(MyGui, 10, "bold", "Semibold")
    StatusText := MyGui.Add("Text", "x0 y+10 w270 Center BackgroundTrans c" cStat, sLabel)

    ; ── Number Input ───────────────────────────
    SetFixedFont(MyGui, 7, "bold")
    MyGui.Add("Text", "x14 y+3  w242 Center BackgroundTrans c" p["divider"], "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    
    SetFixedFont(MyGui, 9, "norm", "Light")
    MyGui.Add("Text", "x30 y+6 w155 BackgroundTrans c" p["text"], "⟡   Current Skill Points")
    SkillPtsCount_In := MyGui.Add("Edit", "x179 yp-3 w63 Center Number Background" p["editBg"] " c" p["text"], savedVals ? savedVals[1] : 0)

    MyGui.Add("Text", "x30 y+6 w155 BackgroundTrans c" p["text"], "⟡   Desired Skill Points")
    SkillPtsWant_In := MyGui.Add("Edit", "x179 yp-3 w63 Center Number Background" p["editBg"] " c" p["text"], savedVals ? savedVals[2] : MaxPoints)

    MyGui.Add("Text", "x30 y+6 w155 BackgroundTrans c" p["text"], "⟡   Car Purchase")
    CarCount_In := MyGui.Add("Edit", "x179 yp-3 w63 Center Number Background" p["editBg"] " c" p["text"], savedVals ? savedVals[3] : Floor(MaxPoints / SelectedCarPoint))

    MyGui.Add("Text", "x30 y+6 w155 BackgroundTrans c" p["text"], "⟡   Sequence Loop")
    LoopCount_In := MyGui.Add("Edit", "x179 yp-3 w63 Center Number Background" p["editBg"] " c" p["text"], savedVals ? savedVals[4] : 99)

    SetFixedFont(MyGui, 9, "bold")
    CarSelect_UI := MyGui.Add("DropDownList", "x55 y+10 w160 Center Choose1", ["Subaru Impreza 22B-STi", "Lamborghini Revuelto", "Dodge Viper GTS ACR"])
   
    SetFixedFont(MyGui, 9, "norm c" p["text"])
    PremiumCheck_UI := MyGui.Add("Checkbox", "y+8 0x200", "  PREMIUM    🜲")

    ; ── Calculations & Targets ────────────────
    SetFixedFont(MyGui, 9, "bold")
    MyGui.Add("Text", "x14 y+14 w242 Center BackgroundTrans c" p["header"], "TARGET")
    MyGui.Add("Text", "x14 y+0  w242 Center BackgroundTrans c" p["divider"], "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    PointsGain := GetMinScore(SkillPtsWant_In.Value)
    PointsTotal  := Min(PointsGain + SkillPtsCount_In.Value, 999)
    TimeTotal    := CalcTimeRace(SkillPtsWant_In.Value) + CalcTimeBuy(CarCount_In.Value) + CalcTimeUnlock(CarCount_In.Value)

    SetFixedFont(MyGui, 9, "norm", "Light")
    PointsLabel_UI := MyGui.Add("Text", "x14 y+5 w242 Center BackgroundTrans c" p["cIdle"], "Est. Skill Points Gain  —  " PointsGain)
    SectorLabel_UI := MyGui.Add("Text", "x14 y+2 w242 Center BackgroundTrans c" p["cIdle"], "Est. Sectors Count  —  " Ceil(PointsGain/AveragePoints))
    TimeLabel_UI   := MyGui.Add("Text", "x14 y+2 w242 Center BackgroundTrans c" p["cIdle"], "Est. Total Time Completion  —  " Format("{:02}:{:02}", Floor(TimeTotal), Round((TimeTotal - Floor(TimeTotal)) * 60)))
    CarsLabel_UI   := MyGui.Add("Text", "x14 y+2 w242 Center BackgroundTrans c" p["cIdle"], "Recommended Car Purchase  —  " Floor(PointsTotal / SelectedCarPoint))

    ; Event Bindings
    CarSelect_UI.OnEvent("Change", UpdateCar)
    SkillPtsCount_In.OnEvent("Change", UpdateSkillPts)
    SkillPtsCount_In.OnEvent("LoseFocus", ValidateSkillPts)
    SkillPtsWant_In.OnEvent("Change", UpdateSkillPtsWant)
    SkillPtsWant_In.OnEvent("LoseFocus", ValidateSkillPtsWant)

    ; ── Session Panel ─────────────────────────
    SetFixedFont(MyGui, 9, "bold")
    MyGui.Add("Text", "x14 y+10 w242 Center BackgroundTrans c" p["header"], "SESSION")
    MyGui.Add("Text", "x14 y+0  w242 Center BackgroundTrans c" p["divider"], "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    SetFixedFont(MyGui, 9, "norm", "Light")
    Key_UI          := MyGui.Add("Text", "x0 y+5 w270 Center BackgroundTrans c" p["cIdle"], "⌨  [   ]")
    Process_UI      := MyGui.Add("Text", "x0 y+2 w270 Center BackgroundTrans c" p["cIdle"], "⚙️  Waiting...")
    TotalRunTime_UI := MyGui.Add("Text", "x0 y+2 w270 Center BackgroundTrans c" p["cIdle"], "🕓  00:00")

    ; ── Progress Panel ────────────────────────
    SetFixedFont(MyGui, 9, "bold")
    MyGui.Add("Text", "x0 y+13 w270 Center BackgroundTrans c" p["header"], "PROGRESS")
    MyGui.Add("Text", "x0 y+0  w270 Center BackgroundTrans c" p["divider"], "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    SetFixedFont(MyGui, 9, "norm", "Light")
    RaceRunTime_UI   := MyGui.Add("Text", "x0 y+5 w270 Center BackgroundTrans c" p["cIdle"], "🕓   Race Time Running   —   00:00")
    PointsCount_UI   := MyGui.Add("Text", "x0 y+0 w270 Center BackgroundTrans c" p["cIdle"], "💡   Est. Skill Points Gained  —   0")
    SectorCount_UI   := MyGui.Add("Text", "x0 y+0 w270 Center BackgroundTrans c" p["cIdle"], "🏁   Sectors Completed   —   0")
    BuyRunTime_UI    := MyGui.Add("Text", "x0 y+10 w270 Center BackgroundTrans c" p["cIdle"], "🕓   Buy Time Running   —   00:00")
    CarCount_UI      := MyGui.Add("Text", "x0 y+0 w270 Center BackgroundTrans c" p["cIdle"], "🚗   Car Purchased   —   0")
    UnlockRunTime_UI := MyGui.Add("Text", "x0 y+10 w270 Center BackgroundTrans c" p["cIdle"], "🕓   Unlock Time Running   —   00:00")
    SWheelCount_UI   := MyGui.Add("Text", "x0 y+0 w270 Center BackgroundTrans c" p["cIdle"], "🛞   Super Wheelspin   —   0")
    WheelCount_UI    := MyGui.Add("Text", "x0 y+0 w270 Center BackgroundTrans c" p["cIdle"], "🛞   Wheelspin   —   0")
    CreditCount_UI   := MyGui.Add("Text", "x0 y+0 w270 Center BackgroundTrans c" p["cIdle"], "💲   Credits   —   0 CR")

    ; ── Action Buttons ────────────────────────
    MyGui.Add("Text", "x14 y+10 w242 Center BackgroundTrans c" p["divider"], "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    SetFixedFont(MyGui, 9, "bold", "Semibold")
    RaceBtn := MyGui.Add("Text", "x14 y+6 w242 h36 Center 0x200 Background" p["btnBg"] " c" p["btnText"], "🏁   RACE   —   \")
    RaceBtn.OnEvent("Click", (*) => StartRace())

    BuyBtn := MyGui.Add("Text", "x14 y+6 w119 h36 Center 0x200 Background" p["btnBg"] " c" p["btnText"], "🚗   BUY  —   [")
    BuyBtn.OnEvent("Click", (*) => StartBuy())

    UnlockBtn := MyGui.Add("Text", "x137 yp w119 h36 Center 0x200 Background" p["btnBg"] " c" p["btnText"], "🛞   UNLOCK  —   ]")
    UnlockBtn.OnEvent("Click", (*) => StartUnlock())

    AllBtn := MyGui.Add("Text", "x14 y+6 w242 h36 Center 0x200 Background" p["btnBg"] " c" p["btnText"], "⟲   INIT SEQUENCE   —   /")
    AllBtn.OnEvent("Click", (*) => ToggleAll())

    themeLabel := DarkMode ? "☀   Switch to Light Mode" : "🌙   Switch to Dark Mode"
    SetFixedFont(MyGui, 8, "norm")
    ThemeBtn := MyGui.Add("Text", "x14 y+7 w242 h26 Center 0x200 Background" p["btnBg2"] " c" p["btnText2"], themeLabel)
    ThemeBtn.OnEvent("Click", (*) => ToggleTheme())

    ; ── Footer Codes ──────────────────────────
    SetFixedFont(MyGui, 9, "norm")
    SpeedLabel_UI := MyGui.Add("Text", "x0 y+20 w270 Center", "Delay Multiplier: 1x")
    DelaySlider_UI := MyGui.Add("Slider", "x35 y+5 w200 Range1-7", 4) 
    DelaySlider_UI.OnEvent("Change", UpdateSpeed)

    SetFixedFont(MyGui, 8, "bold")
    CodeSelect_UI := MyGui.Add("DropDownList", "x85 y+5 w100 Center Choose1", ["AMMAGEDON", "LIQUIDPOTATO"])
    CodeSelect_UI.OnEvent("Change", UpdateCode)
    
    SetFixedFont(MyGui, 9, "norm", "Emoji")
    CodeTune_UI     := MyGui.Add("Text", "x0 y+5 w270 Center BackgroundTrans c" p["cIdle"], "Subaru 22B Tune Code")
    CodeEventLab_UI := MyGui.Add("Text", "x0 y+0 w270 Center BackgroundTrans c" p["cIdle"], "EventLab Race Code")

    CodeTune_UI.OnEvent("Click", (*) => (
        A_Clipboard := CodeSelect_UI.Text = "LIQUIDPOTATO" ?  "293391902" : "206657706",
        ToolTip("Subaru 22B Tune Code Copied! " CodeTune),
        SetTimer(() => ToolTip(), -2000)
    ))

    CodeEventLab_UI.OnEvent("Click", (*) => (
        A_Clipboard := CodeSelect_UI.Text = "LIQUIDPOTATO" ? "124198343" : "113938786",
        ToolTip("EventLab Race Code Copied! " CodeEventLab),
        SetTimer(() => ToolTip(), -2000)
    ))

    MyGui.Add("Link","xm+210 y+5 Right", '<a href="https://github.com/M-Haziq-Iqbal/Forza-Horizon-6-Wheelspin-Macro/releases/tag/v1.4.0">v1.4.0</a>')

; ── Positioning ──────────────────────────
    MyGui.Add("Text", "x0 y+5 w270 h1 BackgroundTrans c" p["footer"], "")
    MyGui.OnEvent("Close", (*) => ExitApp())
    MyGui.Show("w270 Hide")

    MyGui.GetClientPos(,, &guiWidth)
    PremiumCheck_UI.GetPos(,, &PremWidth)
    PremiumCheck_UI.Move((guiWidth / 2) - (PremWidth / 2))

    ; 1. Get the boundaries of the PRIMARY monitor (respects taskbars and DPI safely)
    ; If you want it on the ACTIVE window's monitor instead, use: MonitorGetWorkArea(MonitorGetFromWindow(), &Left, &Top, &Right, &Bottom)
    MonitorGetWorkArea(, &Left, &Top, &Right, &Bottom)
    
    ; 2. Calculate true monitor width and height
    monWidth := Right - Left
    monHeight := Bottom - Top

    MyGui.GetPos(,, &w, &h)
    
    ; 3. Position precisely on the right-half of that specific monitor
    x := Left + (monWidth // 2) + ((monWidth // 2) - w) // 2
    y := Top + (monHeight - h) // 2
    
    MyGui.Move(x, y)
    MyGui.Show() ; Finally, show the window at its true destination
}

ToggleTheme() {
    global DarkMode, MyGui, SkillPtsCount_In, SkillPtsWant_In, CarCount_In, ActiveMode, LoopCount_In
    saved := [SkillPtsCount_In.Value, SkillPtsWant_In.Value, CarCount_In.Value, LoopCount_In.Value]

    if ActiveMode {
        ActiveMode  := ""
        MasterMode  := ""
        MasterStart := ""
        Sleep(1250)
    }

    DarkMode := !DarkMode
    MyGui.Destroy()
    BuildGui(saved)
}

SetFixedFont(guiObject, pointSize, options := "", fontName := "Segoe UI") {

    Switch fontName
    {
        Case "Light":    fontName := "Segoe UI Light"
        Case "Semibold": fontName := "Segoe UI Semibold"
        Case "Emoji": fontName := "Segoe UI Emoji"
        Default:         fontName := "Segoe UI"
    }

    ; 1. Calculate the anti-scaling math for the size
    fixedSize := pointSize * (96 / A_ScreenDPI)
    
    ; 2. Combine the fixed size with your extra choices (bold, norm, colors, etc.)
    fullOptions := "s" . fixedSize . " " . options
    
    ; 3. Apply it
    guiObject.SetFont(fullOptions, fontName)
}