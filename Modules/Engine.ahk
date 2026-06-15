; ╔═════════════════════════════════════════╗
; ║        MHI - FH6 Wheelspin Macro		║
; ║        Cyber Noir Edition v1.4.0        ║
; ╚═════════════════════════════════════════╝

#Requires AutoHotkey v2.0

#Include UI.ahk
#Include Task_Race.ahk
#Include Task_Buy.ahk
#Include Task_Unlock.ahk

; ══════════════════════════════════════════════
;  LOOP COORDINATION MECHANICS
; ══════════════════════════════════════════════

TogglePause() {
    global ActiveMode, PauseMode, StatusText, cIdle, cPaused, cStat, MasterMode
    Pause(-1)
    PauseMode := !PauseMode

    if (PauseMode && ActiveMode) {
        StatusText.Value := "⬤  Paused..."
        StatusText.SetFont("c" cPaused)
    } else if ActiveMode {
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
    global SkillPtsCount_In, SkillPtsWant_In, CarCount_In, LoopCount_In
    global MaxPoints, PointsGain, SelectedCarPoint, cHighlight, cIdle

    StartIndicators()
    MasterMode := !MasterMode
    LoopCount := 0

    while (MasterMode && LoopCount < LoopCount_In.Value) {
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
        LoopCount++
        LoopCount_In.Value -= LoopCount
    }
    MasterMode := ""
    MasterStart := false
    ResetIndicators()
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
    DelaySlider_UI.Enabled := false
    CodeSelect_UI.Enabled := false
    LoopCount_In.Enabled := false

    SetTimer(TotalTimerTick, 1000)
}

ResetIndicators() {
    global Key_UI, Process_UI, StatusText, cIdle, cTextDim
    global TotalRunTime_UI, RaceRunTime_UI, BuyRunTime_UI, UnlockRunTime_UI, SectorCount, ActiveMode, MasterMode
    global SkillPtsCount_In, SkillPtsWant_In, CarCount_In, CarSelect_UI, PremiumCheck_UI

    SetTimer(RaceTimerTick, 0)
    SetTimer(BuyTimerTick, 0)
    SetTimer(UnlockTimerTick, 0)
    if (!MasterMode) {
        SetTimer(TotalTimerTick, 0)
    }
    ActiveMode := ""
    Key_UI.Value := "⌨  [   ]"
    Key_UI.SetFont("c" cIdle)
    Process_UI.Value := "⚙️  Waiting..."
    
    Process_UI.SetFont("c" cIdle)
    TotalRunTime_UI.SetFont("c" cIdle)
    RaceRunTime_UI.SetFont("c" cIdle)
    BuyRunTime_UI.SetFont("c" cIdle)
    UnlockRunTime_UI.SetFont("c" cIdle)
    PointsCount_UI.SetFont("c" cIdle)
    SectorCount_UI.SetFont("c" cIdle)
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
    DelaySlider_UI.Enabled := true
    CodeSelect_UI.Enabled := true
    LoopCount_In.Enabled := true

}

; ══════════════════════════════════════════════
;  UPDATE VALUE INPUT
; ══════════════════════════════════════════════
UpdateCode(ctrl, *) {
    global SelectedCode, MaxPoints, MaxSections, AveragePoints, SkillPtsCount_In, SkillPtsWant_In, CarCount_In, PointsTotal, CodeTune, CodeEventLab

    SelectedCode:= ctrl.Text

    MaxSections := SelectedCode = "AMMAGEDON" ? 100 : 96
    MaxPoints := SelectedCode = "AMMAGEDON" ? 990 : 940
    AveragePoints := SelectedCode = "AMMAGEDON" ? 9.9 : 9.8
    
    CodeTune := CodeSelect_UI.Text = "AMMAGEDON" ?  "206657706" : "293391902"
    CodeEventLab := CodeSelect_UI.Text = "AMMAGEDON" ? "102089819" : "124198343"
    
    SkillPtsWant_In.Value := UpdateSkillPtsWant({Value: MaxPoints})
    CarCount_In.Value := Floor(PointsTotal / SelectedCarPoint)
}

UpdateCar(ctrl,*) {
    global SelectedCar, SelectedCarPoint, PointsTotal, CarSelect_UI, CarsLabel_UI, CarCount_In
    
    SelectedCar := ctrl.Text
    SelectedCarPoint := CarSelect_UI.Text = "Lamborghini Revuelto" ? 39 : 30

    CarPurchaseCount := Floor(PointsTotal / SelectedCarPoint)
        
    CarCount_In.Value :=  CarPurchaseCount
    CarsLabel_UI.Value := "Recommended Car Purchase  —  " CarPurchaseCount
}

UpdateSkillPts(ctrl, *) {
    global SelectedCarPoint, TimeTotal, PointsTotal, CarCount_In, SkillPtsWant_In, SelectedCarPoint, AveragePoints, PointsGain, MaxPoints
    global PointsLabel_UI, TimeLabel_UI, CarsLabel_UI, SectorLabel_UI, ActiveMode, CustomSkillPts

    CustomSkillPts := false

    value := ctrl.value
    value := value = "" ? 0 : Min(999, value)
	
    SkillPtsWant_In.Value := 999 - value > MaxPoints ? MaxPoints : 999 - value

    PointsGain := GetMinScore(SkillPtsWant_In.Value)	
    PointsTotal := Min(PointsGain + value, 999)
    	
    CarCount_In.Value := Floor(PointsTotal / SelectedCarPoint)
	TimeTotal := CalcTimeRace(SkillPtsWant_In.Value)  + CalcTimeBuy(CarCount_In.Value) + CalcTimeUnlock(CarCount_In.Value)

    PointsLabel_UI.Value := "Est. Skill Points Gain  —  " PointsGain
    SectorLabel_UI.Value := "Est. Sectors Count  —  " Ceil(PointsGain/AveragePoints)
    TimeLabel_UI.Value :=  "Est. Total Time Completion  —  " Format("{:02}:{:02}", Floor(TimeTotal) , Round((TimeTotal - Floor(TimeTotal)) * 60))
    CarsLabel_UI.Value := "Recommended Car Purchase  —  " Floor(PointsTotal / SelectedCarPoint)
}
    
UpdateSkillPtsWant(ctrl, *) {

    global SelectedCarPoint, TimeTotal, PointsTotal, CarCount_In, SkillPtsCount_In, SelectedCarPoint, AveragePoints, PointsGain, MaxPoints
    global PointsLabel_UI, TimeLabel_UI, CarsLabel_UI, PointsCount_UI, SectorLabel_UI, CustomSkillPts

    CustomSkillPts := true

    value := ctrl.value
	
    if (value = "") 
        value := 0
    else if (value + SkillPtsCount_In.Value > 999)
        value := 999 - SkillPtsCount_In.Value
    else if (value > MaxPoints)
        value := MaxPoints

    PointsGain := GetMinScore(value)
    PointsTotal := Min(PointsGain + SkillPtsCount_In.Value, 999)
	
    CarCount_In.Value := Floor(PointsTotal / SelectedCarPoint)
	TimeTotal := CalcTimeRace(value) + CalcTimeBuy(CarCount_In.Value) + CalcTimeUnlock(CarCount_In.Value)
    
    PointsLabel_UI.Value := "Est. Skill Points Gain  —  " PointsGain
    SectorLabel_UI.Value := "Est. Sectors Count  —  " Ceil(PointsGain/AveragePoints)
    TimeLabel_UI.Value :=  "Est. Total Time Completion  —  " Format("{:02}:{:02}", Floor(TimeTotal) , Round((TimeTotal - Floor(TimeTotal)) * 60))
    CarsLabel_UI.Value := "Recommended Car Purchase  —  " Floor(PointsTotal / SelectedCarPoint)

    return value
}

ValidateSkillPts(ctrl, *) {
    global SkillPtsCount_In
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
    global SelectedCode, MaxPoints, MaxSections

    pointsPerSection := MaxPoints / MaxSections
    sections := Ceil(score / pointsPerSection)
    return Floor(sections * pointsPerSection)
}

CalcTimeRace(score) {
    global MaxSections, SelectedCode

    StartLoadingTime	:= 52
    MidLoadingTime      := 20
    FinLoadingTime	    := 40

    pointsPerSection := MaxPoints / MaxSections
    secPerSection := SelectedCode = "AMMAGEDON"? 20 : 30
    secPerRow := SelectedCode = "AMMAGEDON" ? 4 :7
    sectionsPerRow := SelectedCode = "AMMAGEDON" ? 1 : 4


    sections := Ceil(score / pointsPerSection)
    rows := Ceil(sections / sectionsPerRow)

    totalTime := StartLoadingTime + (sections * secPerSection) + (rows * secPerRow) + MidLoadingTime + FinLoadingTime

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

; ══════════════════════════════════════════════
;  TIMER TICK  (fires every second while running)
; ══════════════════════════════════════════════
TotalTimerTick() {
    global TotalRunSeconds, TotalRunTime_UI, cHighlight
    TotalRunSeconds++
    mins := TotalRunSeconds // 60
    secs := Mod(TotalRunSeconds, 60)

    TotalRunTime_UI.Value := "🕓  " Format("{:02d}:{:02d}", mins, secs)
}

RaceTimerTick() {
    global RaceRunSeconds, RaceRunTime_UI, cHighlight
    RaceRunSeconds++
    mins := RaceRunSeconds // 60
    secs := Mod(RaceRunSeconds, 60)

    RaceRunTime_UI.Value := "🕓   Race Time Running   —   " Format("{:02d}:{:02d}", mins, secs)
}

BuyTimerTick() {
    global BuyRunSeconds, BuyRunTime_UI, cHighlight
    BuyRunSeconds++
    mins := BuyRunSeconds // 60
    secs := Mod(BuyRunSeconds, 60)

    BuyRunTime_UI.Value := "🕓   Buy Time Running   —   " Format("{:02d}:{:02d}", mins, secs)
}

UnlockTimerTick() {
    global UnlockRunSeconds, UnlockRunTime_UI, cHighlight
    UnlockRunSeconds++
    mins := UnlockRunSeconds // 60
    secs := Mod(UnlockRunSeconds, 60)

    UnlockRunTime_UI.Value := "🕓   Unlock Time Running   —   " Format("{:02d}:{:02d}", mins, secs)
}
; ══════════════════════════════════════════════
;  PIXEL DETECTION
; ══════════════════════════════════════════════

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

WaitForMenuRelative(text, ratioX, ratioY, targetColor, targetColorHDR := "", timeoutMs := 8000, postDelayMs := 1000, isFatal := false, variation := 0) {
    global ActiveMode, MasterMode, MasterStart, CurrentMultiplier
    CoordMode("Pixel", "Screen") 
    StartTime := A_TickCount
    LastSec := -1 ; ── Tracks seconds to prevent spamming your status window
    
    actualX := Round(ratioX * A_ScreenWidth)
    actualY := Round(ratioY * A_ScreenHeight)

    timeoutMs *= CurrentMultiplier
    postDelayMs *= CurrentMultiplier

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
                Process("Sync Warning: Pixel missed. Proceeding blindly...", 2000)
                return true 
            }
        }
        Sleep(50) 
    }
}

