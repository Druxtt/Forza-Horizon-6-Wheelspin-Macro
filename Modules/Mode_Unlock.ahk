; ╔═════════════════════════════════════════╗
; ║        MHI - FH6 Wheelspin Macro        ║
; ║            Cyber Noir Edition           ║
; ╚═════════════════════════════════════════╝

StartUnlock() {
    global ActiveMode, StatusText
    global SkillPtsCount_In, CarCount_In, CarsLabel_UI
    global SWheelCount_UI, WheelCount_UI, CreditCount_UI, UnlockRunTime_UI
    global MiniSWheelCount_UI, MiniWheelCount_UI, MiniCreditCount_UI, MiniUnlockRunTime_UI
    global UnlockRunSeconds, cHighlight
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
    global ActiveMode, MasterMode, SkillPtsScanSuccess
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
    customUnlock   := false

    CheckAbort() => ActiveMode != "Unlock" && !MasterMode

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

        if CheckAbort()
            return

        FilterByDuplicates()
    } 

    CarSorted := true

    CarUnlockCheck()

    Process("Choosing First Car...")
    PressKey("Enter", 800) ; Select First Car
    PressKey("Down", 50) ; Navigate to Get in Car
    PressKey("Enter", 800) ; Select Get in Car

    if !WaitForPixel("Getting in Car...", 0.067, 0.169, "0xFFFFFF", "", 10000, 500) {
        Process("Sync Error: Unable to get in car!")
        return
    }

    Process("Returning to Cars Menu...")
    PressKey("Esc", 1500) ; Navigate to Upgrades Menu
    PressKey("Esc", 1500) ; Navigate to Cars Menu

    if CheckAbort()
        return

    Process("Navigate to Car Mastery...")
    PressKey("PgDn") ; Navigate to Cars
    PressKey("Down", 50) ; Navigate to Upgrades & Tuning
    PressKey("Enter", 800) ; Select Upgrades & Tuning
    Loop 7 
        PressKey("Down", 50) ; Navigate to Car Mastery
    PressKey("Enter") ; Select Car Mastery

    if CheckAbort()
        return

    if !SkillPtsScanSuccess && !SkillPtsCount_In.Value{        
        Process("Scanning Skill Points...")
        points := SkillPtsScan(0.331, 0.851, 0.054, 0.033, 2000)
        SkillPtsScanSuccess := points != -1 ? true : false
        
        if SkillPtsScanSuccess {
            SkillPtsCount_In.Value := points
            ShowNotif("info", "Reward Unlock", points " Current Skill Points scanned.")
        }
        else {
            ShowNotif("fail", "Reward Unlock", "Unable to scan Current Skill Points amount. `nManual input required.")
            
            Process("Returning to Campaign Menu...")
            PressKey("Esc", 1500) ; Navigate to Upgrades Menu
            PressKey("Esc", 1500) ; Navigate to Cars Menu
            PressKey("PgUp", 50) ; Navigate to Buy & Sell Menu
            PressKey("PgUp", 50) ; Navigate to Campaign
            return
        }
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

    ; --- Main Unlocking Loop ---
    Loop CarCount_In.Value {
        if CheckAbort()
            break
        
        if UnlockCount > 0 {
            Process("Navigating to Cars...")
            PressKey("PgDn", 50) ; Navigate to Cars Menu

            Process("Navigating to Upgrades & Tuning...", 500)
            PressKey("Down", 50) ; Navigate to Upgrades & Tuning
            PressKey("Enter", 800) ; Select Upgrades & Tuning
            Loop 8 ; Extra Down for safety
                PressKey("Down", 50) ; Navigate to Car Mastery
            PressKey("Enter", 800) ; Select Car Mastery
        }

        if !WaitForPixel("Opening Car Mastery...", 0.176, 0.545, "0xFFFFFF", "", 3000, 100, true, , "0") {
            ShowNotif("error", "Reward Unlock", "Car with unlocked mastery perk detected!`nResetting the Car Mastery position...")
            Process("Resetting the Car Mastery position")
            Loop 4 
                PressKey("Down", 10)
            Loop 4 
                PressKey("Left", 10)
        }

        if CheckAbort()
            break

        Process("Unlocking Car Mastery...")
        if UnlockCar(SelectedCar) = false {
            PressKey("Enter") ; Select Ok (Cannot Afford Perk)
            PressKey("Esc", 1500) ; Navigate to Upgrades
            PressKey("Esc", 1500) ; Navigate to Home - Cars
            PressKey("PgUp") ; Navigate to Home - Buy & Sell
            break
        }

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
        CarCount_In.Value -= 1

        if CheckAbort()
            break

        Process("Navigating Home...")
        PressKey("Esc", 1500) ; Navigate to Upgrades
        PressKey("Esc", 1500) ; Navigate to Home - Cars
        PressKey("PgUp") ; Navigate to Home - Buy & Sell
        
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

        FilterByDuplicates()

        if CheckAbort()
            break

        Process("Choosing Next Car...")
        PressKey("Down") ; Navigate to Next Car

        CarUnlockCheck()

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

        CarUnlockCheck()

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
        PressKey("Esc", 1600) ; Navigate to Home - Buy & Sell
    }

    ; DYNAMIC FINAL OUTPUT SUMMARY
    FinalRewardsText := BuildRewardString(TotalSWheel, TotalWheel, TotalCredit, " have been obtained.")
    ShowNotif("success", "Reward Unlock", FinalRewardsText)

    PressKey("PgUp") ; Navigate to Home - Campaign
    SetTimer(EmergencyUnlockCheck, 0)
}

