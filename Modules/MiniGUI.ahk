; ╔═════════════════════════════════════════╗
; ║        MHI - FH6 Wheelspin Macro        ║
; ║        Cyber Noir Edition v1.8.0        ║
; ╚═════════════════════════════════════════╝

; ══════════════════════════════════════════════
;  RESOLUTION-RELATIVE MATRIX CONFIGURATION
; ══════════════════════════════════════════════
Global MiniGui             := Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale")
Global p                   := GetPalette()
Global RestoreBtn, PauseBtn, StopBtn
Global RaceControls := [], BuyControls := [], UnlockControls := []

; 1. Fetch target game monitor dimensions in raw physical pixels
gameMonitorIndex := GetGameMonitor()
MonitorGet(gameMonitorIndex, &mLeft, &mTop, &mRight, &mBottom)
Global MonWidth            := mRight - mLeft
Global MonHeight           := mBottom - mTop

; 2. Define Ratios relative to 1440p baseline workspace (2560x1440)
Global ScaleX              := MonWidth / 2560
Global ScaleY              := MonHeight / 1440

; 3. Calculate Font Matrix (Neutralizes Windows OS DPI, scales via Display Area)
DpiScale                   := A_ScreenDPI / 96
Global FontScale           := ScaleX / DpiScale

; 4. Resolution-Relative UI Bounding Boxes
Global TargetWidgetWidth   := Round(230 * ScaleX)
Global CurrentWidgetHeight := Round(225 * ScaleY) 
WidgetPadding              := Round(15 * ScaleX)
StartY                     := Round(115 * ScaleY)

; Deep obsidian canvas background
MiniGui.BackColor          := "111216"

; Left accent status bar (Electric Neon Cyan)
Global LeftAccentBar       := MiniGui.Add("Progress", "x0 y0 w" Round(4 * ScaleX) " h" CurrentWidgetHeight " Background00D2FF")

; --- HEADER SECTION ---
MiniGui.SetFont("s" (8 * FontScale) " bold c00D2FF", "Segoe UI")
MiniGui.Add("Text", "x" Round(15*ScaleX) " y" Round(12*ScaleY) " w" Round(110*ScaleX) " h" Round(16*ScaleY) " BackgroundTrans", "⚙️ FH6 MACRO ")

MiniGui.SetFont("s" (10 * FontScale) " bold")

RestoreBtn := MiniGui.Add("Text", "x" Round(195*ScaleX) " y" Round(10*ScaleY) " w" Round(20*ScaleX) " h" Round(20*ScaleY) " Center Background22252E c64748B", "⛶")
RestoreBtn.OnEvent("Click", RestoreMainWindow)

ReloadBtn := MiniGui.Add("Text", "x" Round(173*ScaleX) " y" Round(10*ScaleY) " w" Round(20*ScaleX) " h" Round(20*ScaleY) " Center Background22252E c94A3B8", "⭮")
ReloadBtn.OnEvent("Click", (*) => Reload())

LockBtn := MiniGui.Add("Text", "x" Round(151*ScaleX) " y" Round(10*ScaleY) " w" Round(20*ScaleX) " h" Round(20*ScaleY) " Center Background22252E c94A3B8", "🔒")
LockBtn.OnEvent("Click", (ctrl, *) => ToggleWindowLock(ctrl))

global AlwaysOnTopBtn := MiniGui.Add("Text", "x" Round(129*ScaleX) " y" Round(10*ScaleY) " w" Round(20*ScaleX) " h" Round(20*ScaleY) " Center Background22252E c94A3B8", "📌")
AlwaysOnTopBtn.OnEvent("Click", (ctrl, *) => AlwaysOnTopEnable(ctrl))

ResoSetBtn := MiniGui.Add("Text", "x" Round(107*ScaleX) " y" Round(10*ScaleY) " w" Round(20*ScaleX) " h" Round(20*ScaleY) " Center Background22252E c94A3B8", "🗗")
ResoSetBtn.OnEvent("Click", (ctrl, *) => SetGameResolution(ctrl))

InitStartBtn := MiniGui.Add("Text", "x" Round(195*ScaleX) " y" Round(70*ScaleY) " w" Round(18*ScaleX) " h" Round(18*ScaleY) " Center Background22252E c94A3B8", "⬤")
InitStartBtn.OnEvent("Click", (ctrl, *) => MiniInitStartMacro(ctrl))

