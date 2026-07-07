; ╔═════════════════════════════════════════╗
; ║        MHI - FH6 Wheelspin Macro        ║
; ║            Cyber Noir Edition           ║
; ╚═════════════════════════════════════════╝

StartRace() {
    global ActiveMode, StatusText, cActive, SectorCount, TotalRunSeconds, RaceRunSeconds, PointsGain
    global RaceRunTime_UI, PointsCount_UI, SectorCount_UI
    global SkillPtsCount_In, SkillPtsWant_In, CarCount_In

    if FindGame() = 0
        return

    if !ToggleMode("Race") {
        StatusText.Value := "⬤  Stopping..."
        StatusText.SetFont("cFFB347")
    }
    
    StartIndicators()
    UpdateMiniWidgetMode(activeMode)
    
    if (ActiveMode = "Race" && SkillPtsWant_In.Value > 0 && SkillPtsCount_In.Value < 999) {
        SectorCount          := 0
        
        TotalRunSeconds      := 0
        RaceRunSeconds       := 0

        SectorCount_UI.Value := 0
        PointsCount_UI.Value := 0
        RaceRunTime_UI.Value := "00:00"

        ; Update GUI
        MiniSectorCount_UI.Value := 0
        MiniPointsCount_UI.Value := 0
        MiniRaceRunTime_UI.Value := "00:00"

        PointsCount_UI.SetFont("c" cHighlight)
        SectorCount_UI.SetFont("c" cHighlight)
        RaceRunTime_UI.SetFont("c" cHighlight)
        SetTimer(RaceTimerTick, 1000)
        RaceLoop()
    }
    ResetIndicators()
}

