#Requires AutoHotkey v2.0
#SingleInstance Force

doubleTapMs := 188  ; tweak to taste

lastSpaceTick := 0
spaceIsDown   := false

; Pass-through Space so other scripts still receive a real Space key
~$Space::
{
    global doubleTapMs, lastSpaceTick, spaceIsDown

    ; Ignore auto-repeat while holding Space (let Windows keep repeating spaces)
    if spaceIsDown
        return
    spaceIsDown := true

    ; Holding any modifier forces normal behavior (and cancels double-tap tracking)
    if GetKeyState("Shift","P") || GetKeyState("Ctrl","P") || GetKeyState("Alt","P")
        || GetKeyState("LWin","P") || GetKeyState("RWin","P")
    {
        lastSpaceTick := 0
        return
    }

    now := A_TickCount

    ; On second space within window: remove BOTH spaces, then insert ". "
    if (A_PriorKey = "Space" && lastSpaceTick && (now - lastSpaceTick) <= doubleTapMs) {
        SendInput "{BS 2}. "
        lastSpaceTick := 0
    } else {
        lastSpaceTick := now
    }
}

~$Space up::
{
    global spaceIsDown
    spaceIsDown := false
}