; Flat Premium Action Buttons (Header Control Bar)
MiniGui.SetFont("s" (9 * FontScale) " bold")

global PauseBtn := MiniGui.Add("Text", "x" Round(170*ScaleX) " y" StartY " w" Round(18*ScaleX) " h" Round(18*ScaleY) " Center Background22252E cFFD166","❚❚")
PauseBtn.OnEvent("Click", (ctrl, *) => MiniTogglePause(ctrl))

global StopBtn := MiniGui.Add("Text", "x" Round(195*ScaleX) " y" StartY " w" Round(18*ScaleX) " h" Round(18*ScaleY) " Center Background22252E cFF5A5A", "⏹")
StopBtn.OnEvent("Click", (ctrl, *) => MiniStopMacro(ctrl))

; --- SYSTEM STATUS SECTION (Always Visible) ---
MiniGui.SetFont("s" (9 * FontScale) " norm c8A99AD", "Segoe UI")
Global MiniTotalRunTime_UI := MiniGui.Add("Text", "x" Round(15*ScaleX) " y35" " w" Round(180*ScaleX) " h" Round(16*ScaleY) " BackgroundTrans", "🕓  00:00")
Global MiniKey_UI          := MiniGui.Add("Text", "x" Round(15*ScaleX) " y+" Round(2*ScaleY) " w" Round(180*ScaleX) " h" Round(16*ScaleY) " BackgroundTrans", "⌨  [   ]")
Global MiniProcess_UI      := MiniGui.Add("Text", "x" Round(15*ScaleX) " y+" Round(2*ScaleY) " w" Round(180*ScaleX) " h" Round(30*ScaleY) " BackgroundTrans", "⚙️  Waiting...")

; Premium subtle dark divider line
MiniGui.Add("Progress", "x" Round(15*ScaleX) " y+" Round(6*ScaleY) " w" Round(190*ScaleX) " h" Round(1*ScaleY) " Background22252E")

; --- ADAPTIVE SECTION 1: RACE TELEMETRY ---
MiniGui.SetFont("s" (7 * FontScale) " bold c566273", "Segoe UI")
RaceControls.Push(MiniGui.Add("Text", "x" Round(15*ScaleX) " y" StartY " w" Round(190*ScaleX) " h" Round(12*ScaleY) " BackgroundTrans c00D2FF", "◼ RACE PROGRESS"))

MiniGui.SetFont("s" (9 * FontScale) " norm c8A99AD", "Segoe UI")
RaceControls.Push(MiniGui.Add("Text", "x" Round(15*ScaleX) " y+" Round(6*ScaleY) " w" Round(140*ScaleX) " h" Round(16*ScaleY) " BackgroundTrans", "🕓  Race Runtime"))
RaceControls.Push(MiniRaceRunTime_UI := _LinkNoirTelemetry(MiniGui.Add("Text", "x" Round(155*ScaleX) " yp w" Round(60*ScaleX) " h" Round(16*ScaleY) " Right BackgroundTrans cF3F4F6"), "00:00"))

RaceControls.Push(MiniGui.Add("Text", "x" Round(15*ScaleX) " y+" Round(4*ScaleY) " w" Round(140*ScaleX) " h" Round(16*ScaleY) " BackgroundTrans", "💡  Points Gained"))
RaceControls.Push(MiniPointsCount_UI := _LinkNoirTelemetry(MiniGui.Add("Text", "x" Round(155*ScaleX) " yp w" Round(60*ScaleX) " h" Round(16*ScaleY) " Right BackgroundTrans cF3F4F6"), "0"))

RaceControls.Push(MiniGui.Add("Text", "x" Round(15*ScaleX) " y+" Round(4*ScaleY) " w" Round(140*ScaleX) " h" Round(16*ScaleY) " BackgroundTrans", "🏁  Sectors Cleared"))
RaceControls.Push(MiniSectorCount_UI := _LinkNoirTelemetry(MiniGui.Add("Text", "x" Round(155*ScaleX) " yp w" Round(60*ScaleX) " h" Round(16*ScaleY) " Right BackgroundTrans cF3F4F6"), "0"))


; --- ADAPTIVE SECTION 2: CAR PURCHASE ---
MiniGui.SetFont("s" (7 * FontScale) " bold c566273", "Segoe UI")
BuyControls.Push(MiniGui.Add("Text", "x" Round(15*ScaleX) " y" StartY " w" Round(190*ScaleX) " h" Round(12*ScaleY) " BackgroundTrans c00D2FF", "◼ CAR PURCHASE"))

