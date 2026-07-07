; ╔═════════════════════════════════════════╗
; ║        MHI - FH6 Wheelspin Macro        ║
; ║            Cyber Noir Edition           ║
; ╚═════════════════════════════════════════╝

StartBuy() {
    global ActiveMode, MasterMode, StatusText, cActive, BuyRunSeconds
    global BuyRunTime_UI, CarCount_UI, CarsLabel_UI, SkillPtsWant_In, CarCount_In, SkillPtsCount_In
    global CarData, SelectedCar

    if FindGame() = 0
        return

    if !ToggleMode("Buy") {
        StatusText.Value := "⬤  Stopping..."
        StatusText.SetFont("cFFB347")
    }
    
    StartIndicators()
    UpdateMiniWidgetMode(activeMode)
    if (ActiveMode = "Buy") {
        
        BuyRunSeconds       := 0
        SkillPtsScanSuccess := false
        CarCount_In.Value   := Floor(SkillPtsCount_In.Value / CarData[SelectedCar].SkillPtsCost)
        CarsLabel_UI.Value  := CarCount_In.Value

        CarCount_UI.Value   := "0"
        BuyRunTime_UI.Value := "00:00"
        MiniCarCount_UI.Value   := "0"
        MiniBuyRunTime_UI.Value := "00:00"

        CarCount_UI.SetFont("c" cHighlight)
        BuyRunTime_UI.SetFont("c" cHighlight)
        
        SetTimer(BuyTimerTick, 1000)
        BuyLoop()
    }
    ResetIndicators()
}

BuyLoop() {
    global ActiveMode, MasterMode, MasterStart, SkillPtsScanSuccess
    global cActive, cHighlight, cIdle
    global CarCount_In, CarCount_UI, BuyRunTime_UI, SkillPtsCount_In
    global CarData, SelectedCar

    BuyCount            := 0

    ; Local helper to cleanly check if the macro should stop
    CheckAbort() => (ActiveMode != "Buy" || (!MasterMode && MasterStart))

    While (ActiveMode = "Buy") {

        BuyNav("Car Purchase")
        
        if(!MasterMode && !SkillPtsScanSuccess && SkillPtsCount_In.Value = 0) {
            Process("Checking Available Skill Points..")
            PressKey("PgDn") ; Navigate to Buy & Sell Menu
            PressKey("PgDn") ; Navigate to Cars Menu
            PressKey("Down", 50) ; Navigate to Upgrades & Tuning
            PressKey("Enter", 800) ; Select Upgrades & Tuning
            Loop 7 
                PressKey("Down", 50) ; Navigate to Car Mastery
            PressKey("Enter") ; Select Car Mastery
            
            Process("Scanning Skill Points...")
            points := SkillPtsScan(0.331, 0.851, 0.054, 0.033) 

            if points != -1 {
                SkillPtsScanSuccess := true
            }
            else {
                SkillPtsScanSuccess := false
                ShowNotif("fail","Car Purchase", "Unable to scan Current Skill Points amount. `nManual input required.")
            }
            
            Process("Returning to Campaign Menu...")
            PressKey("Esc", 1500) ; Navigate to Upgrades Menu
            PressKey("Esc", 1500) ; Navigate to Cars Menu
            PressKey("PgUp", 50) ; Navigate to Buy & Sell Menu
            PressKey("PgUp") ; Navigate to Campaign Menu
        }

        CarCount_In.Value := Floor(SkillPtsCount_In.Value / CarData[SelectedCar].SkillPtsCost)
        if CarCount_In.Value > 0
            ShowNotif("info", "Car Purchase", CarCount_In.Value " " SelectedCar " will be purchased.`nAn extra car will be purchased for safety measure.")
        else {
            ShowNotif("error", "Car Purchase", "Insufficient Skill Points.")
            break
        }

        Process("Navigating Journal...")
        Loop 3
            PressKey("Up", 50) ; Navigate to Drive
        PressKey("Down", 50) ; Navigate to Collection Journal
        PressKey("Enter", 650) ; Select Collection Journal
        PressKey("Right") ; Navigate to Master Explorer
        PressKey("Enter", 650) ; Select Master Explorer
        PressKey("Down") ; Navigate to Car Collection
        PressKey("Enter", 650) ; Select Car Collection
        PressKey("Backspace") ; Select Manufacturers
        if CheckAbort()
            break

        NavigateToCar(SelectedCar)

        if CheckAbort()
            break

        ; ── Buying Car ───────────────
        Process("Buying " SelectedCar "...")
        PressKey("Enter") ; Select Car

        EmergencyBuyCheck()

        ShowNotif("info", "Car Purchase", "Purchasing " CarCount_In.Value+1 " " SelectedCar ".")

        While (BuyCount < CarCount_In.Value+1) {
            PressKey("Space") ; Purchase Car
            PressKey("Down") ; Navigate to Yes
            PressKey("Enter") ; Select Yes (Car Collection)
            PressKey("Enter") ; Select Yes (Buy Car)
            PressKey("Enter") ; Select Yes (Ok)
            
            BuyCount++
            CarCount_UI.Value := BuyCount
            MiniCarCount_UI.Value := BuyCount
        }

        ShowNotif("success", "Car Purchase", BuyCount " " SelectedCar " have been purchased.")

        if CheckAbort()
            break

        ; ── Return to Home ───────────────
        Process("Returning to Home...")
        Loop 4
            PressKey("Esc") ; Navigate to Home Menu
        Sleep(500)
        PressKey("Up") ; Navigate to Drive
        
        break
    }
}

