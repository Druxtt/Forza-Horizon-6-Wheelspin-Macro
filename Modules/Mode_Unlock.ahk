; ╔═════════════════════════════════════════╗
; ║        MHI - FH6 Wheelspin Macro        ║
; ║            Cyber Noir Edition           ║
; ╚═════════════════════════════════════════╝

StartUnlock() {
    global ActiveMode, StatusText
    global SkillPtsCount_In, CarCount_In, CarsLabel_UI
    global SWheelCount_UI, CreditCount_UI, UnlockRunTime_UI, WheelCount_UI
    global MiniSWheelCount_UI, MiniWheelCount_UI, MiniCreditCount_UI, MiniUnlockRunTime_UI
    global UnlockRunSeconds, SkillPtsScanSuccess, cHighlight
    global CarData, SelectedCar

    if (FindGame() == 0)
        return

    if !ToggleMode("Unlock") {
        StatusText.Value := "⬤  Stopping..."
        StatusText.SetFont("cFFB347")
    }
    
    StartIndicators()
    UpdateMiniWidgetMode(ActiveMode)
    
    if (ActiveMode == "Unlock") {
        UnlockRunSeconds    := 0
        SkillPtsScanSuccess := false
        CarCount_In.Value   := Floor(SkillPtsCount_In.Value / CarData[SelectedCar].SkillPtsCost)
        CarsLabel_UI.Value  := CarCount_In.Value

        SWheelCount_UI.Value   := "0"
        WheelCount_UI.Value    := "0"
        CreditCount_UI.Value   := "0 CR"
        UnlockRunTime_UI.Value := "00:00"

        MiniSWheelCount_UI.Value   := "0"
        MiniWheelCount_UI.Value    := "0"
        MiniCreditCount_UI.Value   := "0 CR"
        MiniUnlockRunTime_UI.Value := "00:00"

        UnlockRunTime_UI.SetFont("c" cHighlight)
        SetTimer(UnlockTimerTick, 1000)

        UnlockLoop()
    }

    ResetIndicators()
}

