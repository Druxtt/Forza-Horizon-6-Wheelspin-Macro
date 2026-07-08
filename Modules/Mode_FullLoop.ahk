; ╔═════════════════════════════════════════╗
; ║        MHI - FH6 Wheelspin Macro        ║
; ║            Cyber Noir Edition           ║
; ╚═════════════════════════════════════════╝

StartFullLoop() {
    global ActiveMode, MasterMode, StartLoopMode
    global LoopCount_In, SkillPtsScanSuccess

    LoopMode := StartLoopMode
    SkillPtsScanSuccess := false
    CustomCarCount := 0

    if FindGame() = 0
        return

    StartIndicators()
    MasterMode := !MasterMode

    if (MasterMode) {
        ShowNotif("success", "Master Loop Initiated", "Beginning automated event cycles.")
    }

    while (MasterMode && LoopCount_In.Value > 0) {

        if !LoopMode || LoopMode = "Race" {
            _UpdateStartLoop(RadioRace, "Race")
            StartRace()
            ActiveMode := ""
            LoopMode := ""
            if !MasterMode
                break
        }

        if !LoopMode || LoopMode = "Buy" {
            _UpdateStartLoop(RadioBuy, "Buy")
            StartBuy()
            ActiveMode := ""
            LoopMode := ""
            if !MasterMode
                break
        }

        if !LoopMode || LoopMode = "Unlock" {
            _UpdateStartLoop(RadioUnlock, "Unlock")
            StartUnlock()
            ActiveMode := ""
            LoopMode := ""
            if !MasterMode
                break
        }
        
        if SpinInFullLoop {
            OpenSpinPanel()
            StartSpin()
            ActiveMode := ""
            if !MasterMode
                break
            OnSpinClose()
        }

        Process("Restarting Race...")
        LoopCount_In.Value -= 1
    }
    
    if (MasterMode == "") {
        ShowNotif("info", "Sequence Complete", "Master loop runs finished or stopped.")
    }
    
    MasterMode := ""
    ResetIndicators()
}