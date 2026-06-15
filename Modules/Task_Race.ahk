; ╔═════════════════════════════════════════╗
; ║        MHI - FH6 Wheelspin Macro		║
; ║        Cyber Noir Edition v1.4.0        ║
; ╚═════════════════════════════════════════╝

#Requires AutoHotkey v2.0

StartRace() {
    global ActiveMode, StatusText, cActive, SectorCount, TotalRunSeconds, RaceRunSeconds
    global PointsCount, PointsGain, PointsTotal, RaceRunTime_UI, PointsCount_UI, SectorCount_UI
    global SkillPtsCount_In, SkillPtsWant_In, CarCount_In

    StartIndicators()
    if !ToggleMode("Race") {
        StatusText.Value := "⬤  Stopping..."
        StatusText.SetFont("cFFB347")
    }

    if (ActiveMode = "Race") {
        SectorCount          := 0
        TotalRunSeconds      := 0
        RaceRunSeconds       := 0
        PointsCount          := 0
        SectorCount_UI.Value := "🏁   Sectors Completed   —   0"
        PointsCount_UI.Value := "💡   Est. Skill Points Gained   —   0"
        RaceRunTime_UI.Value := "🕓   Race Time Running   —   00:00"

        RaceLoop()
    }
    ResetIndicators()
}