; --- NEW HELPER ENGINE: Dynamically strings together active car payouts ---
BuildRewardString(sWheel, wheel, credit, executionSuffix) {
    global CarData, SelectedCar
    car := CarData[SelectedCar]

    msgParts := []
    
    if (car.UnlockSWheel > 0)
        msgParts.Push(sWheel " Super Wheelspins")
    if (car.UnlockWheel > 0)
        msgParts.Push(wheel " Wheelspins")
    if (car.UnlockCredit > 0)
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
            PressKey("Enter", 0)

            if ScanOCR(0.388, 0.424, 0.625-0.388, 0.476-0.424, 1000, "Cannot Afford Perk", , false)
                return false
        }
    }
}

EmergencyUnlockCheck() {
    global GameTitle, ActiveMode, CarData, CarSorted
    
    if (ActiveMode != "Unlock" || !WinExist(GameTitle))
        return

    MenuText := ScanOCR(0.362, 0.357, 0.290, 0.092)
    
    if InStr(MenuText, "Create Auction")
        EmergencyExit("Create Auction Menu detected.")

    if !CarSorted && InStr(MenuText, "Remove Car")
        EmergencyExit("Remove Car Menu detected.")

    SubMenuText := ScanOCR(0.062, 0.092, 0.086, 0.040)
    
    if InStr(SubMenuText, "Car Pass")
        EmergencyExit("Car Pass Menu detected.")
}

CarUnlockCheck() {
    global GameTitle, ActiveMode, CarData, SelectedCar
    static StatsNum := 0
    
    ; Early exit guard clause
    if (ActiveMode != "Unlock" || !WinExist(GameTitle)) {
        return
    }
    
    ExpectedNum := CarData[SelectedCar].StatsNum
    
    ; Define both coordinate presets
    mazdaCoords    := {x: 0.170, y: 0.455, w: 0.035, h: 0.245}
    standardCoords := {x: 0.177, y: 0.457, w: 0.028, h: 0.250}

    ; Determine primary and secondary based on selection
    isMadMike := (CarData[SelectedCar].AltName == "1974 Mazda")
    primary   := isMadMike ? mazdaCoords : standardCoords
    secondary := isMadMike ? standardCoords : mazdaCoords

    ; 1. Primary Scan Attempt
    StatsNumNew := ScanOCR(primary.x, primary.y, primary.w, primary.h, 100, , true, false)

    ; 2. Cross-Scan Fallback (If primary failed, try the other car type's coordinates)
    if (StrLen(StatsNumNew) < 10 || StatsNumNew = -1) {
        StatsNumNew := ScanOCR(secondary.x, secondary.y, secondary.w, secondary.h, 100, , true, false)
    }

    ; 3. Validation Checks (Only if a valid string length was achieved)
    if (StrLen(StatsNumNew) >= 10 && StatsNumNew != -1) {
        StatsNum        := StatsNumNew
        SimilarityScore := Round(GetTextSimilarity(ExpectedNum, StatsNum))
        
        ; Match fails threshold -> Emergency Exit
        if (SimilarityScore <= 80) {
            Details := "Wrong Car Detected!`n`n"
                     . "Scanning " SelectedCar " Stats Number...`n"
                     . "Scanned: " StatsNum "`n"
                     . "Expected: " ExpectedNum "`n"
                     . "Similarity: " SimilarityScore "%"
            EmergencyExit(Details)
        }
        
        ; Match passes threshold -> Success Notification
        ShowNotif("info", "Reward Unlock", "Car Stats detected: `n- " StatsNum " (" SimilarityScore "% match)")
        return 
    }

    ; 4. Total Failure Notification
    ShowNotif("error", "Reward Unlock", "Unable to read the Car Stats number.`nEnsure it is fully visible.")
}

UnlockNav(NotifTitle) {

    ; 1. Define page movements needed to reach "Cars" from any Free Roam menu tab
    FreeRoamNav := Map(
        "Free Roam Menu - Campaign",     { key: "PgDn", count: 1 },
        "Free Roam Menu - Cars",         { key: "",     count: 0 },
        "Free Roam Menu - My Horizon",   { key: "PgUp", count: 1 },
        "Free Roam Menu - Online",       { key: "PgUp", count: 2 },
        "Free Roam Menu - Creative Hub", { key: "PgUp", count: 3 },
        "Free Roam Menu - Store",        { key: "PgUp", count: 4 }
    )

    ; 2. Define page movements needed to reach "Buy & Sell" from any Home menu tab
    HomeNav := Map(
        "Home Menu - Campaign",             { key: "PgDn", count: 1 },
        "Home Menu - Buy & Sell",           { key: "",     count: 0 },
        "Home Menu - Cars",                 { key: "PgUp", count: 1 },
        "Home Menu - Customizable Garage",  { key: "PgUp", count: 2 },
        "Home Menu - Character",            { key: "PgUp", count: 3 }
    )

    Scanned := ScanMenu()

    ; 3. Safety Check: Handle timeout immediately
    if (Scanned.menu == "") {
        Process("Navigation aborted: Menu could not be identified.")
        return 
    }

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

        Process("Navigating to Home Menu - Buy & Sell...")
        PressKey("PgDn") ; Navigate to Buy & Sell
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

FilterByDuplicates() {
    Process("Filter Cars by Duplicates...")
    PressKey("y") ; Filter
    Loop 2
        PressKey("Down", 50) ; Navigate to Duplicates
    PressKey("Enter", 50) ; Check Duplicates
    PressKey("Esc") ; Return to All Cars
}