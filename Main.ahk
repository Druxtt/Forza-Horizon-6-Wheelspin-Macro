; ╔═════════════════════════════════════════╗
; ║        MHI - FH6 Wheelspin Macro		║
; ║        Cyber Noir Edition v1.4.0        ║
; ╚═════════════════════════════════════════╝

#Requires AutoHotkey v2.0

#MaxThreadsPerHotkey 2
#SingleInstance Force

#Include Lib\OCR.ahk

#Include Modules\Config.ahk
#Include Modules\UI.ahk
#Include Modules\Engine.ahk
#Include Modules\Task_Race.ahk

; Construct and display the visual interface
BuildGui()

; ══════════════════════════════════════════════
;  GAME-FOCUS BOUNDED HOTKEYS
; ══════════════════════════════════════════════
#HotIf WinActive(GameTitle)

\::StartRace()
[::StartBuy()
]::StartUnlock()
/::ToggleAll()
F12::Reload()
`::TogglePause()
^+c::GetCoordsColor()

#HotIf