SkillPtsScan(ratioX, ratioY, ratioW, ratioH, delay:= 1000) {
    global SkillPtsCount_In, SkillPtsWant_In, CarCount_In
    global PointsLabel_UI, SectorLabel_UI, TimeLabel_UI, CarsLabel_UI
    global ActiveMode, MaxPoints, CustomSkillPts, PointsGain, PointsTotal, TimeTotal, SelectedCarPoint

    Sleep(delay)

    points := GetSkillPointsRelative(ratioX, ratioY, ratioW, ratioH)

    if (points = -1)
        points := SkillPtsCount_In.Value

    ToolTip "Current Skill Points: " points
    SetTimer(() => ToolTip(), -2000)

    SkillPtsCount_In.Value := points

    if RaceStart {
        SkillPtsWant_In.Value := CustomSkillPts ? Min(SkillPtsWant_In.Value, MaxPoints - SkillPtsCount_In.Value) : Min(999 - points, MaxPoints)

        PointsGain := GetMinScore(SkillPtsWant_In.Value)
        PointsTotal := Min(PointsGain + SkillPtsCount_In.Value, 999)
        CarCount_In.Value := Floor(PointsTotal / SelectedCarPoint)

        TimeTotal := CalcTimeRace(SkillPtsWant_In.Value)  + CalcTimeBuy(CarCount_In.Value) + CalcTimeUnlock(CarCount_In.Value)

        PointsLabel_UI.Value := "Est. Skill Points Gain  —  " PointsGain
        SectorLabel_UI.Value := "Est. Sectors Count  —  " Ceil(PointsGain/AveragePoints)
        TimeLabel_UI.Value :=  "Est. Total Time Completion  —  " Format("{:02}:{:02}", Floor(TimeTotal) , Round((TimeTotal - Floor(TimeTotal)) * 60))
        CarsLabel_UI.Value := "Recommended Car Purchase  —  " Floor(PointsTotal / SelectedCarPoint)
    }

    ;UpdateSkillPts({Value:points})

    return points
}