NavigateToCar(SelectedCar) {
    ; Safety check
    if !CarData.Has(SelectedCar) {
        MsgBox("Error: Selected car '" SelectedCar "' not found in database.", "Error", 16)
        return
    }
    
    car := CarData[SelectedCar]

    ; 1. Navigate to the Manufacturer
    ExecutePath(car.BuyMfrPath)

    ; 2. Enter the Manufacturer's menu
    PressKey("Enter") 

    ; 4. Navigate to the specific car
    ExecutePath(car.BuyCarPath)
}

; Helper function to process any data path array (e.g., [["Up", 3], ["Right", 1]])
ExecutePath(pathArray) {
    if (!IsObject(pathArray) || pathArray == "")
        return

    for , step in pathArray {
        keyName    := step[1] ; e.g., "Up"
        pressCount := step[2] ; e.g., 3
        
        Loop pressCount {
            PressKey(keyName, 50)
        }
    }
}

SkillPtsScan(ratioX, ratioY, ratioW, ratioH, waitTime:= 1000, delay:=1000) {
    global SkillPtsCount_In, SkillPtsWant_In, CarCount_In
    global PointsLabel_UI, SectorLabel_UI, TimeLabel_UI, CarsLabel_UI
    global ActiveMode, MaxPoints, PointsGain, PointsTotal, TimeTotal
    global CarData, SelectedCar

    points := ScanOCR(ratioX, ratioY, ratioW, ratioH, waitTime, , true)

    if (points = -1) {
        SkillPtsCount_In.Value := 0
    } else {
        SkillPtsCount_In.Value := points
    }

    SkillPtsWant_In.Value := Min(999 - points, MaxPoints)

    PointsGain := GetMinScore(SkillPtsWant_In.Value)
    PointsTotal := Min(PointsGain + SkillPtsCount_In.Value, 999)

    CarCount_In.Value := Floor(PointsTotal / CarData[SelectedCar].SkillPtsCost)

    TimeTotal := CalcTimeRace(SkillPtsWant_In.Value)  + CalcTimeBuy(CarCount_In.Value) + CalcTimeUnlock(CarCount_In.Value)

    PointsLabel_UI.Value := PointsGain
    SectorLabel_UI.Value := Ceil(PointsGain/AveragePoints)
    TimeLabel_UI.Value :=  Format("{:02}:{:02}", Floor(TimeTotal) , Round((TimeTotal - Floor(TimeTotal)) * 60))
    CarsLabel_UI.Value := Floor(PointsTotal / CarData[SelectedCar].SkillPtsCost)

    Sleep(delay)

    return points
}

EmergencyBuyCheck() {
    global GameTitle, ActiveMode, CarData, SelectedCar

    ScannedCar := ScanOCR(0.254, 0.607, 0.446-0.254, 0.672-0.607) 

    if !InStr(ScannedCar, CarData[SelectedCar].AltName) || !InStr(ScannedCar, SelectedCar)
        EmergencyExit("Selected Car does not match scanned car name.")

}

BuyNav(NotifTitle) {
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
        "Home Menu - Campaign",             { key: "",     count: 0 },
        "Home Menu - Buy & Sell",           { key: "PgUp", count: 1 },
        "Home Menu - Cars",                 { key: "PgUp", count: 2 },
        "Home Menu - Customizable Garage",  { key: "PgUp", count: 3 },
        "Home Menu - Character",            { key: "PgUp", count: 4 }
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
    Process("Navigating to Free Roam Menu - Cars...")
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
    
    Process("Navigating to Home Menu - Campaign...")
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