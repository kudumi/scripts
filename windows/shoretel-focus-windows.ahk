/* A hotkey to reload the script quickly
 */
#!+r::
{
    Reload ;
    return ;
}

/* This function will react in the following way to a specified window:
 * If unfocused  -> Focus,  and optionally
 * If none       -> create
 */
ManipulateWindow(title, descr, create = 0)
{
    If WinExist("ahk_class" + descr)
    {
	WinActivate ;
	WinMaximize ;
    }
    Else If (create != 0)
    {
	Run, %create%, , max ;
	WinActivate ;
    }
}

F1::
{
    ManipulateWindow("emacs", "cygwin/x X rl") ;
    return ;
}

F2::
{
    ManipulateWindow("Google Chrome", "Chrome_WidgetWin_1", "Chrome") ;
    return ;
}

F3::
{
    ManipulateWindow("Perforce","QWidget") ;
    return ;
}

F4::
{
    ManipulateWindow("PuTTY", "PuTTY") ;
    return ;
}

/* If PuTTY is active, enable logging on the current session
 */
#IfWinActive ahk_class PuTTY
^F4::
{
    delay := 100 ;
    Send cli{Enter} ;
    Sleep delay ;
    Send log on all{Enter} ;
    Sleep delay ;
    Send exit{Enter} ;
    Sleep delay ;
    Send tail -f /var/log/messages ;
    return ;
}
#IfWinActive

F10::
{
    ManipulateWindow("Microsoft Outlook", "rctrl_renwnd32") ;
    return ;
}

F11::
{
    ManipulateWindow("Windows Internet Explorer","IEFrame") ;
    return ;
}

F9::
{
    ManipulateWindow("Remote Desktop Connection","TscShellContainerClass") ;
    return ;
}