GetSkillPointsRelative(ratioX, ratioY, ratioW, ratioH) {
    ; 1. Setup the bounding box based on your exact coordinates
    startX := Round(ratioX * A_ScreenWidth)
    startY := Round(ratioY * A_ScreenHeight)
    width  := Round(ratioW * A_ScreenWidth)
    height := Round(ratioH * A_ScreenHeight)

    try {
        ; 2. Scan the box
        result := OCR.FromRect(startX, startY, width, height)
        scannedText := result.Text

        ; ── 🔎 TEMPORARY DEBUG TOOL ──────────────────────────────────────────
        ToolTip("OCR Sees: '" scannedText "'") 
        SetTimer () => ToolTip(), -4000 
        ; ─────────────────────────────────────────────────────────────────────
        
        ; 1. Handle the "No Skill Points" edge case
        if InStr(scannedText, "No Skill Points") {
            return 0
        }
        
        ; 2. If it's not "No", look for the actual number
        if (result.Words.Length > 0) {
            firstWord := result.Words[1].Text ; Grab ONLY the first clump (the number)
            
            ; Extract digits from just that first word
            if RegExMatch(firstWord, "\d+", &match) {
                return Number(match[0])
            }
        }
    } catch {
        ToolTip "Screen capture error or window minimized"
        SetTimer(() => ToolTip(), -2000)
        return -1
    }
    ToolTip "Text found but couldn't identify 'No' or a number"
    SetTimer(() => ToolTip(), -2000)
    return -1
}
; ══════════════════════════════════════════════
;  KEY AND PROCESS
; ══════════════════════════════════════════════