RaceLoop() {
    global ActiveMode, MasterMode, MasterStart, RaceStart
    global cActive, cHighlight, cIdle
    global SectorCount, PointsCount_UI, CarCount_UI, RaceRunTime_UI, PixelCheck_UI, SectorCount_UI
    global AveragePoints, Maxpoints, PointsTotal, PointsGain, PointsCount, RaceRunSeconds
    global CodeEventLab_UI, CodeEventLab, CodeSelect_UI

    ; Local helper to cleanly check if the macro should stop
    CheckAbort() => (ActiveMode != "Race" || (!MasterMode && MasterStart))

    While (ActiveMode = "Race") {
        RaceStart := true

        RaceRunTime_UI.SetFont("c" cHighlight)
        SetTimer(RaceTimerTick, 1000)
        
        Sleep(1000)
        PressKey("Esc") ; Return to Free Roam

        if !WaitForMenuRelative("Returning to Free Roam...", 0.137, 0.950, "0xFFFFFF", , 20000) {
            Process("Sync Error: Unable to return to Free Roam!")
            break
        }

        if CheckAbort()
            break
            
        Process("Navigating Menu...")
        PressKey("Esc", 1000) ; Open Menu
        PressKey("PgDn", 50) ; Naigate to Cars Menu

        Process("Scanning Skill Points")
        SkillPtsScan(0.284, 0.717, 0.145, 0.035)

        Process("Navigating to EventLab Menu")
        Loop 2
            PressKey("PgDn", 50) ; Navigate to EventLab Menu
        PressKey("PgDn")

        Process("Opening EventLab Menu...")
        PressKey("Enter", 1000) ; Select EventLab
        PressKey("Enter", 1500) ; Select Play Event
        if CheckAbort()
            break

        Process("Navigating to Favourited Events...")
        Loop 7
            PressKey("pgDn", 100)

        if !WaitForMenuRelative("Waiting for EventLab to load...", 0.427, 0.594, "0x000000", , 10000) {
            Process("Sync Error: EventLab search timed out!")
            break
        }
        PressKey("Enter") ; Select Event
        if CheckAbort()
            break

        if !WaitForMenuRelative("Choosing Race Type...", 0.427, 0.594, "0xFFFFFF", , 10000) {
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
        
        if !WaitForMenuRelative("Waiting for track to load...", 0.158, 0.678, "0xFFFFFF", "", 30000) {
            Process("Sync Error: EventLab track failed to load!")
            break
        }

        Process("Start Race Event...")
        PressKey("Enter", 2000) ; Start Race
        if CheckAbort()
            break

        PressKey("W", 50) ; Early throttle
        Process("Countdown...", 3000)

        PointsCount_UI.SetFont("c" cHighlight)
        SectorCount_UI.SetFont("c" cHighlight)

        if CodeSelect_UI.Text = "LIQUIDPOTATO" {

            While (PointsCount < PointsGain) {
                Process("Throttling...")

                PressKey("w down", 50) ; Press throttle to move forward
                Sleep(30000)
                PressKey("w up", 50) ; Release throttle to prevent timeout

                if CheckAbort()
                    break
                
                SectorCount++

                PointsCount := Floor(SectorCount * AveragePoints) ; Using average points per race for estimation to account for variability
                PointsCount_UI.Value    := "💡   Est. Skill Points Gained  —   " PointsCount
                SectorCount_UI.Value     := "🏁   Sectors Completed   —   " SectorCount
                
                if (Mod(SectorCount, 4) = 0 && PointsCount < PointsGain) {
                    PressKey("w down", 50) ; Press throttle to move forward
                    Sleep(7700) ; 7.7 seconds of extra throttle for the car to turn around
                    PressKey("w up", 50) ; Release throttle to prevent timeout
                }
            }

            Process("Quitting the Event...", 2000)
            PressKey("Esc", 1000) ; Pause Menu
            PressKey("Right") ; Navigate to Quit
            PressKey("Enter") ; Quit Event
            PressKey("Enter") ; Confirm Quit
        }
        else If CodeSelect_UI.Text = "AMMAGEDON" {
            StartTime := A_TickCount

            while (PointsCount < PointsGain) {

                Process("Throttling...")
                if(Mod(SectorCount, 1) = 0) {
                    PressKey("w down", 16000)
                } else {
                    PressKey("w down", 18000)
                }

                if WaitForMenuRelative("Turning...", 0.202, 0.843, "0x696562", ,8000, 500, false, 25) {
                    Process("Braking...")
                    PressKey("w up")
                    PressKey("s down", 1500)
                    PressKey("s up", 1000)

                    Process("Throttling...")
                    PressKey("w down", 2000)
                }

                if CheckAbort()
                    break
                
                SectorCount++

                PointsCount := Floor(SectorCount * AveragePoints) ; Using average points per race for estimation to account for variability
                PointsCount_UI.Value    := "💡   Est. Skill Points Gained  —   " PointsCount
                SectorCount_UI.Value    := "🏁   Sectors Completed   —   " SectorCount
                
                if (Mod(SectorCount, 50) = 0) {

                    if !WaitForMenuRelative("Waiting for leaderboard to load...", 0.166, 0.292, "0xFFFFFF", "", 10000) {
                        Process("Sync Error: EventLab leaderboard failed to load!")
                        break
                    }
                    
                    if PointsCount < PointsGain {
                        Process("Restarting the Event...")
                        PressKey("X") ; Restart
                        PressKey("Enter") ; Confirm Restart Event

                        if !WaitForMenuRelative("Waiting for next round to load...", 0.174, 0.683, "0xFFFFFF", "", 20000) {
                            Process("Sync Error: EventLab next round failed to load!")
                            break
                        }
                        Process("Entering the Event")
                        PressKey("Enter", 2000) ; Start Race Event
                        PressKey("W down", 50) ; Early throttle
                        Process("Countdown...", 3000)
                    }
                    else {
                        Process("Quitting the Event...")
                        PressKey("Enter") ; Continue
                        break
                    }
                }
            }
            PressKey("w up")

            if (!(Mod(SectorCount, 50) = 0)) {
                Process("Quitting the Event...", 2000)
                PressKey("Esc", 1000) ; Pause Menu
                PressKey("Right") ; Navigate to Quit
                PressKey("Enter") ; Quit Event
                PressKey("Enter") ; Confirm Quit
            }
        }

        RaceStart := false

        if !WaitForMenuRelative("Returning to Free Roam...", 0.061, 0.945, "0xFFFFFF", "", 30000) {
            Process("Sync Error: Unable to return to Free Roam!")
            break
        }

        if CheckAbort()
            break

        Process("Navigating Menu...")
        PressKey("Esc", 1000) ; Open Menu
        PressKey("PgDn") ; Navigate to Cars Menu

        Process("Scanning Skill Points")
        SkillPtsScan(0.284, 0.717, 0.145, 0.035)

        PressKey("PgDn") ; Navigate to My Horizon Menu
        PressKey("Enter") ; Select Return Home
        PressKey("Enter") ; Confirm Travel to Home

        if !WaitForMenuRelative("Returning to Home...", 0.168, 0.722, "0xFFFFFF", "", 20000) {
            Process("Sync Error: Unable to return Home!")
            break
        }

        RaceRunTime_UI.SetFont("c" cIdle)
        PointsCount_UI.SetFont("c" cIdle)
        SectorCount_UI.SetFont("c" cIdle)

        break
    }
}