UnlockLoop() {
    global ActiveMode, MasterMode, MasterStart, SkillPtsScanSuccess
    global cActive, cHighlight, cIdle
    global SWheelCount_UI, WheelCount_UI, CreditCount_UI, UnlockRunTime_UI
    global SkillPtsCount_In, CarCount_In, MaxPoints
    global CarData, SelectedCar
    global CarSorted := false

    if (ActiveMode != "Unlock")
        return

    ; Early Safety Guard: Stop immediately if the vehicle configuration doesn't exist
    if !CarData.Has(SelectedCar) {
        MsgBox("Error: Selected car '" SelectedCar "' not found in database.", "Error", 16)
        return
    }
    car := CarData[SelectedCar]

    ; Initialize Automation Telemetry counters
    global TotalSWheel    := 0
    global TotalWheel     := 0
    TotalCredit    := 0
    UnlockCount    := 0
    NotiFreqInterv := 5

    CheckAbort() => (ActiveMode != "Unlock" || (!MasterMode && MasterStart))

    ; DYNAMIC UI STYLING: Highlights matching UI counters if the car rewards them
    if (car.UnlockSWheel > 0) SWheelCount_UI.SetFont("c" cHighlight)
    if (car.UnlockWheel > 0)  WheelCount_UI.SetFont("c" cHighlight)
    if (car.UnlockCredit > 0) CreditCount_UI.SetFont("c" cHighlight)
    
    Process("Starting Emergency Unlock Check", 500)
    SetTimer(EmergencyUnlockCheck, 400)

    CarMenu := ScanOCR(0.060, 0.090, 0.096, 0.045)
    if !InStr(CarMenu, "My Cars") {

        Process("Scanning Menu...")
        UnlockNav("Reward Unlock")

        if CheckAbort()
            return

        if (!MasterMode && !SkillPtsScanSuccess && SkillPtsCount_In.Value == 0) {
            Process("Checking Available Skill Points..")
            PressKey("PgDn") ; Navigate to Cars
            PressKey("Down", 50) ; Navigate to Upgrades & Tuning
            PressKey("Enter", 800) ; Select Upgrades & Tuning
            Loop 7 
                PressKey("Down", 50)
            PressKey("Enter")

            if CheckAbort()
                return
            
            Process("Scanning Skill Points...")
            points := SkillPtsScan(0.331, 0.851, 0.054, 0.033, 1500, 1500)
            SkillPtsScanSuccess := (points != -1)
            
            if !SkillPtsScanSuccess
                ShowNotif("fail", "Reward Unlock", "Unable to scan Current Skill Points amount. `nManual input required.")

            if CheckAbort()
                return

            Process("Returning to Campaign Menu...")
            PressKey("Esc", 1500) ; Navigate to Upgrades Menu
            PressKey("Esc", 1500) ; Navigate to Cars Menu
            PressKey("PgUp", 50) ; Navigate to Buy & Sell Menu
        }
        
        CarCount_In.Value := Floor(SkillPtsCount_In.Value / CarData[SelectedCar].SkillPtsCost)
        
        if (CarCount_In.Value > 0) {
            ; DYNAMIC START NOTIFICATION
            StartRewardsText := BuildRewardString(
                CarCount_In.Value * car.UnlockSWheel, 
                CarCount_In.Value * car.UnlockWheel, 
                CarCount_In.Value * car.UnlockCredit, 
                " will be obtained."
            )
            ShowNotif("info", "Reward Unlock", StartRewardsText)
        } else {
            ShowNotif("error", "Reward Unlock", "Insufficient Skill Points")
            return
        }

        if CheckAbort()
            return

        Process("Navigating Auction House...", 500)
        PressKey("Down", 50) ; Navigate to Auction House
        PressKey("Enter", 800) ; Select Auction House
        PressKey("Down", 50) ; Navigate to Start Auction
        PressKey("Enter", 800) ; Select Start Auction

        if CheckAbort()
            return
    
        Process("Sort by Recently Added...")
        PressKey("X")
        Loop 6 
            PressKey("Down", 50) ; Navigate to Recently Added
        PressKey("Enter") ; Select Recently Added
        PressKey("Backspace") ; Jump to Recently Added
        PressKey("Enter") ; Select All Cars

        Process("Filter Cars by Duplicates...")
        PressKey("y") ; ; Filter
        Loop 4
            PressKey("Down", 50) ; Navigate to Duplicates
        PressKey("Enter") ; Check Duplicates
        PressKey("Esc") ; Return to All Cars

        if CheckAbort()
            return
    }

    CarSorted := true
    
    Process("Choosing First Car...")
    PressKey("Enter", 800) ; Select First Car
    PressKey("Down", 50) ; Navigate to Get in Car
    PressKey("Enter", 800) ; Select Get in Car

    if !WaitForPixel("Getting in Car...", 0.067, 0.169, "0xFFFFFF", "", 10000, 500) {
        Process("Sync Error: Unable to get in car!")
        return
    }

    if CheckAbort()
        return

    PressKey("Esc", 1500) ; Navigate to Auction House Menu
    PressKey("Esc", 1500) ; Navigate to Buy & Sell Menu

    if CheckAbort()
        return

    ; --- Main Unlocking Loop ---
    Loop CarCount_In.Value {
        if CheckAbort()
            break
        
        Process("Navigating to Cars...")
        PressKey("PgDn", 50) ; Navigate to Cars Menu

        Process("Navigating to Upgrades & Tuning...", 500)
        PressKey("Down", 50) ; Navigate to Upgrades & Tuning
        PressKey("Enter", 800) ; Select Upgrades & Tuning
        Loop 8 ; Extra Down for safety
            PressKey("Down", 50) ; Navigate to Car Mastery
        PressKey("Enter", 800) ; Select Car Mastery

        if !WaitForPixel("Opening Car Mastery...", 0.176, 0.545, "0xFFFFFF", "", 3000, 100, true) {
            Process("Resetting the Car Mastery position")
            Loop 4 
                PressKey("Down", 0) ; Navigate to Car Mastery
            Loop 4 
                PressKey("Left", 0) ; Navigate to Car Mastery
        }

        if CheckAbort()
            break

        Process("Unlocking Car Mastery...")
        UnlockCar(SelectedCar)
        UnlockCount++

        ; Update internal tracking aggregates
        TotalSWheel += car.UnlockSWheel
        TotalWheel  += car.UnlockWheel
        TotalCredit += car.UnlockCredit

        ; UI Metric Live Component Updates
        if (car.UnlockSWheel > 0) {
            SWheelCount_UI.Value := TotalSWheel
            MiniSWheelCount_UI.Value := TotalSWheel
        }
        if (car.UnlockWheel > 0) {
            WheelCount_UI.Value := TotalWheel
            MiniWheelCount_UI.Value := TotalWheel
        }
        if (car.UnlockCredit > 0) {
            CreditCount_UI.Value := FormatCommas(TotalCredit) " CR"
            MiniCreditCount_UI.Value := FormatCommas(TotalCredit) " CR"
        }

        ; DYNAMIC PERIODIC NOTIFICATION
        if (Mod(UnlockCount, NotiFreqInterv) == 0) {
            PeriodicRewardsText := BuildRewardString(TotalSWheel, TotalWheel, TotalCredit, " have been obtained.")
            ShowNotif("info", "Reward Unlock", PeriodicRewardsText)
        }

        SkillPtsCount_In.Value -= CarData[SelectedCar].SkillPtsCost
        SkillPtsWant_In.Value := Min(999 - SkillPtsCount_In.Value, MaxPoints)

        if CheckAbort()
            break

        Process("Navigating Home...")
        PressKey("Esc", 1500) ; Navigate to Upgrades Menu
        PressKey("Esc", 1500) ; Navigate to Cars Menu
        PressKey("PgUp") ; Navigate to Buy & Sell Menu
        
        ; SubMenuText := ScanOCR(0.030, 0.186, 0.329-0.030, 0.358-0.186)
        ; if !InStr(SubMenuText, "Buy & Sell")
        ;     EmergencyUnlockExit("Buy & Sell Menu not detected.")

        PressKey("Down", 1000) ; Navigate to Auction House

        if CheckAbort()
            break

        Process("Navigating Auction House...")
        PressKey("Enter", 800) ; Select Auction House
        PressKey("Down") ; Navigate to Start Auction
        PressKey("Enter", 800) ; Select Start Auction
            
        if CheckAbort()
            break

        Process("Sort by Recently Added...")
        PressKey("X") ; Sort
        Loop 6 
            PressKey("Down", 50) ; Navigate to Recently Added
        PressKey("Enter") ; Select Recently Added

        Process("Filter Cars by Duplicates...")
        PressKey("y") ; ; Filter
        Loop 4
            PressKey("Down", 50) ; Navigate to Duplicates
        PressKey("Enter") ; Check Duplicates
        PressKey("Esc") ; Return to All Cars

        if CheckAbort()
            break

        Process("Choosing Next Car...")
        PressKey("Down") ; Navigate to Next Car
        PressKey("Enter", 800) ; Select Next Car
        PressKey("Down", 50) ; Navigate to Get in Car 
        PressKey("Enter", 800) ; Select Get in Car

        if !WaitForPixel("Getting in Car...", 0.067, 0.169, "0xFFFFFF", "", 10000, 500) {
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
    }

    ; DYNAMIC FINAL OUTPUT SUMMARY
    FinalRewardsText := BuildRewardString(TotalSWheel, TotalWheel, TotalCredit, " have been obtained.")
    ShowNotif("success", "Reward Unlock", FinalRewardsText)

    PressKey("PgUp")
    SetTimer(EmergencyUnlockCheck, 0)
}

; --- NEW HELPER ENGINE: Dynamically strings together active car payouts ---
BuildRewardString(sWheel, wheel, credit, executionSuffix) {
    msgParts := []
    
    if (sWheel > 0)
        msgParts.Push(sWheel " Super Wheelspins")
    if (wheel > 0)
        msgParts.Push(wheel " Wheelspins")
    if (credit > 0)
        msgParts.Push(FormatCommas(credit) " CR")
        
    compiledMessage := ""
    for idx, text in msgParts
        compiledMessage .= (idx == 1 ? "" : " and`n") . text
        
    return compiledMessage . executionSuffix
}

UnlockCar(SelectedCar) {
    global CarData
    PressKey("Enter", 1100)
    for , step in CarData[SelectedCar].UnlockPath {
        keyName    := step[1]
        pressCount := step[2]
        
        Loop pressCount {
            PressKey(keyName, 300)
            PressKey("Enter", 1100)
        }
    }
}

EmergencyUnlockCheck() {
    global GameTitle, ActiveMode, CarData, SelectedCar, CarSorted
    static StatsNum := 0
    
    if (ActiveMode != "Unlock" || !WinExist(GameTitle))
        return

    MenuText := ScanOCR(0.362, 0.357, 0.290, 0.092)
    
    if InStr(MenuText, "Create Auction")
        EmergencyExit("Create Auction Menu detected.")

    if !CarSorted && InStr(MenuText, "Remove Car")
        EmergencyExit("Remove Car Menu detected.")

    if CarSorted {
        SubMenuText := ScanOCR(0.062, 0.092, 0.086, 0.040)
        
        if InStr(SubMenuText, "Car Pass")
            EmergencyExit("Car Pass Menu detected.")
        
        if InStr(SubMenuText, "My Cars") {
            isMadMike := (SelectedCar == "Mazda #123 Mad Mike 808")
            StatsNumNew := isMadMike 
                ? ScanOCR(0.170, 0.455, 0.035, 0.245, , , true) 
                : ScanOCR(0.177, 0.457, 0.028, 0.250, , , true)
            
            if (StrLen(StatsNumNew) < 10)
                return
            
            StatsNum        := StatsNumNew
            ExpectedNum     := CarData[SelectedCar].StatsNum
            SimilarityScore := Round(GetTextSimilarity(ExpectedNum, StatsNum))

            if (SimilarityScore <= 80) {
                Details := "Wrong Car Detected!`n`n"
                        . "Scanning " SelectedCar " Stats Number...`n"
                        . "Scanned: " StatsNum "`n"
                        . "Expected: " ExpectedNum "`n"
                        . "Similarity: " SimilarityScore "%"
                
                EmergencyExit(Details)
            }
        }
    }
}

UnlockNav(NotifTitle) {
    Scanned := ScanMenu()

    ; 1. Safety Check: Handle timeout immediately
    if (Scanned.menu == "") {
        Process("Navigation aborted: Menu could not be identified.")
        return 
    }

    ; 2. Define page movements needed to reach "Cars" from any Free Roam menu tab
    FreeRoamNav := Map(
        "Free Roam Menu - Campaign",     { key: "PgDn", count: 1 },
        "Free Roam Menu - Cars",         { key: "",     count: 0 },
        "Free Roam Menu - My Horizon",   { key: "PgUp", count: 1 },
        "Free Roam Menu - Online",       { key: "PgUp", count: 2 },
        "Free Roam Menu - Creative Hub", { key: "PgUp", count: 3 },
        "Free Roam Menu - Store",        { key: "PgUp", count: 4 }
    )

    ; 3. Define page movements needed to reach "Buy & Sell" from any Home menu tab
    HomeNav := Map(
        "Home Menu - Campaign",             { key: "PgDn", count: 1 },
        "Home Menu - Buy & Sell",           { key: "",     count: 0 },
        "Home Menu - Cars",                 { key: "PgUp", count: 1 },
        "Home Menu - Customizable Garage",  { key: "PgUp", count: 2 },
        "Home Menu - Character",            { key: "PgUp", count: 3 }
    )

    ; 4. State Normalization (Get everything into the Home Menu state)
    switch Scanned.menu {
        case "Home Menu":
            ; Already in the menu structure; Scanned.submenu is already accurately set by ScanMenu()
            ShowNotif("info", NotifTitle, "Home Menu detected.")

        case "Free Roam":
            Process("Navigating to Free Roam Menu...")
            ShowNotif("info", NotifTitle, "Free Roam detected! `nNavigating to Free Roam Menu...")
            PressKey("Esc", 1000) ; Open Free Roam Menu (Lands on default Campaign tab)
            Scanned.submenu := "Free Roam Menu - Campaign"
            
        case "Free Roam Menu":
            ShowNotif("info", NotifTitle, "Free Roam Menu detected!")
    }

    ; 5. Unified Tab Navigation Execution
    Process("Navigating to Cars Menu...")
    if FreeRoamNav.Has(Scanned.submenu) {
        nav := FreeRoamNav[Scanned.submenu]
        Loop nav.count {
            PressKey(nav.key, 100)
        }
        
        Process("Scanning Skill Points")
        if SkillPtsRaceScan(0.280, 0.698, (0.437-0.280), (0.756-0.698))
            global SkillPtsScanSuccess := true
        
        Process("Navigating to My Horizon Menu...")
        PressKey("PgDn") ; Navigate to My Horizon Menu
        PressKey("Enter") ; Select Return Home
        PressKey("Enter") ; Confirm Travel to Home
        WaitForPixel("Returning to Home...", 0.168, 0.722, "0xFFFFFF", "", 20000)
    }
    
    Process("Navigating to Home Menu - Buy & Sell...")
    if HomeNav.Has(Scanned.submenu) {
        nav := HomeNav[Scanned.submenu]
        Loop nav.count {
            PressKey(nav.key, 100)
        }
        Sleep(500)
        if nav.count = 0 {
            Process("Resetting the menu position...")
            Loop 4
                PressKey("Up", 50)
        }
    }
}