PressKey(key, delay := 500) {
    global Key_UI, cHighlight, cIdle, CurrentMultiplier, GameTitle

    ; 1. Determine UI Display Name (Supports grouping multiple cases)
    switch key {
        case "Down":  displayname := "↓"
        case "Up":    displayname := "↑"
        case "Left":  displayname := "←"
        case "Right": displayname := "→"
        case "Enter": displayname := "Enter ↵" 
        case "Backspace": displayname := "⬅ Backspace"
        case "w down", "w up": displayname := "W"
        case "s down", "s up": displayname := "S"
        Default : displayname := key
    }

    Key_UI.Value := "⌨  [ " displayName " ]"

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
    ; Send("{" sendKey "}")
    try {
        ControlSend("{" sendKey "}", , GameTitle)
    } catch {
        Process("Game Window Not Found!")
    }

    Sleep(CurrentMultiplier * delay)
}

Process(text, delay := 0) {
    global Process_UI

    Process_UI.Value := "⚙️  " text
    Sleep(delay)
}

; ══════════════════════════════════════════════
;  MISC FUNCTIONS
; ══════════════════════════════════════════════

WriteNumber(num) {
    global GameTitle

    for digit in StrSplit(String(num))
    {
        ControlSend("{" digit "}", , GameTitle)
        Sleep(50) ; optional delay between key presses
    }
}

UpdateSpeed(*) {
    global SpeedLabel_UI, DelaySlider_UI

    ; Get the slider's current physical position (1 through 7)
    sliderPosition := DelaySlider_UI.Value
    
    ; Pull the matching decimal value from our array
    Global CurrentMultiplier := Multipliers[sliderPosition]
    
    ; Update the Text Label on the GUI
    SpeedLabel_UI.Text := "Delay Multiplier: " CurrentMultiplier "x"
}