MiniGui.SetFont("s" (9 * FontScale) " norm c8A99AD", "Segoe UI")
BuyControls.Push(MiniGui.Add("Text", "x" Round(15*ScaleX) " y+" Round(6*ScaleY) " w" Round(140*ScaleX) " h" Round(16*ScaleY) " BackgroundTrans", "🕓  Buy Runtime"))
BuyControls.Push(MiniBuyRunTime_UI := _LinkNoirTelemetry(MiniGui.Add("Text", "x" Round(155*ScaleX) " yp w" Round(60*ScaleX) " h" Round(16*ScaleY) " Right BackgroundTrans cF3F4F6"), "00:00"))

BuyControls.Push(MiniGui.Add("Text", "x" Round(15*ScaleX) " y+" Round(4*ScaleY) " w" Round(140*ScaleX) " h" Round(16*ScaleY) " BackgroundTrans", "📦  Cars Purchased"))
BuyControls.Push(MiniCarCount_UI := _LinkNoirTelemetry(MiniGui.Add("Text", "x" Round(155*ScaleX) " yp w" Round(60*ScaleX) " h" Round(16*ScaleY) " Right BackgroundTrans cF3F4F6"), "0"))


; --- ADAPTIVE SECTION 3: REWARDS UNLOCK ---
MiniGui.SetFont("s" (7 * FontScale) " bold c566273", "Segoe UI")
UnlockControls.Push(MiniGui.Add("Text", "x" Round(15*ScaleX) " y" StartY " w" Round(190*ScaleX) " h" Round(12*ScaleY) " BackgroundTrans c00D2FF", "◼ REWARDS UNLOCK"))

MiniGui.SetFont("s" (9 * FontScale) " norm c8A99AD", "Segoe UI")
UnlockControls.Push(MiniGui.Add("Text", "x" Round(15*ScaleX) " y+" Round(6*ScaleY) " w" Round(140*ScaleX) " h" Round(16*ScaleY) " BackgroundTrans", "🕓  Unlock Runtime"))
UnlockControls.Push(MiniUnlockRunTime_UI := _LinkNoirTelemetry(MiniGui.Add("Text", "x" Round(155*ScaleX) " yp w" Round(60*ScaleX) " h" Round(16*ScaleY) " Right BackgroundTrans cF3F4F6"), "00:00"))

UnlockControls.Push(MiniGui.Add("Text", "x" Round(15*ScaleX) " y+" Round(4*ScaleY) " w" Round(140*ScaleX) " h" Round(16*ScaleY) " BackgroundTrans", "🌟  Super Wheelspins"))
UnlockControls.Push(MiniSWheelCount_UI := _LinkNoirTelemetry(MiniGui.Add("Text", "x" Round(155*ScaleX) " yp w" Round(60*ScaleX) " h" Round(16*ScaleY) " Right BackgroundTrans cF3F4F6"), "0"))

UnlockControls.Push(MiniGui.Add("Text", "x" Round(15*ScaleX) " y+" Round(4*ScaleY) " w" Round(140*ScaleX) " h" Round(16*ScaleY) " BackgroundTrans", "🛞  Regular Wheelspins"))
UnlockControls.Push(MiniWheelCount_UI := _LinkNoirTelemetry(MiniGui.Add("Text", "x" Round(155*ScaleX) " yp w" Round(60*ScaleX) " h" Round(16*ScaleY) " Right BackgroundTrans cF3F4F6"), "0"))

UnlockControls.Push(MiniGui.Add("Text", "x" Round(15*ScaleX) " y+" Round(4*ScaleY) " w" Round(140*ScaleX) " h" Round(16*ScaleY) " BackgroundTrans", "💲  Credits Earned"))
UnlockControls.Push(MiniCreditCount_UI := _LinkNoirTelemetry(MiniGui.Add("Text", "x" Round(145*ScaleX) " yp w" Round(70*ScaleX) " h" Round(16*ScaleY) " Right BackgroundTrans cF3F4F6"), "0 CR"))

;SetInitial UI state safely
UpdateMiniWidgetMode("")

