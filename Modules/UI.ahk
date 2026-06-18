; ╔═════════════════════════════════════════╗
; ║        MHI - FH6 Wheelspin Macro        ║
; ║        Cyber Noir Edition v1.6.0        ║
; ╚═════════════════════════════════════════╝

#Requires AutoHotkey v2.0

; ══════════════════════════════════════════════
;  GLOBAL DATA SOURCING (Super-Globals)
; ══════════════════════════════════════════════
global CarList          := ["Subaru Impreza 22B-STi", "Lamborghini Revuelto", "Dodge Viper GTS ACR"]
global CodeList         := ["AMMAGEDON", "LIQUIDPOTATO"]

; ══════════════════════════════════════════════
;  GLOBAL UI HANDLES
; ══════════════════════════════════════════════
global PointsCount_UI   := ""
global CarCount_UI      := ""
global SWheelCount_UI   := ""
global WheelCount_UI    := ""
global CreditCount_UI   := ""
global CodeTune_UI      := ""
global TotalRunTime_UI  := ""
global RaceRunTime_UI   := ""
global BuyRunTime_UI    := ""
global UnlockRunTime_UI := ""
global CarSelect_UI     := ""
global CarsLabel_UI     := ""
global PointsLabel_UI   := ""
global TimeLabel_UI     := ""
global SectorLabel_UI   := ""
global PixelCheck_UI    := ""
global PremiumCheck_UI  := ""
global CodeSelect_UI    := ""
global SectorCount_UI   := ""
global SpinRunTime_UI   := ""
global SpinOpenCount_UI := ""
global SpinLeftCount_UI := ""

; ══════════════════════════════════════════════
;  PALETTE COMPOSER
; ══════════════════════════════════════════════
GetPalette() {
    global DarkMode
    p := Map()

    if DarkMode {
        p["bg"]          := "0B0F14"
        p["panel"]       := "111826"
        p["accent"]      := "00E5FF"
        p["accent2"]     := "7C4DFF"
        p["text"]        := "E6F1FF"
        p["textDim"]     := "6B7C93"
        p["editBg"]      := "0F1624"
        p["btnBg"]       := "111826"
        p["btnText"]     := "00E5FF"
        p["btnBg2"]      := "0C1320"
        p["btnText2"]    := "6B7C93"
        p["divider"]     := "1F2A3A"
        p["cActive"]     := "00E5FF"
        p["cHighlight"]  := "39FF14"
        p["cPaused"]     := "FFD54F"
        p["cIdle"]       := "6B7C93"
        p["cTextDim"]    := "6B7C93"
        p["footer"]      := "1F2A3A"
        p["header"]      := "4289B6"
        p["activeBg"]    := "4B5563"
        p["inactiveBg"]  := "1F2937"
    } else {
        p["bg"]          := "F5F7FA"
        p["panel"]       := "E8EEF5"
        p["accent"]      := "0066FF"
        p["accent2"]     := "7C4DFF"
        p["text"]        := "0B1220"
        p["textDim"]     := "4B5B73"
        p["editBg"]      := "FFFFFF"
        p["btnBg"]       := "DCE8FF"
        p["btnText"]     := "003A99"
        p["btnBg2"]      := "CFE0FF"
        p["btnText2"]    := "4B5B73"
        p["divider"]     := "C9D6E5"
        p["cActive"]     := "0066FF"
        p["cHighlight"]  := "1DB954"
        p["cPaused"]     := "C68400"
        p["cIdle"]       := "4B5B73"
        p["cTextDim"]    := "4B5B73"
        p["footer"]      := "C9D6E5"
        p["header"]      := "4289B6"
        p["activeBg"]    := "BFDBFE"
        p["inactiveBg"]  := "F1F5F9"
    }
    return p
}

; ══════════════════════════════════════════════
;  TOGGLE BUTTON PAIR  (generalised helper)
; ══════════════════════════════════════════════
TogglePair(chosenValue, &targetVar, activeBtn, inactiveBtn, p) {
    targetVar := chosenValue
    activeBtn.Opt("Background" p["activeBg"])
    inactiveBtn.Opt("Background" p["inactiveBg"])
    activeBtn.Redraw()
    inactiveBtn.Redraw()
}

