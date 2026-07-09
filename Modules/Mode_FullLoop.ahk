; ╔═════════════════════════════════════════╗
; ║        MHI - FH6 Wheelspin Macro        ║
; ║            Cyber Noir Edition           ║
; ╚═════════════════════════════════════════╝

StartFullLoop() {
    global ActiveMode, MasterMode, StartLoopMode
    global LoopCount_In, SkillPtsScanSuccess
    global RadioRace, RadioBuy, RadioUnlock

    StartLoop := StartLoopMode
    SkillPtsScanSuccess := false
    CustomCarCount := 0

    if FindGame() = 0
        return

    StartIndicators()
    MasterMode := !MasterMode

    if MasterMode
        ShowNotif("success", "Master Loop Initiated", "Beginning automated event cycles.")

    while (MasterMode && LoopCount_In.Value > 0) {

        if !StartLoop || StartLoop = "Race" {
            _UpdateStartLoop(RadioRace, "Race")
            StartRace()
            StartLoop := ""
            if !MasterMode
                break
        }

        if !StartLoop || StartLoop = "Buy" {
            _UpdateStartLoop(RadioBuy, "Buy")
            StartBuy()
            StartLoop := ""
            if !MasterMode
                break
        }

        if !StartLoop || StartLoop = "Unlock" {
            _UpdateStartLoop(RadioUnlock, "Unlock")
            StartUnlock()
            StartLoop := ""
            if !MasterMode
                break
        }
        
        if SpinInFullLoop {
            OpenSpinPanel()
            StartSpin()
            OnSpinClose()
            if !MasterMode
                break
        }

        Process("Restarting Full Loop with Race Mode...")
        LoopCount_In.Value -= 1
    }
    
    MasterMode := ""
    ShowNotif("info", "Sequence Complete", "Master loop runs finished or stopped.")
    
    ResetIndicators()
}