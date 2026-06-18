; ╔═════════════════════════════════════════╗
; ║        MHI - FH6 Wheelspin Macro		║
; ║        Cyber Noir Edition v1.6.0        ║
; ╚═════════════════════════════════════════╝

#Requires AutoHotkey v2.0

; ══════════════════════════════════════════════
;  ENVIRONMENT & WINDOW DEFINITIONS
; ══════════════════════════════════════════════
global GameTitle := "ahk_exe ForzaHorizon6.exe"

global ActiveMode     := ""
global PauseMode      := ""
global MasterMode     := ""
global MasterStart    := ""
global RaceStart      := ""

global DarkMode       := true
global MyGui          := ""
global StatusText     := ""

global Key_UI         := ""
global Process_UI     := ""

global SkillPtsCount_In := 0
global SkillPtsWant_In  := 0
global CarCount_In      := 0
global LoopCount_In     := 0
global CustomSkillPts   := false

global cActive        := "FF8FAB"
global cHighlight     := "39FF14"
global cIdle          := "7A4A60"
global cTextDim       := "7A4A60"

global TotalRunSeconds  := 0
global RaceRunSeconds   := 0
global BuyRunSeconds    := 0
global UnlockRunSeconds := 0
global SpinRunSeconds   := 0

global PointsTotal      := 0
global PointsGain       := 0
global TimeTotal        := 0

global SpinMode         := "KEEP"
global UserTier         := "STANDARD"

; ══════════════════════════════════════════════
;  BALANCING PRESETS & TUNING METRICS
; ══════════════════════════════════════════════
global SelectedCar      := "Subaru Impreza 22B-STi"
global SelectedCarPoint := 30

global SelectedCode     := "AMMAGEDON"
global AveragePoints    := 9.9
global MaxPoints        := 990
global MaxSections      := 100

global SpeedLabel_UI    := ""
global DelaySlider_UI   := ""
global Multipliers      := [0.25, 0.5, 0.75, 1, 1.5, 2, 2.5]
global CurrentMultiplier := 1

global CodeTune         := "293391902"
global CodeEventLab     := "102089819"

global GuiWidth         := "w270"

; ══════════════════════════════════════════════
;  MONITOR SETTINGS
; ══════════════════════════════════════════════
; Set to 1 for primary monitor, 2 for second monitor, etc.
global GameMonitor      := 1