; ══════════════════════════════════════════════
;  FONT HELPER
; ══════════════════════════════════════════════
SetFixedFont(guiObj, pointSize, options := "", fontName := "Segoe UI") {
    switch fontName {
        case "Light":    fontName := "Segoe UI Light"
        case "Semibold": fontName := "Segoe UI Semibold"
        case "Emoji":    fontName := "Segoe UI Emoji"
        default:         fontName := "Segoe UI"
    }
    fixedSize   := pointSize * (96 / A_ScreenDPI)
    guiObj.SetFont("s" fixedSize " " options, fontName)
}

; ══════════════════════════════════════════════
;  NOTIFICATION TOAST
; ══════════════════════════════════════════════
ShowNotif(type, title, message := "") {
    switch StrLower(type) {
        case "success":
            accentColor := "33FF66"
            icon        := "✅ "
            duration    := -5000
        case "error", "fail", "failure":
            accentColor := "FF3333"
            icon        := "❌ "
            duration    := -5000
        default:
            accentColor := "00D2FF"
            icon        := "ℹ️ "
            duration    := -5000
    }

    Notif := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
    Notif.BackColor := "181A1F"
    Notif.Add("Progress", "x0 y0 w6 h70 Background" accentColor)
    Notif.SetFont("s10 bold c" accentColor, "Segoe UI")
    Notif.Add("Text", "x15 y10 w250 BackgroundTrans", icon title)
    Notif.SetFont("s9 norm cEEEEEE", "Segoe UI")
    Notif.Add("Text", "x15 y+5 w250 h35 BackgroundTrans", message)

    Notif.Show("x" (A_ScreenWidth - 290) " y" (A_ScreenHeight - 110) " w280 h70 NoActivate")
    SetTimer(() => Notif.Destroy(), duration)
}

; ══════════════════════════════════════════════
;  MINI WIDGET  (shown when main window minimises)
; ══════════════════════════════════════════════
Global MiniGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
MiniGui.BackColor := "181A1F"
MiniGui.Add("Progress", "x0 y0 w5 h120 Background00D2FF")
MiniGui.SetFont("s8 bold c00D2FF", "Segoe UI")
MiniGui.Add("Text", "x15 y8 w120", "⚙️ FH6 MACRO")
MiniGui.SetFont("s9 norm cEEEEEE")
global MiniTotalRunTime_UI := MiniGui.Add("Text", "x15 y+8 w140 BackgroundTrans c6B7C93", "🕓  00:00")
global MiniKey_UI          := MiniGui.Add("Text", "x15 y+2 w140 BackgroundTrans c6B7C93", "⌨  [   ]")
global MiniMode_UI         := MiniGui.Add("Text", "x15 y+2 w140 BackgroundTrans c6B7C93", "🔀  Mode:")
MiniGui.Add("Progress", "x15 y+2 w155 h1 Background333333")
global MiniProcess_UI      := MiniGui.Add("Text", "x15 y+2 w150 h35 BackgroundTrans c6B7C93", "⚙️  Waiting...")

RestoreBtn := MiniGui.Add("Button", "x144 y8 w25 h25", "⤢")
RestoreBtn.OnEvent("Click", RestoreMainWindow)

MainGui_SizeChange(thisGui, minMax, *) {
    if (minMax == -1) {
        thisGui.Hide()
        MiniGui.Show("x10 y10 w180 h120 NoActivate")
        WinSetTransparent(180, MiniGui.Hwnd)
    }
}

RestoreMainWindow(*) {
    MiniGui.Hide()
    MyGui.Show()
}

; ══════════════════════════════════════════════
;  THEME TOGGLE
; ══════════════════════════════════════════════
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