; ══════════════════════════════════════════════
;  ADAPTIVE VISIBILITY & FRAME RESIZE ENGINE
; ══════════════════════════════════════════════
UpdateMiniWidgetMode(activeMode) {
    global CurrentWidgetHeight, LeftAccentBar, MiniGui, ScaleY
    global RaceControls, BuyControls, UnlockControls
    
    for ctrl in RaceControls
        ctrl.Visible := false
    for ctrl in BuyControls
        ctrl.Visible := false
    for ctrl in UnlockControls
        ctrl.Visible := false

    switch StrLower(activeMode) {
        case "race":
            for ctrl in RaceControls
                ctrl.Visible := true
            targetHeight := Round(195 * ScaleY)
            
        case "buy":
            for ctrl in BuyControls
                ctrl.Visible := true
            targetHeight := Round(175 * ScaleY)
            
        case "unlock":
            for ctrl in UnlockControls
                ctrl.Visible := true
            targetHeight := Round(215 * ScaleY)
            
        default:
            targetHeight := Round(100 * ScaleY)
    }

    CurrentWidgetHeight := targetHeight
    LeftAccentBar.Move(,,, targetHeight)
    MiniGui.Move(,,, targetHeight)
    WinRedraw(MiniGui.Hwnd)
}

; ══════════════════════════════════════════════
;  BUTTON ACTION INTERFACES
; ══════════════════════════════════════════════
MiniTogglePause(ctrl) {
    global MasterMode, ActiveMode
    
    TogglePause()

    if !PauseMode && ActiveMode {
        ctrl.Opt("cFFD166")
        ctrl.Value := "❚❚"
    }
    else if PauseMode && ActiveMode {
        ctrl.Opt("cFFD166")
        ctrl.Value := "▶"
    }
}

MiniStopMacro(ctrl) {
    global MasterMode, ActiveMode, PauseBtn

    if MasterMode
        ToggleAll()
    else
        switch ActiveMode {
            case "Race": StartRace()
            case "Buy": StartBuy()
            case "Unlock": StartUnlock()
            default: 
        }
    
    if !ActiveMode || (!MasterMode && MasterStart) {
        ctrl.Opt("c94A3B8")
        PauseBtn.Opt("c94A3B8")
        PauseBtn.Value := "❚❚"
    }
}

MiniInitStartMacro(ctrl) {
    global MasterMode, ActiveMode, PauseBtn

    ctrl.Opt("c22C55E")
    PauseBtn.Opt("cFFD166")
    PauseBtn.Value := "❚❚"
    StopBtn.Opt("cFF5A5A")

    ToggleAll()

    ctrl.Opt("c94A3B8")
    PauseBtn.Opt("c94A3B8")
    PauseBtn.Value := "❚❚"
    StopBtn.Opt("c94A3B8")
}

; ══════════════════════════════════════════════
;  SIZE CHANGE TRIGGER (Dynamic Top-Right Screen Snap)
; ══════════════════════════════════════════════
MainGUI_SizeChange(thisGui, minMax, *) {
    global TargetWidgetWidth, CurrentWidgetHeight, WidgetPadding
    
    if (minMax == -1) {
        thisGui.Hide()
        
        gameMonitorIndex := GetGameMonitor()
        MonitorGet(gameMonitorIndex, &mLeft, &mTop, &mRight, &mBottom)
        
        miniX := mRight - TargetWidgetWidth - WidgetPadding
        miniY := mTop + WidgetPadding
        
        MiniGui.Show("x" miniX " y" miniY " w" TargetWidgetWidth " h" CurrentWidgetHeight " NoActivate")
        WinSetTransparent(180, MiniGui.Hwnd)
    }
}

DragMiniGui() {
    global MiniGui, DragOffsetX, DragOffsetY
    
    if !GetKeyState("LButton", "P") {
        SetTimer(, 0)
        return
    }
    
    CoordMode("Mouse", "Screen")
    MouseGetPos(&mouseX, &mouseY)
    
    MiniGui.Move(mouseX - DragOffsetX, mouseY - DragOffsetY)
}

RestoreMainWindow(*) {
    MiniGui.Hide()
    MainGUI.Show()
}

