#Requires AutoHotkey v2.0
#MaxThreadsPerHotkey 2
#SingleInstance Force

; ╔═════════════════════════════════════════╗
; ║        FH6 Wheelspin Macro				║
; ║        Cyber Noir Edition v1.2.2        ║
; ╚═════════════════════════════════════════╝

global ActiveMode	:= ""
global PauseMode	:= false
global MasterMode	:= ""
global MasterStart	:= false

global DarkMode		:= true
global MyGui		:= ""
global StatusText	:= ""

global Key_UI		:= ""
global Process_UI	:= ""

global SkillPtsCount_In	:= 0
global SkillPtsWant_In	:= 0
global CarCount_In	    := 0

global cActive		:= "FF8FAB"
global cHighlight	:= "39FF14"
global cIdle		:= "7A4A60"
global cTextDim		:= "7A4A60"

global RaceCount	:= 0
global PointsCount	:= 0
global CarCount		:= 0
global UnlockCount	:= 0
global SWheelCount	:= 0
global WheelCount	:= 0
global CreditCount	:= 0

global TotalRunSeconds	:= 0
global RaceRunSeconds	:= 0
global BuyRunSeconds	:= 0
global UnlockRunSeconds	:= 0
global RaceLoadingTime	:= 52
global FinLoadingTime	:= 40

global RaceCount_UI	    := ""
global PointsCount_UI	:= ""
global CarCount_UI	    := ""
global SWheelCount_UI	:= ""
global WheelCount_UI	:= ""
global CreditCount_UI	:= ""
global CodeTune_UI	    := ""
global TotalRunTime_UI	:= ""
global RaceRunTime_UI	:= ""
global BuyRunTime_UI	:= ""
global UnlockRunTime_UI	:= ""
global CarSelect_UI	    := ""
global CarsLabel_UI	    := ""
global PointsLabel_UI	:= ""
global TimeLabel_UI	    := ""
global PixelCheck_UI    := ""
global PremiumCheck_UI  := ""

global SelectedCar      := "Subaru Impreza 22B"
global SelectedCarPoint	:= 30
global PointsTotal 	    := 0
global PointsGained 	:= 0
global TimeTotal 	    := 0
global AveragePoints 	:= 9.8
global MaxPoints 	    := 940

global GuiWidth		    := "w270"

; ══════════════════════════════════════════════
;  PALETTE HELPER
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
    } 
    else {
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
    }
    return p
}