; ══════════════════════════════════════════════
;  INTERFACE GENERATION ENGINE
; ══════════════════════════════════════════════
BuildGui(savedVals := "") {
    global MyGui, StatusText
    global PointsCount_UI, CarCount_UI, SWheelCount_UI, WheelCount_UI, CreditCount_UI
    global SpinRunTime_UI, SpinOpenCount_UI, SpinLeftCount_UI
    global TotalRunTime_UI, RaceRunTime_UI, BuyRunTime_UI, UnlockRunTime_UI, SectorCount_UI
    global PointsLabel_UI, TimeLabel_UI, CarsLabel_UI, SectorLabel_UI
    global CodeSelect_UI, DelaySlider_UI, SpeedLabel_UI
    global Key_UI, Process_UI, CodeTune_UI, CodeEventLab_UI, CarSelect_UI
    global SkillPtsCount_In, SkillPtsWant_In, CarCount_In, LoopCount_In
    global AveragePoints, MaxPoints, PointsTotal, PointsGain, TimeTotal
    global ActiveMode, DarkMode, cActive, cHighlight, cIdle, cTextDim, cPaused, cStat
    global CodeEventLab, CodeTune, SpinMode, UserTier
    global CarList, CodeList

    p          := GetPalette()
    cActive    := p["cActive"]
    cHighlight := p["cHighlight"]
    cIdle      := p["cIdle"]
    cTextDim   := p["cTextDim"]
    cPaused    := p["cPaused"]
    cStat      := ActiveMode ? p["accent"] : p["textDim"]
    sLabel     := ActiveMode ? "⬤   Running..." : "⬤   Stopped"

    ; ── Window ────────────────────────────────
    MyGui := Gui("+AlwaysOnTop -MaximizeBox -DPIScale", "MHI | FH6 MACRO")
    MyGui.BackColor := p["bg"]

    ; ── Header ────────────────────────────────
    SetFixedFont(MyGui, 14, "bold", "Light")
    MyGui.Add("Text", "x0 y+15 w270 Center BackgroundTrans c" p["accent"], "WHEELSPIN MACRO")
    SetFixedFont(MyGui, 7, "norm")
    MyGui.Add("Text", "x0 y+1 w270 Center BackgroundTrans c" p["textDim"], "FORZA HORIZON 6   ✦   AFK FARM")

    ; ── Status ────────────────────────────────
    SetFixedFont(MyGui, 10, "bold", "Semibold")
    StatusText := MyGui.Add("Text", "x0 y+10 w270 Center BackgroundTrans c" cStat, sLabel)

    ; ── Tab Control ───────────────────────────
    TabControl := MyGui.Add("Tab3", "x5 y+15 w260 h400 +Buttons +0x400 c" p["accent"], ["Input", "Stats"])
    SendMessage(0x1329, 0, 127 | (26 << 16), TabControl)

    ; ══════════════════════════════════════════
    ;  TAB 1 — INPUT
    ; ══════════════════════════════════════════
    TabControl.UseTab(1)

    MyGui.Add("Text", "x0 y+5 w270 h5 BackgroundTrans c" p["footer"], "")

    ; ── Numeric Inputs (Strict Layout & Scope Matching) ──
    SetFixedFont(MyGui, 9, "norm", "Light")
    MyGui.Add("Text", "x30 y+6 w155 BackgroundTrans c" p["text"], "⟡   Current Skill Points")
    SkillPtsCount_In := MyGui.Add("Edit", "x179 yp-3 w63 Center Number Background" p["editBg"] " c" p["text"], savedVals ? savedVals[1] : 0)

    MyGui.Add("Text", "x30 y+6 w155 BackgroundTrans c" p["text"], "⟡   Desired Skill Points")
    SkillPtsWant_In := MyGui.Add("Edit", "x179 yp-3 w63 Center Number Background" p["editBg"] " c" p["text"], savedVals ? savedVals[2] : MaxPoints)

    MyGui.Add("Text", "x30 y+6 w155 BackgroundTrans c" p["text"], "⟡   Car Purchase")
    CarCount_In := MyGui.Add("Edit", "x179 yp-3 w63 Center Number Background" p["editBg"] " c" p["text"], savedVals ? savedVals[3] : Floor(MaxPoints / SelectedCarPoint))

    MyGui.Add("Text", "x30 y+6 w155 BackgroundTrans c" p["text"], "⟡   Sequence Loop")
    LoopCount_In := MyGui.Add("Edit", "x179 yp-3 w63 Center Number Background" p["editBg"] " c" p["text"], savedVals ? savedVals[4] : 99)

    ; ── Cyber Dropdown: Car Selector ──────────
    SetFixedFont(MyGui, 9, "bold")
    CarSelect_UI := MyGui.Add("Text", "x45 y+10 w180 h24 Center 0x200 Background" p["editBg"] " c" p["text"])
    
    CarSelect_UI.DefineProp("Value", {
        get: (this) => this.HasOwnProp("ctrlIndex") ? this.ctrlIndex : 1,
        set: (this, val) => (this.ctrlIndex := val, ControlSetText(CarList[val] "   ▼", this.Hwnd, this.Gui.Hwnd))
    })
    CarSelect_UI.DefineProp("Text", {
        get: (this) => CarList[this.Value],
        set: (this, val) => ControlSetText(val, this.Hwnd, this.Gui.Hwnd)
    })
    CarSelect_UI.Value := 1 
    CarSelect_UI.OnEvent("Click", ShowCarMenu)

    ; ── Tier Toggle ───────────────────────────
    SetFixedFont(MyGui, 9, "bold", "Semibold")
    StandardBtn := MyGui.Add("Text", "x14 y+5 w119 h24 Center 0x200 Background" p["activeBg"]   " c" p["text"], "😎   STANDARD")
    PremiumBtn  := MyGui.Add("Text", "x137 yp w119 h24 Center 0x200 Background" p["inactiveBg"] " c" p["text"], "🜲   PREMIUM")

    StandardBtn.OnEvent("Click", (*) => TogglePair("STANDARD", &UserTier, StandardBtn, PremiumBtn, p))
    PremiumBtn.OnEvent("Click",  (*) => TogglePair("PREMIUM",  &UserTier, PremiumBtn, StandardBtn, p))

    ; ── Session Info ──────────────────────────

    SetFixedFont(MyGui, 9, "norm", "Light")

    Key_UI          := MyGui.Add("Text", "x0 y+15 w270 Center BackgroundTrans c" p["cIdle"], "⌨   [   ]")

    Process_UI      := MyGui.Add("Text", "x0 y+2  w270 Center BackgroundTrans c" p["cIdle"], "⚙️   Waiting...")

    TotalRunTime_UI := MyGui.Add("Text", "x0 y+2  w270 Center BackgroundTrans c" p["cIdle"], "🕓   00:00")

    ; ── Action Buttons ────────────────────────
    SetFixedFont(MyGui, 9, "bold", "Semibold")
    RaceBtn   := MyGui.Add("Text", "x14 y+16 w242 h32 Center 0x200 Background" p["btnBg"] " c" p["btnText"], "🏁   RACE      \")
    BuyBtn    := MyGui.Add("Text", "x14 y+6  w119 h32 Center 0x200 Background" p["btnBg"] " c" p["btnText"], "🚗   BUY     [")
    UnlockBtn := MyGui.Add("Text", "x137 yp  w119 h32 Center 0x200 Background" p["btnBg"] " c" p["btnText"], "🛞   UNLOCK     ]")
    AllBtn    := MyGui.Add("Text", "x14 y+6  w242 h32 Center 0x200 Background" p["btnBg"] " c" p["btnText"], "⟲   INIT SEQUENCE     /")

    RaceBtn.OnEvent("Click",   (*) => StartRace())
    BuyBtn.OnEvent("Click",    (*) => StartBuy())
    UnlockBtn.OnEvent("Click", (*) => StartUnlock())
    AllBtn.OnEvent("Click",    (*) => ToggleAll())

    ; ══════════════════════════════════════════
    ;  TAB 2 — STATS
    ; ══════════════════════════════════════════
    TabControl.UseTab(2)

    ; ── Targets ───────────────────────────────
    SetFixedFont(MyGui, 9, "bold")
    MyGui.Add("Text", "x14 y+15 w242 Center BackgroundTrans c" p["header"],  "TARGETS")
    MyGui.Add("Text", "x14 y+0  w242 Center BackgroundTrans c" p["divider"], "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    PointsGain  := GetMinScore(SkillPtsWant_In.Value)
    PointsTotal := Min(PointsGain + SkillPtsCount_In.Value, 999)
    TimeTotal   := CalcTimeRace(SkillPtsWant_In.Value) + CalcTimeBuy(CarCount_In.Value) + CalcTimeUnlock(CarCount_In.Value)

    SetFixedFont(MyGui, 9, "norm", "Light")
    
    MyGui.Add("Text", "x22 y+6 w140 Left BackgroundTrans c" p["textDim"], "⟡  Est. Points Gain")
    PointsLabel_UI := _LinkNoirTelemetry(MyGui.Add("Text", "x162 yp w86 Right BackgroundTrans c" p["text"]), PointsGain)

    MyGui.Add("Text", "x22 y+4 w140 Left BackgroundTrans c" p["textDim"], "⟡  Est. Sectors")
    SectorLabel_UI := _LinkNoirTelemetry(MyGui.Add("Text", "x162 yp w86 Right BackgroundTrans c" p["text"]), Ceil(PointsGain / AveragePoints))

    MyGui.Add("Text", "x22 y+4 w140 Left BackgroundTrans c" p["textDim"], "⟡  Est. Total Time")
    TimeLabel_UI   := _LinkNoirTelemetry(MyGui.Add("Text", "x162 yp w86 Right BackgroundTrans c" p["text"]), Format("{:02}:{:02}", Floor(TimeTotal), Round((TimeTotal - Floor(TimeTotal)) * 60)))

    MyGui.Add("Text", "x22 y+4 w140 Left BackgroundTrans c" p["textDim"], "⟡  Recommended Car")
    CarsLabel_UI   := _LinkNoirTelemetry(MyGui.Add("Text", "x162 yp w86 Right BackgroundTrans c" p["text"]), Floor(PointsTotal / SelectedCarPoint))

    ; Event bindings for live recalculation
    SkillPtsCount_In.OnEvent("Change",    UpdateSkillPts)
    SkillPtsCount_In.OnEvent("LoseFocus", ValidateSkillPts)
    SkillPtsWant_In.OnEvent("Change",     UpdateSkillPtsWant)
    SkillPtsWant_In.OnEvent("LoseFocus",  ValidateSkillPtsWant)

    ; ── Live Progress Telemetry ───────────────
    SetFixedFont(MyGui, 9, "bold")
    MyGui.Add("Text", "x14 y+18 w242 Center BackgroundTrans c" p["header"],  "LIVE TELEMETRY")
    MyGui.Add("Text", "x14 y+0  w242 Center BackgroundTrans c" p["divider"], "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    SetFixedFont(MyGui, 9, "norm", "Light")
    
    MyGui.Add("Text", "x22 y+6 w140 Left BackgroundTrans c" p["textDim"], "🕓  Race Runtime")
    RaceRunTime_UI := _LinkNoirTelemetry(MyGui.Add("Text", "x162 yp w86 Right BackgroundTrans c" p["text"]), "00:00")

    MyGui.Add("Text", "x22 y+4 w140 Left BackgroundTrans c" p["textDim"], "💡  Points Gained")
    PointsCount_UI := _LinkNoirTelemetry(MyGui.Add("Text", "x162 yp w86 Right BackgroundTrans c" p["accent"]), "0")

    MyGui.Add("Text", "x22 y+4 w140 Left BackgroundTrans c" p["textDim"], "🏁  Sectors Cleared")
    SectorCount_UI := _LinkNoirTelemetry(MyGui.Add("Text", "x162 yp w86 Right BackgroundTrans c" p["text"]), "0")

    MyGui.Add("Text", "x22 y+12 w140 Left BackgroundTrans c" p["textDim"], "🚗  Buy Runtime")
    BuyRunTime_UI  := _LinkNoirTelemetry(MyGui.Add("Text", "x162 yp w86 Right BackgroundTrans c" p["text"]), "00:00")

    MyGui.Add("Text", "x22 y+4 w140 Left BackgroundTrans c" p["textDim"], "📦  Cars Purchased")
    CarCount_UI    := _LinkNoirTelemetry(MyGui.Add("Text", "x162 yp w86 Right BackgroundTrans c" p["text"]), "0")

    MyGui.Add("Text", "x22 y+12 w140 Left BackgroundTrans c" p["textDim"], "🕓  Unlock Runtime")
    UnlockRunTime_UI := _LinkNoirTelemetry(MyGui.Add("Text", "x162 yp w86 Right BackgroundTrans c" p["text"]), "00:00")

    MyGui.Add("Text", "x22 y+4 w140 Left BackgroundTrans c" p["textDim"], "🛞  Super Wheelspins")
    SWheelCount_UI := _LinkNoirTelemetry(MyGui.Add("Text", "x162 yp w86 Right BackgroundTrans c" p["accent"]), "0")

    MyGui.Add("Text", "x22 y+4 w140 Left BackgroundTrans c" p["textDim"], "🛞  Regular Wheelspins")
    WheelCount_UI  := _LinkNoirTelemetry(MyGui.Add("Text", "x162 yp w86 Right BackgroundTrans c" p["accent"]), "0")

    MyGui.Add("Text", "x22 y+4 w140 Left BackgroundTrans c" p["textDim"], "💲  Credits Earned")
    CreditCount_UI := _LinkNoirTelemetry(MyGui.Add("Text", "x162 yp w86 Right BackgroundTrans c" p["accent"]), "0 CR")

    ; ── Shared Content (outside tabs) ──────────
    TabControl.UseTab()

    MyGui.Add("Text", "x14 y+10 w242 Center BackgroundTrans c" p["divider"], "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    ; ── Redesigned Delay Slider ────────────────
    SetFixedFont(MyGui, 9, "norm")
    SpeedLabel_UI := MyGui.Add("Text", "x0 y+10 w270 Center c" p["text"], "Delay Multiplier: 1x")
    
    SetFixedFont(MyGui, 8, "norm")
    MyGui.Add("Text", "x15 y+8 w25 Right c" p["textDim"], "0.25x")
    DelaySlider_UI := MyGui.Add("Slider", "x45 yp-3 w180 Range1-7 +NoTicks", 4)
    MyGui.Add("Text", "x230 yp+3 w25 Left c" p["textDim"], "2.5x")
    
    DelaySlider_UI.OnEvent("Change", UpdateSpeed)

    ; ── Cyber Dropdown: Code Selector ─────────
    SetFixedFont(MyGui, 8, "bold")
    CodeSelect_UI := MyGui.Add("Text", "x85 y+5 w100 h24 Center 0x200 Background" p["editBg"] " c" p["text"])
    
    CodeSelect_UI.DefineProp("Value", {
        get: (this) => this.HasOwnProp("ctrlIndex") ? this.ctrlIndex : 1,
        set: (this, val) => (this.ctrlIndex := val, ControlSetText(CodeList[val] "   ▼", this.Hwnd, this.Gui.Hwnd))
    })
    CodeSelect_UI.DefineProp("Text", {
        get: (this) => CodeList[this.Value],
        set: (this, val) => ControlSetText(val, this.Hwnd, this.Gui.Hwnd)
    })
    CodeSelect_UI.Value := 1
    CodeSelect_UI.OnEvent("Click", ShowCodeMenu)

    ; ── Clickable Code Labels ─────────────────
    SetFixedFont(MyGui, 9, "norm", "Emoji")
    CodeTune_UI     := MyGui.Add("Text", "x0 y+5 w270 Center BackgroundTrans c" p["cIdle"], "Subaru 22B Tune Code")
    CodeEventLab_UI := MyGui.Add("Text", "x0 y+0 w270 Center BackgroundTrans c" p["cIdle"], "EventLab Race Code")

    CodeTune_UI.OnEvent("Click", (*) => _CopyToClip(CodeTune, "Subaru 22B Tune Code"))
    CodeEventLab_UI.OnEvent("Click", (*) => _CopyToClip(CodeEventLab, "EventLab Race Code"))

    ; ── Improved Cyber-Noir Styled Toggle Trigger ────────────────
    SetFixedFont(MyGui, 8, "bold", "Semibold")
    ToggleBtn := MyGui.Add("Text", "x65 y+15 w140 h24 Center 0x200 Background" p["btnBg2"] " c" p["btnText"], "⚙️  SPIN OPTIONS  ⏷")

    ; ── Collapsible Spin Section Grouping ─────
    SpinControls := []
    SetFixedFont(MyGui, 9, "norm", "Light")
    SpinControls.Push(lbl1 := MyGui.Add("Text", "x22 y+10 w140 Left BackgroundTrans c" p["textDim"], "🕓  Spin Runtime"))
    SpinControls.Push(SpinRunTime_UI := _LinkNoirTelemetry(MyGui.Add("Text", "x162 yp w86 Right BackgroundTrans c" p["text"]), "00:00"))

    SpinControls.Push(lbl2 := MyGui.Add("Text", "x22 y+0 w140 Left BackgroundTrans c" p["textDim"], "🎊  Spins Opened"))
    SpinControls.Push(SpinOpenCount_UI := _LinkNoirTelemetry(MyGui.Add("Text", "x162 yp w86 Right BackgroundTrans c" p["text"]), "0"))

    SpinControls.Push(lbl3 := MyGui.Add("Text", "x22 y+0 w140 Left BackgroundTrans c" p["textDim"], "🎁  Spins Remaining"))
    SpinControls.Push(SpinLeftCount_UI := _LinkNoirTelemetry(MyGui.Add("Text", "x162 yp w86 Right BackgroundTrans c" p["text"]), "0"))

    SetFixedFont(MyGui, 9, "bold", "Semibold")
    SpinControls.Push(KeepBtn := MyGui.Add("Text", "x14 y+16 w119 h24 Center 0x200 Background" p["activeBg"]   " c" p["text"], "💾   KEEP"))
    SpinControls.Push(SellBtn := MyGui.Add("Text", "x137 yp  w119 h24 Center 0x200 Background" p["inactiveBg"] " c" p["text"], "🏷️   SELL"))

    SetFixedFont(MyGui, 9, "bold", "Semibold")
    SpinControls.Push(SpinBtn := MyGui.Add("Text", "x14 y+6 w242 h32 Center 0x200 Background" p["btnBg"] " c" p["btnText"], "🎲   SPIN     ="))

    ; ── Sticky Bottom Footer Grouping ─────────
    FooterControls := []
    FooterControls.Push(F_Divider := MyGui.Add("Text", "x14 y+12 w242 h1 BackgroundTrans", ""))
    
    SetFixedFont(MyGui, 8, "norm")
    FooterControls.Push(ThemeBtn := MyGui.Add("Text", "x14 yp+5 w30 h26 Center 0x200 Background" p["btnBg2"] " c" p["btnText2"], DarkMode ? "☀" : "🌙"))
    ThemeBtn.OnEvent("Click", (*) => ToggleTheme())

    FooterControls.Push(VersionLink := MyGui.Add("Link", "xm+210 yp+12 Right", '<a href="https://github.com/M-Haziq-Iqbal/Forza-Horizon-6-Wheelspin-Macro/releases/tag/v1.6.0">v1.6.0</a>'))
    FooterControls.Push(BottomSpacer := MyGui.Add("Text", "x0 y+5 w270 h1 BackgroundTrans c" p["footer"], ""))

    KeepBtn.OnEvent("Click", (*) => TogglePair("KEEP", &SpinMode, KeepBtn, SellBtn, p))
    SellBtn.OnEvent("Click", (*) => TogglePair("SELL", &SpinMode, SellBtn, KeepBtn, p))
    SpinBtn.OnEvent("Click", (*) => StartSpin())

    MyGui.Show("w270 Hide")
    
    ToggleBtn.GetPos(, &tY, , &tH)
    F_Divider.GetPos(, &fY)
    shiftY := fY - (tY + tH + 15)
    
    footerOrigY := []
    for ctrl in FooterControls {
        ctrl.GetPos(, &cY)
        footerOrigY.Push(cY)
    }
    
    MyGui.GetPos(,, &w, &expandedH)
    compactH := expandedH - shiftY

    _OnOptionsToggle(btnObj, *) {
        static isOpen := false
        isOpen := !isOpen
        
        for ctrl in SpinControls
            ctrl.Visible := isOpen
            
        for i, ctrl in FooterControls {
            ctrl.Move(, isOpen ? footerOrigY[i] : (footerOrigY[i] - shiftY))
        }
        
        MyGui.Move(,,, isOpen ? expandedH : compactH)
        btnObj.Opt("Background" (isOpen ? p["activeBg"] : p["btnBg2"]))
        btnObj.Text := isOpen ? "⚙️  SPIN OPTIONS  ⏶" : "⚙️  SPIN OPTIONS  ⏷"
        btnObj.Redraw()
    }
    ToggleBtn.OnEvent("Click", _OnOptionsToggle)

    for ctrl in SpinControls
        ctrl.Visible := false
    for i, ctrl in FooterControls
        ctrl.Move(, footerOrigY[i] - shiftY)

    MyGui.OnEvent("Close", (*) => ExitApp())
    MyGui.OnEvent("Size",  MainGui_SizeChange)

    MonitorGetWorkArea(, &Left, &Top, &Right, &Bottom)
    monWidth  := Right  - Left
    monHeight := Bottom - Top
    
    MyGui.Move(Left + (monWidth // 2) + ((monWidth // 2) - w) // 2, Top + (monHeight - compactH) // 2, w, compactH)
    MyGui.Show()
}

; ══════════════════════════════════════════════
;  DROPDOWN EMULATION CONTROLLERS
; ══════════════════════════════════════════════
ShowCarMenu(ctrl, *) {
    global CarList
    carMenu := Menu()
    for index, carName in CarList {
        carMenu.Add(carName, MenuSelectCar.Bind(index))
    }
    carMenu.Show()
}

MenuSelectCar(index, *) {
    global CarSelect_UI
    CarSelect_UI.Value := index 
    try UpdateCar(CarSelect_UI, "")
}

ShowCodeMenu(ctrl, *) {
    global CodeList
    codeMenu := Menu()
    for index, codeName in CodeList {
        codeMenu.Add(codeName, MenuSelectCode.Bind(index))
    }
    codeMenu.Show()
}

MenuSelectCode(index, *) {
    global CodeSelect_UI
    CodeSelect_UI.Value := index 
    try UpdateCode(CodeSelect_UI, "")
}

; ══════════════════════════════════════════════
;  PRIVATE HELPERS  (module-scope, not nested)
; ══════════════════════════════════════════════

; Intercepts background text assignments containing strings/dashes, parses out raw values, and updates cleanly
_LinkNoirTelemetry(ctrl, initialValue) {
    ctrl.DefineProp("Text", {
        get: (this) => ControlGetText(this.Hwnd, this.Gui.Hwnd),
        set: (this, val) => (
            RegExMatch(val, "[—–-]\s*(.*)$", &match) 
            ? ControlSetText(match[1], this.Hwnd, this.Gui.Hwnd) 
            : ControlSetText(val, this.Hwnd, this.Gui.Hwnd)
        )
    })
    ctrl.Text := initialValue
    return ctrl
}

_CopyToClip(text, label) {
    A_Clipboard := text
    ToolTip(label " Copied!  " text)
    SetTimer(() => ToolTip(), -2000)
}