; ╔═════════════════════════════════════════╗
; ║        MHI - FH6 Wheelspin Macro		║
; ║        Cyber Noir Edition v1.6.0        ║
; ╚═════════════════════════════════════════╝

#Requires AutoHotkey v2.0

global UnlockCount    := 0
global SWheelCount    := 0
global WheelCount     := 0
global CreditCount    := 0

StartUnlock() {
    global ActiveMode, StatusText, CreditCount, UnlockCount, UnlockRunSeconds
    global SWheelCount_UI, WheelCount_UI, CreditCount_UI, UnlockRunTime_UI, CarsLabel_UI, CarCount_In, SkillPtsCount_In, SelectedCarPoint

    if !ToggleMode("Unlock") {
        StatusText.Value := "⬤  Stopping..."
        StatusText.SetFont("cFFB347")
    }
    
    StartIndicators()
    if (ActiveMode = "Unlock") {
        UnlockCount            := 0
        UnlockRunSeconds       := 0
        SkillPtsScanSuccess := false
        CarCount_In.Value      := Floor(SkillPtsCount_In.Value / SelectedCarPoint)
        CarsLabel_UI.Value     := "Recommended Car Purchase  —  " CarCount_In.Value
        SWheelCount_UI.Value   := "0"
        WheelCount_UI.Value    := "0"
        CreditCount_UI.Value   := "0 CR"
        UnlockRunTime_UI.Value := "00:00"

        UnlockRunTime_UI.SetFont("c" cHighlight)
        SetTimer(UnlockTimerTick, 1000)
        UnlockLoop()
    }
    ResetIndicators()
}

UnlockLoop() {
    global ActiveMode, MasterMode, SkillPtsScanSuccess
    global cActive, cHighlight, cIdle
    global SWheelCount, SWheelCount_UI, WheelCount_UI, CreditCount_UI, UnlockRunTime_UI
    global UnlockCount, WheelCount, CreditCount, SelectedCar, SelectedCarPoint, SkillPtsCount_In, CarCount_In

    NotiFreqInterv := 5

    ; 1. Helper function to clean up the repetitive break checks
    CheckAbort() => (ActiveMode != "Unlock" || (!MasterMode && MasterStart))

    While (ActiveMode = "Unlock") {

        Switch SelectedCar {
            Case "Subaru Impreza 22B-STi":
                SWheelCount_UI.SetFont("c" cHighlight)
            Case "Lamborghini Revuelto":
                SWheelCount_UI.SetFont("c" cHighlight)
                WheelCount_UI.SetFont("c" cHighlight)
            Case "Dodge Viper GTS ACR":
                CreditCount_UI.SetFont("c" cHighlight)
        }

        ; 3. Initial Navigation
        Process("Navigating Home...")
        Loop 4
            PressKey("Up", 50) ; Navigate to Drive selection

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
                ShowNotif("fail", "Car Unlock", "Unable to scan Current Skill Points amount. `nManual input required.")
            }

            Process("Returning to Campaign Menu...")
            PressKey("Esc", 1500) ; Navigate to Upgrades Menu
            PressKey("Esc", 1500) ; Navigate to Cars Menu
            PressKey("PgUp", 50) ; Navigate to Buy & Sell Menu
            PressKey("PgUp") ; Navigate to Campaign Menu
        }
        
        CarCount_In.Value := Floor(SkillPtsCount_In.Value / SelectedCarPoint)
        if CarCount_In.Value > 0
            Switch SelectedCar {
                Case "Subaru Impreza 22B-STi":
                    ShowNotif("info", "Mastery Unlock", CarCount_In.Value " Super Wheelspins will be obtained." )
                    
                Case "Lamborghini Revuelto":
                    ShowNotif("info", "Mastery Unlock", CarCount_In.Value " Super Wheelspins and`n" CarCount_In.Value*3 " Wheelspins will be obtained." )
                    
                Case "Dodge Viper GTS ACR":
                    ShowNotif("info", "Mastery Unlock", CarCount_In.Value*85400 " CR will be obtained.")
            }
        else {
            ShowNotif("error", "Car Unlock", "Insufficient Skill Points")
            break
        }
        
        PressKey("PgDn") ; Navigate to Buy & Sell Menu
        PressKey("Down", 50) ; Navigate to Auction House
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
            PressKey("Enter", 800) ; Select Upgrades & Tuning
            Loop 7 
                PressKey("Down", 50) ; Navigate to Car Mastery
            PressKey("Enter") ; Select Car Mastery

            if !WaitForMenuRelative("Opening Car Mastery...", 0.176, 0.545, "0xFFFFFF", "", 3000, 100) {
                Process("Sync Error: Car Mastery menu failed to load!")
                break
            }
    
            if CheckAbort()
                break
    
            Process("Unlocking Car Mastery...")
            Switch SelectedCar {
                Case "Subaru Impreza 22B-STi":
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

                    SWheelCount := UnlockCount
                    SWheelCount_UI.Value := SWheelCount

                    if Mod(UnlockCount, NotiFreqInterv) = 0
                        ShowNotif("info", "Mastery Unlock", SWheelCount " Super Wheelspins have been obtained." )

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
                    SWheelCount := UnlockCount
                    WheelCount := UnlockCount*3

                    SWheelCount_UI.Value := SWheelCount
                    WheelCount_UI.Value  := WheelCount

                    if Mod(UnlockCount, NotiFreqInterv) = 0
                        ShowNotif("info", "Mastery Unlock", SWheelCount " Super Wheelspins and`n" WheelCount " Wheelspins have been obtained." )
                    
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

                    CreditCount := UnlockCount*85400
                    CreditCount_UI.Value := CreditCount " CR"

                    if Mod(UnlockCount, NotiFreqInterv) = 0
                        ShowNotif("info", "Mastery Unlock", CreditCount " CR have been obtained.")
            }

            SkillPtsCount_In.Value -=  SelectedCarPoint
            SkillPtsWant_In.Value := Min(999 - SkillPtsCount_In.Value, MaxPoints)
    
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

        Switch SelectedCar {
            Case "Subaru Impreza 22B-STi":
                ShowNotif("success", "Mastery Unlock", SWheelCount " Super Wheelspins have been obtained." )
                
            Case "Lamborghini Revuelto":
                ShowNotif("success", "Mastery Unlock", SWheelCount " Super Wheelspins and`n" WheelCount " Wheelspins have been obtained." )
                
            Case "Dodge Viper GTS ACR":
                ShowNotif("success", "Mastery Unlock", CreditCount " CR have been obtained.")
        }
        
        PressKey("PgUp") ; Navigate to Campaign Menu

        break ;
    }
}