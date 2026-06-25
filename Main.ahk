; ╔═════════════════════════════════════════╗
; ║        MHI - FH6 Wheelspin Macro        ║
; ║        Cyber Noir Edition v1.8.0        ║
; ╚═════════════════════════════════════════╝

#Requires AutoHotkey v2.0

; AUTOMATIC ADMIN ENFORCER
; If the script isn't Admin, it restarts itself as Admin so it can control the game window.
; if !A_IsAdmin {
;     Run('*RunAs "' A_ScriptFullPath '"')
;     ExitApp()
; }

#MaxThreadsPerHotkey 2
#SingleInstance Force

#Include Lib\OCR.ahk

#Include modules\Config.ahk
#Include modules\MainGUI.ahk
#Include modules\MiniGUI.ahk
#Include modules\Engine.ahk
#Include modules\Task_Race.ahk
#Include modules\Task_Buy.ahk
#Include modules\Task_Unlock.ahk
#Include modules\Task_Spin.ahk
#Include modules\SpecialK.ahk

;@Ahk2Exe-SetMainIcon assets\icon.ico

; Setup tray icon dynamically
if A_IsCompiled {
    TraySetIcon(A_ScriptFullPath)  ; Pulls the embedded icon directly from the EXE
} else {
    TraySetIcon(A_ScriptDir "\assets\icon.ico") ; Standard path used while testing uncompiled
}

; ══════════════════════════════════════════════
;  GAME-FOCUS BOUNDED HOTKEYS
; ══════════════════════════════════════════════

; Tell AHK to keep running in the background to listen for hotkeys
Persistent(true)

SetTimer(SpoofWindowFocus, 250) ; Fires every 250ms

#HotIf WinActive(GameTitle)

\::StartRace()
[::StartBuy()
]::StartUnlock()
/::ToggleAll()
`::TogglePause()
^+c::GetCoordsColor()
F5::ToggleDetectionZone()
; F10::ToggleWindowLock()
; F11::SetGameResolution()
F12::Reload()
!LButton::MoveWindow()

#HotIf

#HotIf IsSpinGuiOpen()

=::StartSpin() 

#HotIf