; ══════════════════════════════════════════════
;  NOTIFICATION TOAST (Relative Resolution Scale Engine)
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
            duration    := -8000
    }

    ; ── INTERSECT DETECTION ROUTING ──
    ; Calls formula to pull the best monitor index
    targetMon := GetGameMonitor()

    ; Fetch bounding limits for the specific display containing the game
    MonitorGet(targetMon, &mLeft, &mTop, &mRight, &mBottom)
    mWidth  := mRight - mLeft
    mHeight := mBottom - mTop
    
    ; Local scaling factors calculated against the game screen's real footprint
    sX     := mWidth / 2560
    sY     := mHeight / 1440
    fScale := sX / (A_ScreenDPI / 96)

    ; Removed +E0x20 to make the notification interactive/clickable
    Notif := Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale")
    Notif.BackColor := "181A1F"
    Notif.Add("Progress", "x0 y0 w" Round(6*sX) " h" Round(70*sY) " Background" accentColor)
    
    ; Notification Title (Width narrowed to 235*sX to clear room for the X button)
    Notif.SetFont("s" (10 * fScale) " bold c" accentColor, "Segoe UI")
    Notif.Add("Text", "x" Round(15*sX) " y" Round(10*sY) " w" Round(235*sX) " BackgroundTrans", icon title)
    
    ; Notification Body Message
    Notif.SetFont("s" (9 * fScale) " norm cEEEEEE", "Segoe UI")
    Notif.Add("Text", "x" Round(15*sX) " y+" Round(5*sY) " w" Round(235*sX) " h" Round(35*sY) " BackgroundTrans", message)

    ; ── CLOSE BUTTON ("X") ──
    Notif.SetFont("s" (11 * fScale) " norm c888888", "Segoe UI")
    closeBtn := Notif.Add("Text", "x" Round(255*sX) " y" Round(8*sY) " w" Round(15*sX) " h" Round(15*sY) " Center BackgroundTrans", "×")
    closeBtn.OnEvent("Click", (*) => Notif.Destroy())

    tWidth  := Round(280 * sX)
    tHeight := Round(70 * sY)
    Notif.Show("w" tWidth " h" tHeight " Hide")
    
    ; Pins the notification precisely inside the workspace boundaries of that display
    notifX := mRight - tWidth - Round(10 * sX)
    notifY := mBottom - tHeight - Round(10 * sY)

    WinMove(notifX, notifY,,, Notif.Hwnd)
    Notif.Show("NoActivate")
    SetTimer(() => Notif.Destroy(), duration)
}

global OverlayGui       := ""
global OverlayGuiEnabled := false

ToggleDetectionZone() {
    global OverlayGui, OverlayGuiEnabled, GameTitle
    
    if !OverlayGuiEnabled {
        OverlayGuiEnabled := !OverlayGuiEnabled

        ; 1. Get the game's unique operating system ID (HWND)
        gameHwnd := WinExist(GameTitle)
        if !gameHwnd
            return

        if (OverlayGui) 
            return

        ; 2. TRICK 1: Add "+Owner" followed immediately by the game's HWND.
        ; This explicitly chains the overlay's rendering layer to sit in front of the game.
        OverlayGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20 +Owner" gameHwnd)
        
        OverlayGui.BackColor := "Red" 
        WinSetTransparent(5, OverlayGui.Hwnd) 

        ; Start tracking loop
        SetTimer(UpdateOverlayPosition, 50)
    } else if OverlayGuiEnabled {
        OverlayGuiEnabled := !OverlayGuiEnabled

        SetTimer(UpdateOverlayPosition, 0) 
        if (OverlayGui) {
            OverlayGui.Destroy()
            OverlayGui := ""
        }
    }
}

UpdateOverlayPosition() {
    global OverlayGuiEnabled, GameTitle
    
    if !WinExist(GameTitle) {
        OverlayGuiEnabled := true
        ToggleDetectionZone()
        return
    }
    
    WinGetPos(&gameX, &gameY, &gameW, &gameH, GameTitle)
    
    leftOffset := Integer(gameW * (1 / 3))
    targetW    := Integer(gameW * (2 / 3))
    targetH    := gameH
    
    targetX := gameX + leftOffset
    targetY := gameY

    OverlayGui.Show("X" targetX " Y" targetY " W" targetW " H" targetH " NoActivate")
    
    ; 3. TRICK 2: Use a low-level Windows API call to forcefully jump the overlay 
    ; to the absolute top of the stack, preventing the active game from reclaiming the lead.
    ; HWND_TOPMOST = -1 | SWP_NOSIZE (0x0001) | SWP_NOMOVE (0x0002) = 0x0003
    DllCall("SetWindowPos", "Ptr", OverlayGui.Hwnd, "Ptr", -1, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 0x0003)
}