RaceLoop() {
    global ActiveMode, MasterMode, MasterStart, RaceStart, EventLab
    global cActive, cHighlight, cIdle
    global SectorCount_UI, PointsCount_UI, CarCount_UI, RaceRunTime_UI
    global AveragePoints, Maxpoints, PointsGain, RaceRunSeconds

    PointsCount     := 0
    SectorCount     := 0
    FailedTurn      := 0
    NotiFreqInterv  := 5
    ; Local helper to cleanly check if the macro should stop
    CheckAbort() => (ActiveMode != "Race" || (!MasterMode && MasterStart))

    While (ActiveMode = "Race") {
        RaceStart := true

        Process("Scanning Menu...")
        RaceNav("EventLab Race")

        if CheckAbort()
            break

        Process("Scanning Skill Points")
        SkillPtsRaceScan(0.280, 0.698, (0.437-0.280), (0.756-0.698))

        if CheckAbort()
            break

        Process("Navigating to Creative Hub Menu")
        Loop 3
            PressKey("PgDn", 100) ; Navigate to Creative Hub  Menu

        Process("Opening EventLab Menu...", 500)
        PressKey("Enter", 1000) ; Select EventLab
        PressKey("Enter", 3000) ; Select Play Event

        if CheckAbort()
            break

        Process("Navigating to Favourited Events...")
        Loop 7
            PressKey("pgDn", 100)

        if !WaitForPixel("Waiting for EventLab to load...", 0.283, 0.198, "0xFCC500", , 10000) {
            Process("Sync Error: EventLab search timed out!")
            break
        }
        PressKey("Enter") ; Select Event

        if CheckAbort()
            break

        if !WaitForPixel("Choosing Race Type...",0.331, 0.567, "0xFFFFFF", , 10000) {
            Process("Sync Error: EventLab search timed out!")
            break
        }
        PressKey("Enter", 3000) ; Select Race Type

        if CheckAbort()
            break

        Process("Select Favourited Car...")
        PressKey("Y") ; Filter
        PressKey("Enter") ; Toggle
        PressKey("Esc", 1000) ; Back to My Cars

        if CheckAbort()
            break

        Process("Loading EventLab...")
        PressKey("Enter") ; Select Car
        
        if !WaitForPixel("Waiting for track to load...", 0.158, 0.678, "0xFFFFFF", "", 30000) {
            Process("Sync Error: EventLab track failed to load!")
            break
        }

        Process("Start Race Event...")
        PressKey("Enter", 2000) ; Start Race
        
        if CheckAbort()
            break

        PressKey("W", 50) ; Early throttle
        Process("Countdown...", 3000)

        if EventLab = "LIQUIDPOTATO" {

            While (PointsCount < PointsGain) {
                Process("Throttling...")

                PressKey("w down", 50) ; Press throttle to move forward
                Sleep(30000)
                PressKey("w up", 50) ; Release throttle to prevent timeout

                if CheckAbort()
                    break
                
                SectorCount++

                PointsCount := Floor(SectorCount * AveragePoints) ; Using average points per race for estimation to account for variability

                ; Update GUI
                PointsCount_UI.Value    := PointsCount
                SectorCount_UI.Value     := SectorCount
                MiniPointsCount_UI.Value    := PointsCount
                MiniSectorCount_UI.Value     := SectorCount
                
                if (Mod(SectorCount, 4) = 0 && PointsCount < PointsGain) {
                    PressKey("w down", 50) ; Press throttle to move forward
                    Sleep(7700) ; 7.7 seconds of extra throttle for the car to turn around
                    PressKey("w up", 50) ; Release throttle to prevent timeout
                }

                if (Mod(SectorCount, NotiFreqInterv) = 0)
                    ShowNotif("info", "EventLab Race", SectorCount " sectors of EventLab Race completed.")
            }

            Process("Quitting the Event...", 2000)
            PressKey("Esc", 1000) ; Pause Menu
            PressKey("Right") ; Navigate to Quit
            PressKey("Enter") ; Quit Event
            PressKey("Enter") ; Confirm Quit
        }
        else If EventLab = "AMMAGEDON" {
            StartTime := A_TickCount

            while (PointsCount < PointsGain) {

                Process("Throttling...")
                PressKey("w down", 18000)

                if CheckAbort()
                    break

                if WaitForPixel("Turning...", 0.202, 0.843, "0x696562", ,6000, 500, true, 25, "Failed braking on time.", 5) {
                    Process("Braking...")
                    PressKey("w up")
                    PressKey("s down", 1500)
                    PressKey("s up", 1000)

                    Process("Throttling...")
                    PressKey("w down", 2000)
                } else {
                    Process("Releasing throttle...")
                    PressKey("w up", 2000)
                    Process("Throttling...")
                    PressKey("w down", 2000)
                }

                if CheckAbort()
                    break
                
                SectorCount++

                if (Mod(SectorCount, NotiFreqInterv) = 0)
                    ShowNotif("info", "EventLab Race", SectorCount " sectors of EventLab Race completed.")

                PointsCount := Floor(SectorCount * AveragePoints) ; Using average points per race for estimation to account for variability

                ; Update GUI
                PointsCount_UI.Value    := PointsCount
                SectorCount_UI.Value    := SectorCount
                MiniPointsCount_UI.Value    := PointsCount
                MiniSectorCount_UI.Value    := SectorCount

                if (!(Mod(SectorCount, 50) = 0) && PointsCount >= PointsGain) {
                    Process("Quitting the Event...", 2000)
                    PressKey("Esc", 1000) ; Pause Menu
                    PressKey("Right") ; Navigate to Quit
                    PressKey("Enter") ; Quit Event
                    PressKey("Enter") ; Confirm Quit
                    break
                }

                if (Mod(SectorCount, 50) = 0 && PointsCount >= PointsGain) {
                    if WaitForPixel("Waiting for leaderboard to load...", 0.166, 0.292, "0xFFFFFF", "", 20000, , true, , "Leaderboard failed to load! `nRestarting event...") {
                        Process("Quitting the Event...")
                        PressKey("Enter") ; Continue
                        break
                    }
                }

                if (Mod(SectorCount, 50) = 0) {

                    if !WaitForPixel("Waiting for leaderboard to load...", 0.166, 0.292, "0xFFFFFF", "", 30000, , true, , "Leaderboard failed to load! `nRestarting event...") {
                        Process("Sync Error: EventLab leaderboard failed to load!")

                        Process("Restarting the Event...", 2000)
                        PressKey("Esc", 1000) ; Pause Menu
                        PressKey("Left") ; Navigate to Restart
                        PressKey("Enter") ; Restart Event
                        PressKey("Enter") ; Confirm Restart
                        
                        if !WaitForPixel("Waiting for next round to load...", 0.174, 0.683, "0xFFFFFF", "", 20000) {
                            Process("Sync Error: EventLab next round failed to load!")
                            break
                        }
                        Process("Entering the Event")
                        PressKey("Enter", 2000) ; Start Race Event
                        PressKey("W down", 50) ; Early throttle
                        Process("Countdown...", 3000)
                    } else {
                        Process("Restarting the Event...")
                        PressKey("X") ; Restart
                        PressKey("Enter") ; Confirm Restart Event

                        if !WaitForPixel("Waiting for next round to load...", 0.174, 0.683, "0xFFFFFF", "", 20000) {
                            Process("Sync Error: EventLab next round failed to load!")
                            break
                        }
                        Process("Entering the Event")
                        PressKey("Enter", 2000) ; Start Race Event
                        PressKey("W down", 50) ; Early throttle
                        Process("Countdown...", 3000)
                    }
                }
            }
            PressKey("w up")
        }

        ShowNotif("success", "EventLab Race", SectorCount " sectors EventLab Race completed.")

        RaceStart := false

        if !WaitForPixel("Returning to Free Roam...", 0.061, 0.945, "0xFFFFFF", "", 30000) {
            Process("Sync Error: Unable to return to Free Roam!")
            break
        }

        if CheckAbort()
            break

        Process("Navigating Menu...")
        PressKey("Esc", 1000) ; Open Menu
        PressKey("PgDn") ; Navigate to Cars Menu

        Process("Scanning Skill Points")
        SkillPtsRaceScan(0.280, 0.698, (0.437-0.280), (0.756-0.698))
        ;SkillPtsRaceScan(0.283, 0.708, 0.060, 0.041)

        PressKey("PgDn") ; Navigate to My Horizon Menu
        PressKey("Enter") ; Select Return Home
        PressKey("Enter") ; Confirm Travel to Home

        if !WaitForPixel("Returning to Home...", 0.168, 0.722, "0xFFFFFF", "", 20000) {
            Process("Sync Error: Unable to return Home!")
            break
        }

        RaceRunTime_UI.SetFont("c" cIdle)
        PointsCount_UI.SetFont("c" cIdle)
        SectorCount_UI.SetFont("c" cIdle)

        break
    }
}

