;-------------------------------------------------------------------
; Settings
;-------------------------------------------------------------------
;#NoTrayIcon
#NoEnv
#SingleInstance force
SendMode Input
#MaxThreadsPerHotkey 1
SetTitleMatchMode, 2

;-------------------------------------------------------------------
; Caps Lock - Chrome will be brought into focus, a new
; tab will be created, the address bar will be highlighted.
; If Chrome isn't open, this script will see to that.
;-------------------------------------------------------------------
Capslock::
If WinExist("ahk_class Chrome_WidgetWin_0")
{
  WinActivate
  WinWaitActive
}
else
{
  Run "C:\Users\Eric\AppData\Local\Google\Chrome\Application\chrome.exe"
  while(WinExist("ahk_class Chrome_WidgetWin_0") = false)
    sleep 100
}
  Send ^t^l
  
return
+Capslock::Capslock
;end Caps Lock Search
;
;

;-------------------------------------------------------------------
; Windows+t is - empty recycle bin of the C drive
;-------------------------------------------------------------------
#t::
  FileRecycleEmpty
  MsgBox Trash emptied on drives C
return
; end empty trash script
;
;

;-------------------------------------------------------------------
; Windows+h - toggle visibility of hidden files
;-------------------------------------------------------------------
#h:: 
  RegRead, HiddenFiles_Status, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden 
  If (HiddenFiles_Status = 2) 
  RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 1 
  Else  
  RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 2 
  WinGetClass, eh_Class,A 
  If (eh_Class = "#32770" OR A_OSVersion = "WIN_VISTA") 
  send, {F5} 
  Else PostMessage, 0x111, 28931,,, A 
Return
;end toggle hidden files visibility script
;
;

;-------------------------------------------------------------------
; Control+Alt+h - openes cmd to current path in explorer
;-------------------------------------------------------------------
#IfWinActive ahk_class CabinetWClass
^!h::
  ClipSaved := ClipboardAll
  Send !d^c
  StringLeft, drive, clipboard, 2
  Run, cmd /K "%drive% & cd `"%clipboard%`""
  Clipboard := ClipSaved
  VarSetCapacity(ClipSaved, 0)
  VarSetCapacity(drive, 0)
  return
#IfWinActive
;end open cmd from explorer
;
;

;-------------------------------------------------------------------
; Windows+l - display black screen
;-------------------------------------------------------------------
;#l::
;  Sleep 250
;  Run nircmd screensaver
;return
;end lock workstation script
;
;

;-------------------------------------------------------------------
; Control+Alt+e - eject tray
;-------------------------------------------------------------------
;^!e::
;  Run nircmd cdrom open e:
;return
;end eject tray script
;
;-------------------------------------------------------------------
; Control+Shift+e - close tray
;-------------------------------------------------------------------
;^+e::
;  Run nircmd cdrom close e:
;return
;end closet tray script
;
;

;-------------------------------------------------------------------
; Control+Shift+c - google search highlighted text
;-------------------------------------------------------------------
^+c::
  ClipSaved := ClipboardAll
  Send ^c
;----- Opens a new tab in Chrome
If WinExist("ahk_class Chrome_WidgetWin_0")
{
  WinActivate
  WinWaitActive
}
else
{
  Run C:\Users\Eric\AppData\Local\Google\Chrome\Application\chrome.exe
  while(WinExist("ahk_class Chrome_WidgetWin_0") = false)
    sleep 100
	
  WinActivate
  WinWaitActive
}
;----- Searches google
  Send ^t^l
  Sleep 100
  Send ^v{Enter}
  Clipboard := ClipSaved
  VarSetCapacity(ClipSaved, 0)
return
;end google highlighted text script
;
;

;-------------------------------------------------------------------
; Volume Control
;-------------------------------------------------------------------
;#PrintScreen::Send {Volume_Mute}
;#ScrollLock::Send {Volume_Down}
;#Pause::Send {Volume_Up}

;-------------------------------------------------------------------
; Configuring keys to mimic Mac
;-------------------------------------------------------------------
LCtrl::LWin
LWin::LCtrl
RAlt::End
RWin::Home
^e::#e
^q::Send {Alt Down}{F4}{Alt Up}
^h::Send {Alt Downl}{Space}{Alt Up}n