; ══════════════════════════════════════════════
;  BUILD GUI
; ══════════════════════════════════════════════
BuildGui(savedVals := "") {
    global MyGui, StatusText, RaceCount_UI, PointsCount_UI, CarCount_UI, SWheelCount_UI, WheelCount_UI, CreditCount_UI
    global TotalRunTime_UI, RaceRunTime_UI, BuyRunTime_UI, UnlockRunTime_UI
    global PointsLabel_UI, TimeLabel_UI, CarsLabel_UI
    global Key_UI, Process_UI, CodeTune_UI, CodeEventLab_UI, CarSelect_UI, PixelCheck_UI, PremiumCheck_UI
    global SkillPtsCount_In, SkillPtsWant_In, CarCount_In, AveragePoints, MaxPoints, PointsTotal, PointsGained, TimeTotal
    global ActiveMode, DarkMode, cActive, cHighlight, cIdle, cTextDim, cPaused, cStat, RaceCount

    ; 1. Inline assignments to save vertical spacing
    p := GetPalette()
    cActive    := p["cActive"]
    cHighlight := p["cHighlight"]
    cIdle      := p["cIdle"]
    cTextDim   := p["cTextDim"]
    cPaused    := p["cPaused"]
    cStat      := ActiveMode ? p["accent"] : p["textDim"]
    sLabel     := ActiveMode ? "⬤   Running..." : "⬤   Stopped"

    MyGui := Gui("+AlwaysOnTop -MaximizeBox", "FH6 MACRO")
    MyGui.BackColor := p["bg"]

    ; ── Title Header ──────────────────────────
    MyGui.SetFont("s15", "Segoe UI Emoji")
    MyGui.SetFont("s14 bold", "Segoe UI Light")
    MyGui.Add("Text", "x0 y+15 w270 Center BackgroundTrans c" p["accent"], "WHEELSPIN MACRO")

    MyGui.SetFont("s7 norm", "Segoe UI")
    MyGui.Add("Text", "x0 y+1 w270 Center BackgroundTrans c" p["textDim"], "FORZA HORIZON 6   ✦   AFK FARM")

    ; ── Status ────────────────────────────────
    MyGui.SetFont("s10 bold", "Segoe UI Semibold")
    StatusText := MyGui.Add("Text", "x0 y+10 w270 Center BackgroundTrans c" cStat, sLabel)

    ; ── Number Input ───────────────────────────
    MyGui.SetFont("s7 bold", "Segoe UI")
    MyGui.Add("Text", "x14 y+3  w242 Center BackgroundTrans c" p["divider"], "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    
    MyGui.SetFont("s9 norm", "Segoe UI Light")
    MyGui.Add("Text", "x30 y+6 w155 BackgroundTrans c" p["text"], "⟡   Current Skill Points")
    SkillPtsCount_In := MyGui.Add("Edit", "x179 yp-3 w63 Center Number Background" p["editBg"] " c" p["text"], savedVals ? savedVals[1] : 0)

    MyGui.Add("Text", "x30 y+6 w155 BackgroundTrans c" p["text"], "⟡   Desired Skill Points")
    SkillPtsWant_In := MyGui.Add("Edit", "x179 yp-3 w63 Center Number Background" p["editBg"] " c" p["text"], savedVals ? savedVals[2] : MaxPoints)

    MyGui.Add("Text", "x30 y+6 w155 BackgroundTrans c" p["text"], "⟡   Car Purchase")
    CarCount_In := MyGui.Add("Edit", "x179 yp-3 w63 Center Number Background" p["editBg"] " c" p["text"], savedVals ? savedVals[3] : Floor(MaxPoints / SelectedCarPoint))

    MyGui.SetFont("s9 Bold", "Segoe UI")
    CarSelect_UI := MyGui.Add("DropDownList", "x55 y+10 w160 Center Choose1", ["Subaru Impreza 22B", "Lamborghini Revuelto", "Dodge Viper GTS ACR"])
   
    MyGui.SetFont("s9 norm cE6F1FF", "Segoe UI")
    ;PixelCheck_UI := MyGui.Add("Checkbox", , "  Dynamic Loading  ⏳")
    PremiumCheck_UI := MyGui.Add("Checkbox", "y+8 0x200", "  PREMIUM   👑")

    ; ── Calculations & Targets ────────────────
    MyGui.SetFont("s9 bold", "Segoe UI")
    MyGui.Add("Text", "x14 y+14 w242 Center BackgroundTrans c" p["textDim"], "TARGET")
    MyGui.Add("Text", "x14 y+0  w242 Center BackgroundTrans c" p["divider"], "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    PointsGained := GetMinScore(SkillPtsWant_In.Value)
    PointsTotal  := PointsGained + SkillPtsCount_In.Value
    TimeTotal    := CalcTimeRace(SkillPtsWant_In.Value) + CalcTimeBuy(CarCount_In.Value) + CalcTimeUnlock(CarCount_In.Value)

    MyGui.SetFont("s9 norm", "Segoe UI Light")
    PointsLabel_UI := MyGui.Add("Text", "x14 y+5 w242 Center BackgroundTrans c" p["cIdle"], "Est. Skill Points Gained  —  " PointsGained)
    TimeLabel_UI   := MyGui.Add("Text", "x14 y+2 w242 Center BackgroundTrans c" p["cIdle"], "Est. Total Time Completion  —  " Format("{:02}:{:02}", Floor(TimeTotal), Round((TimeTotal - Floor(TimeTotal)) * 60)))
    CarsLabel_UI   := MyGui.Add("Text", "x14 y+2 w242 Center BackgroundTrans c" p["cIdle"], "Recommended Car Purchase  —  " Floor(PointsTotal / SelectedCarPoint))

    ; Event Bindings
    CarSelect_UI.OnEvent("Change", UpdateCar)
    SkillPtsCount_In.OnEvent("Change", UpdateSkillPts)
    SkillPtsCount_In.OnEvent("LoseFocus", ValidateSkillPts)
    SkillPtsWant_In.OnEvent("Change", UpdateSkillPtsWant)
    SkillPtsWant_In.OnEvent("LoseFocus", ValidateSkillPtsWant)

    ; ── Session Panel ─────────────────────────
    MyGui.SetFont("s9 bold", "Segoe UI")
    MyGui.Add("Text", "x14 y+10 w242 Center BackgroundTrans c" p["textDim"], "SESSION")
    MyGui.Add("Text", "x14 y+0  w242 Center BackgroundTrans c" p["divider"], "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    MyGui.SetFont("s9 norm", "Segoe UI Light")
    Key_UI          := MyGui.Add("Text", "x0 y+5 w270 Center BackgroundTrans c" p["cIdle"], "➡️  [  ]")
    Process_UI      := MyGui.Add("Text", "x0 y+2 w270 Center BackgroundTrans c" p["cIdle"], "⚙️  Waiting...")
    TotalRunTime_UI := MyGui.Add("Text", "x0 y+2 w270 Center BackgroundTrans c" p["cIdle"], "⏱ Total Time Running   —   00:00")

    ; ── Progress Panel ────────────────────────
    MyGui.SetFont("s9 bold", "Segoe UI")
    MyGui.Add("Text", "x0 y+13 w270 Center BackgroundTrans c" p["textDim"], "PROGRESS")
    MyGui.Add("Text", "x0 y+0  w270 Center BackgroundTrans c" p["divider"], "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    MyGui.SetFont("s9 norm", "Segoe UI Light")
    RaceRunTime_UI   := MyGui.Add("Text", "x0 y+10 w270 Center BackgroundTrans c" p["cIdle"], "⏱   Race Time Running   —   00:00")
    PointsCount_UI   := MyGui.Add("Text", "x0 y+0 w270 Center BackgroundTrans c" p["cIdle"], "💡   Est. Skill Points Gained  —   0")
    BuyRunTime_UI    := MyGui.Add("Text", "x0 y+10 w270 Center BackgroundTrans c" p["cIdle"], "⏱   Buy Time Running   —   00:00")
    CarCount_UI      := MyGui.Add("Text", "x0 y+0 w270 Center BackgroundTrans c" p["cIdle"], "🚗   Car Purchased   —   0")
    UnlockRunTime_UI := MyGui.Add("Text", "x0 y+10 w270 Center BackgroundTrans c" p["cIdle"], "⏱   Unlock Time Running   —   00:00")
    SWheelCount_UI   := MyGui.Add("Text", "x0 y+0 w270 Center BackgroundTrans c" p["cIdle"], "🛞   Super Wheelspin   —   0")
    WheelCount_UI    := MyGui.Add("Text", "x0 y+0 w270 Center BackgroundTrans c" p["cIdle"], "🛞   Wheelspin   —   0")
    CreditCount_UI   := MyGui.Add("Text", "x0 y+0 w270 Center BackgroundTrans c" p["cIdle"], "💲   Credits   —   0 CR")

    ; ── Action Buttons ────────────────────────
    MyGui.Add("Text", "x14 y+10 w242 Center BackgroundTrans c" p["divider"], "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    MyGui.SetFont("s9 bold", "Segoe UI Semibold")
    RaceBtn := MyGui.Add("Text", "x14 y+6 w242 h36 Center 0x200 Background" p["btnBg"] " c" p["btnText"], "🏁   RACE   —   \")
    RaceBtn.OnEvent("Click", (*) => StartRace())

    BuyBtn := MyGui.Add("Text", "x14 y+6 w119 h36 Center 0x200 Background" p["btnBg"] " c" p["btnText"], "🚗   BUY  —   [")
    BuyBtn.OnEvent("Click", (*) => StartBuy())

    UnlockBtn := MyGui.Add("Text", "x137 yp w119 h36 Center 0x200 Background" p["btnBg"] " c" p["btnText"], "🛞   UNLOCK  —   ]")
    UnlockBtn.OnEvent("Click", (*) => StartUnlock())

    AllBtn := MyGui.Add("Text", "x14 y+6 w242 h36 Center 0x200 Background" p["btnBg"] " c" p["btnText"], "⟲   INIT SEQUENCE   —   /")
    AllBtn.OnEvent("Click", (*) => ToggleAll())

    themeLabel := DarkMode ? "☀   Switch to Light Mode" : "🌙   Switch to Dark Mode"
    MyGui.SetFont("s8 norm", "Segoe UI")
    ThemeBtn := MyGui.Add("Text", "x14 y+7 w242 h26 Center 0x200 Background" p["btnBg2"] " c" p["btnText2"], themeLabel)
    ThemeBtn.OnEvent("Click", (*) => ToggleTheme())

    ; ── Footer Codes ──────────────────────────
    MyGui.SetFont("s9", "Segoe UI Emoji")
    CodeTune_UI     := MyGui.Add("Text", "x0 y+10 w270 Center BackgroundTrans c" p["cIdle"], "Subaru 22B Tune Code - 293 391 902")
    CodeEventLab_UI := MyGui.Add("Text", "x0 y+0 w270 Center BackgroundTrans c" p["cIdle"], "EventLab Race Code - 124 198 343")

    CodeTune_UI.OnEvent("Click", (*) => (
        A_Clipboard := "293391902"
        ToolTip("Subaru 22B Tune Code Copied!")
        SetTimer(() => ToolTip(), -2000)
    ))

    CodeEventLab_UI.OnEvent("Click", (*) => (
        A_Clipboard := "124198343"
        ToolTip("EventLab Race Code Copied!")
        SetTimer(() => ToolTip(), -2000)
    ))

    ; ── GUI setting ──────────────────────────
    MyGui.Add("Text", "x0 y+5 w270 h1 BackgroundTrans c" p["footer"], "")
    MyGui.OnEvent("Close", (*) => ExitApp())
    MyGui.Show("w270 NoActivate Hide")

    ; ── Center the checkboxes ──────────────────────────    
    ;PixelCheck_UI.GetPos(,, &PixWidth)
    PremiumCheck_UI.GetPos(,, &PremWidth)
    MyGui.GetClientPos(,, &guiWidth)

    ;PixelCheck_UI.Move((guiWidth / 2) - (PixWidth / 2))
    PremiumCheck_UI.Move((guiWidth / 2) - (PremWidth / 2))

    ; ── Center the GUI on the half right screen ──────────────────────────
    MyGui.GetPos(, , &w, &h)

    screenW := A_ScreenWidth
    screenH := A_ScreenHeight

    rightHalfLeft := screenW // 2
    rightHalfWidth := screenW // 2

    x := rightHalfLeft + (rightHalfWidth - w) // 2
    y := (screenH - h) // 2

    MyGui.Move(x, y)
    MyGui.Show("w270 NoActivate")
}

; ══════════════════════════════════════════════
;  THEME TOGGLE
; ══════════════════════════════════════════════
ToggleTheme() {
    global DarkMode, MyGui, SkillPtsCount_In, SkillPtsWant_In, CarCount_In, ActiveMode

    ; Capture current values before destroy
    saved := [
        SkillPtsCount_In.Value,
	    SkillPtsWant_In.Value,
        CarCount_In.Value,
    ]

    ; Safely stop macro if running
    if ActiveMode {
        ActiveMode := ""
        Sleep(1250)
    }

    DarkMode := !DarkMode
    MyGui.Destroy()
    BuildGui(saved)
}


; ══════════════════════════════════════════════
;  HOTKEYS
; ══════════════════════════════════════════════
\::StartRace()
[::StartBuy()
]::StartUnlock()
/::ToggleAll()
F12::Reload()
`::TogglePause()
^+c:: GetCoordsColor()

; ══════════════════════════════════════════════
;  TOGGLE ACTION
; ══════════════════════════════════════════════

TogglePause() {
    global ActiveMode, PauseMode, StatusText, cIdle, cPaused, cStat, MasterMode

    Pause(-1)
    PauseMode := !PauseMode

    if (PauseMode && ActiveMode) {
        StatusText.Value := "⬤  Paused..."
        StatusText.SetFont("c" cPaused)
    }
    else if ActiveMode {
        StatusText.Value := "⬤  Running..."
        StatusText.SetFont("c" cStat)
    }
}

ToggleMode(mode) {
    global ActiveMode

    if (ActiveMode = mode) {
        ActiveMode := ""
        return false
    }

    if ActiveMode
        return false

    ActiveMode := mode
    return true
}

ToggleAll() {
    global ActiveMode, MasterMode, MasterStart
    global SkillPtsCount_In, SkillPtsWant_In, CarCount_In
    global PointsTotal, PointsGained, SelectedCarPoint, cHighlight, cIdle

    StartIndicators()
    MasterMode := !MasterMode

    while MasterMode {
	
	    MasterStart := true

        StartRace()
        ActiveMode := ""
        if !MasterMode
            break

        StartBuy()
        ActiveMode := ""
        if !MasterMode
            break

        StartUnlock()
        ActiveMode := ""
        if !MasterMode
            break

        Process("Restarting Race...")

        SkillPtsCount_In.Value := PointsTotal - (CarCount_In.Value * SelectedCarPoint)

        UpdateSkillPtsWant({Value: PointsTotal})
        ValidateSkillPtsWant({Value: PointsTotal})
    }
    MasterMode := ""
    MasterStart := false
    ResetIndicators()
}

StartRace() {
    global ActiveMode
    global StatusText, cActive, RaceCount, TotalRunSeconds, RaceRunSeconds, PointsCount
    global RaceRunTime_UI, RaceCount_UI, PointsCount_UI

    StartIndicators()
    
    if !ToggleMode("Race") {
        StatusText.Value := "⬤  Stopping..."
        StatusText.SetFont("cFFB347")
    }

    if (ActiveMode = "Race") {
        RaceCount		    := 0
        TotalRunSeconds		:= 0
        RaceRunSeconds		:= 0
        PointsCount		    := 0
        ;RaceCount_UI.Value	:= "🏁   Loop Completed   —   0"
        PointsCount_UI.Value	:= "💡   Est. Skill Points Gained   —   0"
        RaceRunTime_UI.Value	:= "⏱   Race Time Running   —   00:00"
        RaceLoop()
    }

    ResetIndicators()
}

StartBuy() {
    global ActiveMode
    global StatusText, cActive, CarCount, BuyRunSeconds
    global BuyRunTime_UI, CarCount_UI

    StartIndicators()

    if !ToggleMode("Buy") {
        StatusText.Value := "⬤  Stopping..."
        StatusText.SetFont("cFFB347")
    }

    if (ActiveMode = "Buy") {
		CarCount			:= 0
        BuyRunSeconds		:= 0
		CarCount_UI.Value	:= "🚗   Car Purchased   —   0"
        BuyRunTime_UI.Value	:= "⏱   Buy Time Running   —   00:00"
        StatusText.Value 	:= "⬤  Running..."
        StatusText.SetFont("c" cActive)
        BuyLoop()
    }

    ResetIndicators()
}

StartUnlock() {
    global ActiveMode
    global StatusText, cActive, SWheelCount, WheelCount, CreditCount, UnlockCount, UnlockRunSeconds
    global SWheelCount_UI, WheelCount_UI, CreditCount_UI, UnlockRunTime_UI

    StartIndicators()

    if !ToggleMode("Unlock") {
        StatusText.Value := "⬤  Stopping..."
        StatusText.SetFont("cFFB347")
    }

    if (ActiveMode = "Unlock") {
	    UnlockCount		        := 0
        UnlockRunSeconds        := 0 
		SWheelCount_UI.Value	:= "🛞   Super Wheelspin   —   0"
		WheelCount_UI.Value	    := "🛞   Wheelspin   —   0"
		CreditCount_UI.Value	:= "💲   Credits   —   0 CR"
        UnlockRunTime_UI.Value	:= "⏱   Unlock Time Running   —   00:00"
        StatusText.Value 	    := "⬤  Running..."
        StatusText.SetFont("c" cActive)
        UnlockLoop()
    }

    ResetIndicators()
}

; ══════════════════════════════════════════════
;  RACE LOOP
; ══════════════════════════════════════════════
RaceLoop() {
    global ActiveMode, MasterMode, MasterStart, SkillPtsCount_In, SkillPtsWant_In, CarCount_In
    global cActive, cHighlight, cIdle
    global RaceCount, RaceCount_UI, PointsCount_UI, CarCount_UI, RaceRunTime_UI, PixelCheck_UI
    global RaceLoadingTime, FinLoadingTime, AveragePoints, Maxpoints, PointsTotal, PointsGained, PointsCount, RaceRunSeconds

    ; Local helper to cleanly check if the macro should stop
    CheckAbort() => (ActiveMode != "Race" || (!MasterMode && MasterStart))

    While (ActiveMode = "Race") {

        RaceRunTime_UI.SetFont("c" cHighlight)
        SetTimer(RaceTimerTick, 1000)
        
        Sleep(1000)
        PressKey("Esc") ; Return to Free Roam

        if !WaitForMenuRelative("Returning to Free Roam...", 0.071, 0.289, "0xFFFFFF", , 20000) {
            Process("Sync Error: Unable to return to Free Roam!")
            break
        }

        if CheckAbort()
            break
            
        Process("Navigating Menu...")
        PressKey("Esc", 1000) ; Open Menu
        Loop 3
            PressKey("PgDn", 50) ; Navigate to EventLab Menu
        PressKey("PgDn")

        Process("Opening EventLab Menu...")
        PressKey("Enter", 1000) ; Select EventLab
        PressKey("Enter", 1500) ; Select Play Event
        if CheckAbort()
            break
        
        Process("Entering EventLab code...")
        PressKey("Backspace", 1000) ; Search
        PressKey("Up") ; Navigate to Share Code
        PressKey("Enter", 1000) ; Enter Text

        WriteNumber(124198343) ; EventLab Code

        PressKey("Enter") ; Submit Code
        PressKey("Down") ; Navigate to Confirm
        PressKey("Enter") ; Select Confirm

        if !WaitForMenuRelative("Waiting for EventLab to load...", 0.427, 0.594, "0x000000", , 10000, , true) {
            Process("Sync Error: EventLab search timed out!")
            break
        }

        PressKey("Enter") ; Select Event
        if CheckAbort()
            break

        Process("Entering EventLab...")
        PressKey("Enter", 3000) ; Choose Race Type
        PressKey("Y") ; Filter
        PressKey("Enter") ; Toggle
        PressKey("Esc", 1000) ; Back to My Cars
        if CheckAbort()
            break

        Process("Loading EventLab...")
        PressKey("Enter") ; Select Car
        
        if !WaitForMenuRelative("Waiting for track to load...", 0.158, 0.678, "0xFFFFFF", "", 30000) {
            Process("Sync Error: EventLab track failed to load!")
            break
        }

        Process("Start Race Event...")
        PressKey("Enter", 3000) ; Start Race
        if CheckAbort()
            break
        
        Process("Countdown...")
        Sleep(3000)
        PressKey("W", 50) ; Extra input to start the timer on the first run

        RaceLoadingTime := RaceRunSeconds ; Loading time can vary, so we capture it dynamically for more accurate estimates

        While (PointsCount < PointsGained) {
            PointsCount_UI.SetFont("c" cHighlight)
            Process("Throttling...")

            PressKey("w down", 50) ; Press throttle to move forward
            Sleep(30000) ; 
            PressKey("w up", 50) ; Release throttle to prevent timeout

            if CheckAbort()
                break
            
            RaceCount++

            ;PointsCount := EstimateScore(RaceRunSeconds - RaceLoadingTime)
            PointsCount := Floor(RaceCount * AveragePoints) ; Using average points per race for estimation to account for variability
            PointsCount_UI.Value := "💡   Est. Skill Points Gained  —   " PointsCount
            
            if (Mod(RaceCount, 4) = 0 && PointsCount < PointsGained) {
                PressKey("w down", 50) ; Press throttle to move forward
                Sleep(7700) ; 7.7 seconds of extra throttle for the car to turn around
                PressKey("w up", 50) ; Release throttle to prevent timeout
            }
        }
        
        Process("Quitting the Event...")
        Sleep(2000)
        PressKey("Esc", 1000) ; Pause Menu
        PressKey("Right") ; Navigate to Quit
        PressKey("Enter") ; Quit Event
        PressKey("Enter") ; Confirm Quit

        if !WaitForMenuRelative("Returning to Free Roam...", 0.061, 0.945, "0xFFFFFF", "", 20000) {
            Process("Sync Error: Unable to return to Free Roam!")
            break
        }

        if CheckAbort()
            break

        Process("Navigating Menu...")
        PressKey("Esc", 1000) ; Open Menu
        PressKey("PgDn") ; Navigate to Cars Menu
        PressKey("PgDn") ; Navigate to My Horizon Menu
        PressKey("Enter") ; Select Return Home
        PressKey("Enter") ; Confirm Travel to Home

        if !WaitForMenuRelative("Returning to Home...", 0.168, 0.722, "0xFFFFFF", "", 20000) {
            Process("Sync Error: Unable to return Home!")
            break
        }   

        RaceRunTime_UI.SetFont("c" cIdle)
        PointsCount_UI.SetFont("c" cIdle)

        break
    }
}

; ══════════════════════════════════════════════
;  BUY LOOP
; ══════════════════════════════════════════════
BuyLoop() {
    global ActiveMode, MasterMode, MasterStart
    global cActive, cHighlight, cIdle
    global CarCount, CarCount_In, SelectedCar, CarCount_UI, BuyRunTime_UI

    ; Local helper to cleanly check if the macro should stop
    CheckAbort() => (ActiveMode != "Buy" || (!MasterMode && MasterStart))

    While (ActiveMode = "Buy") {

        CarCount_UI.SetFont("c" cHighlight)
        BuyRunTime_UI.SetFont("c" cHighlight)

        SetTimer(BuyTimerTick, 1000)

        Process("Navigating Journal...")
        PressKey("Down") ; Navigate to Collection Journal
        PressKey("Enter", 650) ; Select Collection Journal
        PressKey("Right") ; Navigate to Master Explorer
        PressKey("Enter") ; Select Master Explorer
        PressKey("Down") ; Navigate to Car Collection
        PressKey("Enter") ; Select Car Collection
        PressKey("Backspace") ; Select Manufacturers
        if CheckAbort()
            break

        ; Upgraded to a clean Switch block for car selection menu logic
        Switch SelectedCar {
            Case "Subaru Impreza 22B":
                Loop 3
                    PressKey("Up", 50)
                Loop 3
                    PressKey("Right", 50)
                PressKey("Enter") ; Select Subaru
                PressKey("Down")

            Case "Lamborghini Revuelto":
                Loop 10
                    PressKey("Down", 50)
                PressKey("Enter") ; Select Lamborghini
                PressKey("Right")
                Loop 4
                    PressKey("Down", 50)

            Case "Dodge Viper GTS ACR":
                Loop 5
                    PressKey("Down", 50)
                Loop 2
                    PressKey("Right", 50)
                PressKey("Enter") ;Select Dodge
                if !PremiumCheck_UI
                    PressKey("Down")
                else {
                    PressKey("Down")
                    PressKey("Right")
                }
        }

        if CheckAbort()
            break

        ; ── Buying Car ───────────────
        Process("Buying " SelectedCar "...")
        While (CarCount < CarCount_In.Value) {
            PressKey("Space") ; Purchase Car
            PressKey("Down") ; Navigate to Yes
            PressKey("Enter") ; Select Yes (Car Collection)
            PressKey("Enter") ; Select Yes (Buy Car)
            PressKey("Enter") ; Select Yes (Ok)
            
            CarCount++
            CarCount_UI.Value := "🚗   Car Purchased   —   " CarCount
        }

        if CheckAbort()
            break

        ; ── Return to Home ───────────────
        Process("Returning to Home...")
        Loop 3
            PressKey("Esc") ; Navigate to Home Menu
        PressKey("Up") ; Navigate to Drive

        break
    }
}

; ══════════════════════════════════════════════
;  UNLOCK LOOP
; ══════════════════════════════════════════════
UnlockLoop() {
    global ActiveMode, MasterMode, CarCount_In
    global cActive, cHighlight, cIdle
    global SWheelCount, SWheelCount_UI, WheelCount, WheelCount_UI, CreditCount, CreditCount_UI, UnlockRunTime_UI, UnlockCount, SelectedCar

    ; 1. Helper function to clean up the repetitive break checks
    CheckAbort() => (ActiveMode != "Unlock" || (!MasterMode && MasterStart))

    While (ActiveMode = "Unlock") {
        
        ; 2. Initialize UI 
        UnlockRunTime_UI.SetFont("c" cHighlight)

        Switch SelectedCar {
            Case "Subaru Impreza 22B":
                SWheelCount_UI.SetFont("c" cHighlight)
            Case "Lamborghini Revuelto":
                SWheelCount_UI.SetFont("c" cHighlight)
                WheelCount_UI.SetFont("c" cHighlight)
            Case "Dodge Viper GTS ACR":
                CreditCount_UI.SetFont("c" cHighlight)
        }
    
        SetTimer(UnlockTimerTick, 1000)
        
        ; 3. Initial Navigation
        Process("Navigating Home...")
        PressKey("PgDn") ; Navigate to Buy & Sell Menu
        PressKey("Down", 50) ; Navigate to Auction House
        if CheckAbort()
            break
    
        Process("Navigating Auction House...")
        PressKey("Enter", 550) ; Select Auction House
        PressKey("Down") ; Navigate to Start Auction
        PressKey("Enter", 650) ; Select Start Auction
        if CheckAbort()
            break
    
        Process("Sort by Recently Added...")
        PressKey("X") ; Sort
        Loop 6 
            PressKey("Down", 50) ; Navigate to Recently Added
        PressKey("Enter") ; Select Recently Added
        PressKey("Backspace") ; Jump to Recently Added
        PressKey("Enter") ; Select All Cars
        if CheckAbort()
            break
    
        Process("Choosing First Car...")
        PressKey("Enter") ; Select First Car
        PressKey("Down") ; Navigate to Get in Car
        PressKey("Enter", 5000) ; Select Get in Car
        PressKey("Esc", 1500) ; Navigate to Auction House Menu
        PressKey("Esc", 1500) ; Navigate to Buy & Sell Menu
        if CheckAbort()
            break
    
        ; 4. Main Unlocking Loop
        Loop CarCount_In.Value {
            
            Process("Navigating Upgrade...")
            if CheckAbort() 
                break
    
            PressKey("PgDn") ; Navigate to Cars Menu
            PressKey("Down", 50) ; Navigate to Upgrades & Tuning
            PressKey("Enter", 700) ; Select Upgrades & Tuning
            Loop 7 
                PressKey("Down", 50) ; Navigate to Car Mastery
            PressKey("Enter") ; Select Car Mastery

            if !WaitForMenuRelative("Opening Car Mastery...", 0.176, 0.545, "0xFFFFFF", "", 5000, 100) {
                Process("Sync Error: Car Mastery menu failed to load!")
                break
            }
    
            if CheckAbort()
                break
    
            Process("Unlocking Wheelspins...")
            Switch SelectedCar {
                Case "Subaru Impreza 22B":
                    PressKey("Enter", 1100)
                    PressKey("Right", 300)
                    Loop 3 {
                        PressKey("Enter", 1100)
                        PressKey("Up", 300)
                    }
                    PressKey("Enter", 1100)
                    PressKey("Left", 300)
                    PressKey("Enter", 1100)
    
                    UnlockCount++
                    SWheelCount_UI.Value := "🛞   Super Wheelspin   —   " UnlockCount
                    
                Case "Lamborghini Revuelto":
                    PressKey("Enter", 1100)
                    Loop 3 {
                        PressKey("Up", 300)
                        PressKey("Enter", 1100)
                    }
                    Loop 2 {
                        PressKey("Right", 300)
                        PressKey("Enter", 1100)
                    }
    
                    UnlockCount++
                    SWheelCount_UI.Value := "🛞   Super Wheelspin   —   " UnlockCount
                    WheelCount_UI.Value  := "🛞   Wheelspin   —   " (UnlockCount * 3)
                    
                Case "Dodge Viper GTS ACR":
                    PressKey("Enter", 1100)
                    PressKey("Right", 300)
                    Loop 3 {   
                        PressKey("Enter", 1100)
                        PressKey("Up", 300)
                    }
                    PressKey("Enter", 1100)
                    PressKey("Right", 300)
                    PressKey("Enter", 1100)
    
                    UnlockCount++
                    CreditCount_UI.Value := "💲   Credits   —   " (UnlockCount * 85400) " CR"
            }
    
            if CheckAbort()
                break
    
            Process("Navigating Home...")
            PressKey("Esc", 1500) ; Navigate to Upgrades Menu
            PressKey("Esc", 1500) ; Navigate to Cars Menu
            PressKey("PgUp", 50) ; Navigate to Buy & Sell Menu
            PressKey("Down", 1000) ; Navigate to Auction House
            if CheckAbort()
                break
    
            Process("Navigating Auction House...")
            PressKey("Enter", 700) ; Select Auction House
            PressKey("Down") ; Navigate to Start Auction
            PressKey("Enter", 700) ; Select Start Auction
            if CheckAbort()
                break
    
            Process("Sort by Recently Added...")
            PressKey("X") ; Sort
            Loop 6 
                PressKey("Down", 150) ; Navigate to Recently Added
            PressKey("Enter") ; Select Recently Added
            if CheckAbort()
                break
    
            Process("Choosing Next Car...")
            PressKey("Down") ; Navigate to Next Car
            PressKey("Enter") ; Select Next Car
            PressKey("Down") ; Navigate to Get in Car 
            PressKey("Enter") ; Select Get in Car

            if !WaitForMenuRelative("Getting in Car...", 0.067, 0.169, "0xFFFFFF", "", 10000, 100) {
                Process("Sync Error: Unable to get in car!")
                break
            }

            if CheckAbort()
                break
    
            Process("Removing Car From Garage...")
            PressKey("Up") ; Navigate to First Car
            PressKey("Enter") ; Select First Car
            Loop 5 
                PressKey("Down", 50) ; Navigate to Remove from Garage
            PressKey("Enter") ; Select Remove from Garage
            PressKey("Down") ; Navigate to Confirm
            PressKey("Enter", 1000) ; Confirm Remove from Garage
            if CheckAbort()
                break
    
            Process("Returning to Home...")
            PressKey("Esc", 1600) ; Navigate to Auction House Menu
            PressKey("Esc", 1600) ; Navigate to Buy & Sell Menu
            if CheckAbort()
                break
        }
        PressKey("PgUp") ; Navigate to Campaign Menu
        break ; Forces the outer While loop to only run once, acting like a labeled block.
    }
}

; ══════════════════════════════════════════════
;  COUNTDOWN ENGINE
; ══════════════════════════════════════════════
SmartCountdown(TotalSec, UIEl, ActiveText) {
    global ActiveMode
    Loop TotalSec {
        if (ActiveMode != "Race")
            return false
        UIEl.Value := ActiveText " (" (TotalSec - A_Index + 1) "s)"
        Sleep(1000)
    }
    return true
}


; ══════════════════════════════════════════════
;  RESET
; ══════════════════════════════════════════════

StartIndicators() {
    global StatusText, Process_UI, Key_UI, TotalRunTime_UI
    global SkillPtsCount_In, SkillPtsWant_In, CarCount_In, CarSelect_UI, PremiumCheck_UI

    StatusText.Value 	:= "⬤  Running..."
    StatusText.SetFont("c" cActive)

    Process_UI.SetFont("c" cHighlight)
    Key_UI.SetFont("c" cHighlight)
    TotalRunTime_UI.SetFont("c" cHighlight)

    SkillPtsCount_In.Enabled := false
    SkillPtsWant_In.Enabled := false
    CarCount_In.Enabled := false
    CarSelect_UI.Enabled := false
    PremiumCheck_UI.Enabled := false

    SetTimer(TotalTimerTick, 1000)
}

ResetIndicators() {
    global Key_UI, Process_UI, StatusText, cIdle, cTextDim
    global RaceCount_UI, TotalRunTime_UI, RaceRunTime_UI, BuyRunTime_UI, UnlockRunTime_UI, RaceCount, ActiveMode, MasterMode
    global SkillPtsCount_In, SkillPtsWant_In, CarCount_In, CarSelect_UI, PremiumCheck_UI

    SetTimer(RaceTimerTick, 0)
    SetTimer(BuyTimerTick, 0)
    SetTimer(UnlockTimerTick, 0)
    if (!MasterMode) {
        SetTimer(TotalTimerTick, 0)
    }
    ActiveMode := ""
    Key_UI.Value := "➡️  [  ]"
    Key_UI.SetFont("c" cIdle)
    Process_UI.Value := "⚙️  Waiting..."
    
    Process_UI.SetFont("c" cIdle)
    TotalRunTime_UI.SetFont("c" cIdle)
    RaceRunTime_UI.SetFont("c" cIdle)
    BuyRunTime_UI.SetFont("c" cIdle)
    UnlockRunTime_UI.SetFont("c" cIdle)
    ;RaceCount_UI.SetFont("c" cIdle)
    PointsCount_UI.SetFont("c" cIdle)
    CarCount_UI.SetFont("c" cIdle)
    SWheelCount_UI.SetFont("c" cIdle)
    WheelCount_UI.SetFont("c" cIdle)
    CreditCount_UI.SetFont("c" cIdle)
    StatusText.Value := "⬤  Stopped"
    StatusText.SetFont("c" cTextDim)
    
    SkillPtsCount_In.Enabled := true
    SkillPtsWant_In.Enabled := true
    CarCount_In.Enabled := true
    CarSelect_UI.Enabled := true
    PremiumCheck_UI.Enabled := true
}

; ══════════════════════════════════════════════
;  UPDATE VALUE INPUT
; ══════════════════════════════════════════════

UpdateCar(ctrl,*) {
    global SelectedCar, SelectedCarPoint, PointsTotal
    
    SelectedCar := ctrl.Text
    SelectedCarPoint := CarSelect_UI.Text = "Lamborghini Revuelto" ? 39 : 30

    CarPurchaseCount := Floor(PointsTotal / SelectedCarPoint)
        
    CarCount_In.Value :=  CarPurchaseCount
    CarsLabel_UI.Value := "Recommended Car Purchase  —  " CarPurchaseCount
}

UpdateSkillPts(ctrl, *) {
    global SelectedCarPoint, TimeTotal, PointsTotal, CarCount_In, SkillPtsWant_In, SelectedCarPoint, AveragePoints, PointsGained, MaxPoints
    global PointsLabel_UI, TimeLabel_UI, CarsLabel_UI

    value := ctrl.value
	
    if (value = "")
        value := 0
    else if (value > 999)
        value:= 999
	
    SkillPtsWant_In.Value := 999 - value > MaxPoints ? MaxPoints : 999 - value

    PointsGained := GetMinScore(SkillPtsWant_In.Value)	
    PointsTotal := PointsGained + value
    	
    CarCount_In.Value := Floor(PointsTotal / SelectedCarPoint)
	TimeTotal := CalcTimeRace(SkillPtsWant_In.Value)  + CalcTimeBuy(CarCount_In.Value) + CalcTimeUnlock(CarCount_In.Value)

    PointsLabel_UI.Value := "Est. Skill Points Gained  —  " PointsGained
    TimeLabel_UI.Value :=  "Est. Total Time Completion  —  " Format("{:02}:{:02}", Floor(TimeTotal) , Round((TimeTotal - Floor(TimeTotal)) * 60))
    CarsLabel_UI.Value := "Recommended Car Purchase  —  " Floor(PointsTotal / SelectedCarPoint)
}
    
UpdateSkillPtsWant(ctrl, *) {

    global SelectedCarPoint, TimeTotal, PointsTotal, CarCount_In, SkillPtsCount_In, SelectedCarPoint, AveragePoints, PointsGained, MaxPoints
    global PointsLabel_UI, TimeLabel_UI, CarsLabel_UI, PointsCount_UI

    value := ctrl.value
	
    if (value = "") 
        value := 0
    else if (value + SkillPtsCount_In.Value > 999)
        value := 999 - SkillPtsCount_In.Value
    else if (value > MaxPoints)
        value := MaxPoints

    PointsGained := GetMinScore(value)	
    PointsTotal := PointsGained + SkillPtsCount_In.Value
	
    CarCount_In.Value := Floor(PointsTotal / SelectedCarPoint)
	TimeTotal := CalcTimeRace(value) + CalcTimeBuy(CarCount_In.Value) + CalcTimeUnlock(CarCount_In.Value)
    
    PointsLabel_UI.Value := "Est. Skill Points Gained  —  " PointsGained
    TimeLabel_UI.Value :=  "Est. Total Time Completion  —  " Format("{:02}:{:02}", Floor(TimeTotal) , Round((TimeTotal - Floor(TimeTotal)) * 60))
    CarsLabel_UI.Value := "Recommended Car Purchase  —  " Floor(PointsTotal / SelectedCarPoint)
}

ValidateSkillPts(ctrl, *) {
    value := ctrl.value
	
    if (value = "") 
        value := 0
    else if (value > 999)
        value:= 999
	
    ctrl.value := value
}

ValidateSkillPtsWant(ctrl, *) {
    global SkillPtsCount_In, MaxPoints

    value := ctrl.value
	
    if (value = "") 
        value := 0
    else if (value + SkillPtsCount_In.Value > 999)
        value := 999 - SkillPtsCount_In.Value
    else if (value > MaxPoints)
        value := MaxPoints
	
    ctrl.value := value
}

; ══════════════════════════════════════════════
;  SCORE AND TIME CALCULATION
; ══════════════════════════════════════════════

GetMinScore(score) {
    pointsPerSection := MaxPoints / 96
    sections := Ceil(score / pointsPerSection)
    return Floor(sections * pointsPerSection)
}

CalcTimeRace(score) {
    global RaceLoadingTime, FinLoadingTime

    pointsPerSection := MaxPoints / 96
    secPerSection := 30
    secPerRow := 7
    sectionsPerRow := 4

    sections := Ceil(score / pointsPerSection)
    rows := Ceil(sections / sectionsPerRow)

    totalTime := RaceLoadingTime + (sections * secPerSection) + (rows * secPerRow) + FinLoadingTime

    return totalTime / 60
}

CalcTimeBuy(car) {
	totalTime := car * 2.7
    return totalTime / 60
}

CalcTimeUnlock(car) {
    totalTime := car * 31
    return totalTime / 60
}

EstimateScoreFast(time) {
    global Maxpoints

    pointsPerSection := Maxpoints / 96
    secPerSectionEffective := 31.875
    
    sections := Floor(time / secPerSectionEffective)
    return Floor(sections * pointsPerSection)
}

EstimateScore(time) {
    global MaxPoints

    pointsPerSection := MaxPoints / 96

    fullRows := Floor(time / 128)

    remaining := Mod(time, 128)

    sections := fullRows * 4
    sections += Min(4, Floor(remaining / 30))

    return Floor(sections * pointsPerSection)
}

; ══════════════════════════════════════════════
;  TIMER TICK  (fires every second while running)
; ══════════════════════════════════════════════
TotalTimerTick() {
    global TotalRunSeconds, TotalRunTime_UI, cHighlight
    TotalRunSeconds++
    mins := TotalRunSeconds // 60
    secs := Mod(TotalRunSeconds, 60)

    TotalRunTime_UI.Value := "⏱ Total Time Running   —   " Format("{:02d}:{:02d}", mins, secs)
}

RaceTimerTick() {
    global RaceRunSeconds, RaceRunTime_UI, cHighlight
    RaceRunSeconds++
    mins := RaceRunSeconds // 60
    secs := Mod(RaceRunSeconds, 60)

    RaceRunTime_UI.Value := "⏱   Race Time Running   —   " Format("{:02d}:{:02d}", mins, secs)
}

BuyTimerTick() {
    global BuyRunSeconds, BuyRunTime_UI, cHighlight
    BuyRunSeconds++
    mins := BuyRunSeconds // 60
    secs := Mod(BuyRunSeconds, 60)

    BuyRunTime_UI.Value := "⏱   Buy Time Running   —   " Format("{:02d}:{:02d}", mins, secs)
}

UnlockTimerTick() {
    global UnlockRunSeconds, UnlockRunTime_UI, cHighlight
    UnlockRunSeconds++
    mins := UnlockRunSeconds // 60
    secs := Mod(UnlockRunSeconds, 60)

    UnlockRunTime_UI.Value := "⏱   Unlock Time Running   —   " Format("{:02d}:{:02d}", mins, secs)
}
; ══════════════════════════════════════════════
;  PIXEL DETECTION
; ══════════════════════════════════════════════

WaitForMenuRelative(text, ratioX, ratioY, targetColor, targetColorHDR := "", timeoutMs := 8000, postDelayMs := 1000, isFatal := false, variation := 0) {
    global ActiveMode, MasterMode, MasterStart
    CoordMode("Pixel", "Screen") 
    StartTime := A_TickCount
    LastSec := -1 ; ── Tracks seconds to prevent spamming your status window
    
    actualX := Round(ratioX * A_ScreenWidth)
    actualY := Round(ratioY * A_ScreenHeight)

    Loop {
        if (ActiveMode != "Race" && ActiveMode != "Buy" && ActiveMode != "Unlock" || (!MasterMode && MasterStart))
            return false
            
        ; ── ⏳ SMOOTH COUNTDOWN LOGIC ─────────────────────────────────────────
        RemainingSec := Ceil((timeoutMs - (A_TickCount - StartTime)) / 1000)
        if (RemainingSec < 0) 
            RemainingSec := 0
            
        ; Only calls Process() when a full second actually ticks down
        if (RemainingSec != LastSec) {
            Process(text " (" RemainingSec "s)")
            LastSec := RemainingSec
        }
        ; ─────────────────────────────────────────────────────────────────────

        ; 1. Check Standard Color
        if PixelSearch(&foundX, &foundY, actualX, actualY, actualX, actualY, targetColor, variation) {
            if (postDelayMs > 0)
                Sleep(postDelayMs)
            return true 
        }

        ; 2. Check HDR Color
        if (targetColorHDR != "" && PixelSearch(&foundX, &foundY, actualX, actualY, actualX, actualY, targetColorHDR, variation)) {
            if (postDelayMs > 0)
                Sleep(postDelayMs)
            return true 
        }

        ; 3. Handle Timeout
        if (A_TickCount - StartTime > timeoutMs) {
            if (isFatal) {
                Process("Sync Error: Menu timed out!")
                return false
            } else {
                Process("Sync Warning: Pixel missed. Proceeding blindly...")
                Sleep(2000)
                return true 
            }
        }
        Sleep(50) 
    }
}

GetCoordsColor() {
    CoordMode("Mouse", "Screen")
    CoordMode("Pixel", "Screen")
    MouseGetPos(&x, &y)
    color := PixelGetColor(x, y)
    ratioX := x / A_ScreenWidth
    ratioY := y / A_ScreenHeight
    A_Clipboard := Format("{:.3f}, {:.3f}, `"{}`"", ratioX, ratioY, color)
    
    ToolTip("Copied Relative Coords!`nRatio X: " ratioX "`nRatio Y: " ratioY "`nColor: " color)
    SetTimer(() => ToolTip(), -3000)
}

; ══════════════════════════════════════════════
;  KEY AND PROCESS
; ══════════════════════════════════════════════

PressKey(key, delay := 500) {
    global Key_UI, cHighlight, cIdle

    ; 1. Determine UI Display Name (Supports grouping multiple cases)
    switch key {
        case "Down":  displayname := "↓"
        case "Up":    displayname := "↑"
        case "Left":  displayname := "←"
        case "Right": displayname := "→"
        case "w down", "w up": displayname := "W"
        Default : displayname := key
    }

    Key_UI.Value := "➡️  [ " displayName " ]"

    ; 2. Handle Space Modifiers (e.g., splitting "w" and "down")
    cleanKey := key
    suffix := ""
    if InStr(key, " ") {
        parts := StrSplit(key, " ")
        cleanKey := parts[1]   ; Contains just "w"
        suffix := " " parts[2] ; Contains " down" or " up"
    }

    ; 3. Convert the key to a physical Scan Code dynamically
    if (scCode := GetKeySC(cleanKey)) {
        ; Convert integer to 3-digit Hex string (e.g., 17 becomes "011")
        hexSC := Format("{:03X}", scCode)
        sendKey := "sc" hexSC suffix
    } else {
        ; Fallback to the original text if AHK doesn't recognize the key
        sendKey := key
    }

    ; 4. Send the hardware level scan code
    Send("{" sendKey "}")
    
    Sleep(delay)
}

Process(text) {
    global Process_UI

    Process_UI.Value := "⚙️  " text
}

; ══════════════════════════════════════════════
;  MISC FUNCTIONS
; ══════════════════════════════════════════════

WriteNumber(num) {
    for digit in StrSplit(String(num))
    {
        Send("{" digit "}")
        Sleep(50) ; optional delay between key presses
    }
}

; ══════════════════════════════════════════════
BuildGui()