SkillPtsRaceScan(ratioX, ratioY, ratioW, ratioH, waitTime:= 1000) {
    global SkillPtsCount_In, SkillPtsWant_In, CarCount_In
    global PointsLabel_UI, SectorLabel_UI, TimeLabel_UI, CarsLabel_UI
    global ActiveMode, MaxPoints, CustomSkillPts, PointsGain, PointsTotal, TimeTotal, RaceStart
    global CarData, SelectedCar
    
    Sleep(1000)
    points := ScanOCR(ratioX, ratioY, ratioW, ratioH, 1000, , true)

    if RaceStart {

        if points = -1 {
            SkillPtsCount_In.Value := SkillPtsCount_In.Value
            SkillPtsWant_In.Value := CustomSkillPts ? Min(SkillPtsWant_In.Value, MaxPoints - SkillPtsCount_In.Value) : Min(999 - SkillPtsCount_In.Value, MaxPoints)
            ShowNotif("fail", "EventLab Race", "Skill Points Scan Failed. `nDefaulting to previous Skill Points value...")
        }
        else {
            SkillPtsCount_In.Value := points
            SkillPtsWant_In.Value := CustomSkillPts ? Min(SkillPtsWant_In.Value, MaxPoints - points) : Min(999 - points, MaxPoints)
            ShowNotif("info", "EventLab Race", "Starting the EventLab Race with " SkillPtsCount_In.Value " Skill Points.")
        }

        PointsGain := GetMinScore(SkillPtsWant_In.Value)
        PointsTotal := Min(PointsGain + SkillPtsCount_In.Value, 999)
        CarCount_In.Value := Floor(PointsTotal / CarData[SelectedCar].SkillPtsCost)

        TimeTotal := CalcTimeRace(SkillPtsWant_In.Value)  + CalcTimeBuy(CarCount_In.Value) + CalcTimeUnlock(CarCount_In.Value)

        PointsLabel_UI.Value := PointsGain
        SectorLabel_UI.Value := Ceil(PointsGain/AveragePoints)
        TimeLabel_UI.Value := Format("{:02}:{:02}", Floor(TimeTotal) , Round((TimeTotal - Floor(TimeTotal)) * 60))
        CarsLabel_UI.Value := Floor(PointsTotal / CarData[SelectedCar].SkillPtsCost)
    }

    if !RaceStart {

        ; 1. Save the previous value first
        SkillPtsCount_InPrev := SkillPtsCount_In.Value
        
        if (points = -1) {
            SkillPtsCount_In.Value := PointsTotal - 10
            ShowNotif("fail", "EventLab Race", "Skill Points Scan Failed. `nDefaulting to estimated Skill Points gained...")
        }
        else {
            ; 2. Update to the new points
            SkillPtsCount_In.Value := points
            
            ; 3. Now calculate the difference (New total - Old total)
            SkillPtsCount_InNew := SkillPtsCount_In.Value - SkillPtsCount_InPrev
            
            ShowNotif("success", "EventLab Race", SkillPtsCount_InNew " Skill Points have been obtained.")
        }

        SkillPtsWant_In.Value := Min(999 - SkillPtsCount_In.Value, MaxPoints)
    }

    return points
}

