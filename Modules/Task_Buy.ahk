; ╔═════════════════════════════════════════╗
; ║        MHI - FH6 Wheelspin Macro		║
; ║        Cyber Noir Edition v1.4.0        ║
; ╚═════════════════════════════════════════╝

#Requires AutoHotkey v2.0

StartBuy() {
    global ActiveMode, MasterMode, StatusText, cActive, CarCount, BuyRunSeconds
    global BuyRunTime_UI, CarCount_UI, CarsLabel_UI, SkillPtsWant_In, CarCount_In, SkillPtsCount_In, SelectedCarPoint

    StartIndicators()
    if !ToggleMode("Buy") {
        StatusText.Value := "⬤  Stopping..."
        StatusText.SetFont("cFFB347")
    }

    if (ActiveMode = "Buy") {
        CarCount            := 0
        BuyRunSeconds       := 0
        CarCount_In.Value   := Floor(SkillPtsCount_In.Value / SelectedCarPoint)
        CarsLabel_UI.Value  := "Recommended Car Purchase  —  " CarCount_In.Value
        CarCount_UI.Value   := "🚗   Car Purchased   —   0"
        BuyRunTime_UI.Value := "🕓   Buy Time Running   —   00:00"
        StatusText.Value    := "⬤  Running..."
        StatusText.SetFont("c" cActive)
        
        BuyLoop()
    }
    ResetIndicators()
}

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

        CarCount_In.Value := Floor(SkillPtsCount_In.Value / SelectedCarPoint)
        
        if(!MasterMode) {
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
            
            Process("Returning to Campaign Menu...")
            PressKey("Esc", 1500) ; Navigate to Upgrades Menu
            PressKey("Esc", 1500) ; Navigate to Cars Menu
            PressKey("PgUp", 50) ; Navigate to Buy & Sell Menu
            PressKey("PgUp") ; Navigate to Campaign Menu

            if points < SelectedCarPoint
                break
        }

        Process("Navigating Journal...")
        Loop 3
            PressKey("Up", 50) ; Navigate to Drive
        PressKey("Down", 50) ; Navigate to Collection Journal
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
            Case "Subaru Impreza 22B-STi":
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
        Sleep(500)
        PressKey("Up") ; Navigate to Drive

        break
    }
}