RaceNav(NotifTitle) {
    Scanned := ScanMenu()

    ShowNotif("info", NotifTitle, "Navigating to Cars Menu...")

    ; 1. Safety Check: Handle timeout immediately
    if (Scanned.menu == "") {
        Process("Navigation aborted: Menu could not be identified.")
        return 
    }

    ; 2. Define page movements needed to reach "Cars" from any tab
    FreeRoamNav := Map(
        "Free Roam Menu - Campaign",     { key: "PgDn", count: 1 },
        "Free Roam Menu - Cars",         { key: "",     count: 0 },
        "Free Roam Menu - My Horizon",   { key: "PgUp", count: 1 },
        "Free Roam Menu - Online",       { key: "PgUp", count: 2 },
        "Free Roam Menu - Creative Hub", { key: "PgUp", count: 3 },
        "Free Roam Menu - Store",        { key: "PgUp", count: 4 }
    )

    ; 3. State Normalization (Get everything into the Free Roam Menu state)
    switch Scanned.menu {
        case "Home Menu":
            Process("Navigating to Free Roam...")
            ShowNotif("info", NotifTitle, "Home Menu detected. `nReturning to free roam...")
            PressKey("Esc") ; Return to Free Roam
            
            WaitForPixel("Returning to Free Roam...", 0.137, 0.950, "0xFFFFFF", , 20000, 1000)
            
            PressKey("Esc", 1000) ; Open Free Roam Menu (Lands on default Campaign tab)
            Scanned.submenu := "Free Roam Menu - Campaign"

        case "Free Roam":
            Process("Navigating to Free Roam Menu...")
            ShowNotif("info", NotifTitle, "Free Roam detected! `nNavigating to Free Roam Menu...")
            PressKey("Esc", 1000) ; Open Free Roam Menu (Lands on default Campaign tab)
            Scanned.submenu := "Free Roam Menu - Campaign"
            
        case "Free Roam Menu":
            ; Already in the menu structure; Scanned.submenu is already accurately set by ScanMenu()
            ShowNotif("info", NotifTitle, "Free Roam Menu detected!")
    }

    ; 4. Unified Tab Navigation Execution
    Process("Navigating to My Horizon Menu...")

    if FreeRoamNav.Has(Scanned.submenu) {
        nav := FreeRoamNav[Scanned.submenu]
        Loop nav.count {
            PressKey(nav.key, 100)
        }
    }
}