; ──────────────────────────────────────────────────────────────
; RELOAD AHK
; ──────────────────────────────────────────────────────────────

^!r:: { ;        Ctrl+Alt+R
    Reload
    return
}

; ── other fun things ─────────────────────────────────────
::;d::
{
    formatted := FormatTime(A_Now, "yyyy-MM-dd")
    Send formatted
}

::;t::
{
    formatted := FormatTime(A_Now, "HH:mm")
    Send formatted
}

::;dt::
{
    formatted := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
    Send formatted
}

::;now::
{
    formatted := FormatTime(A_Now, "dddd, MMMM d, yyyy 'at' h:mm tt")
    Send formatted
}

; ──────────────────────────────────────────────────────────────
; LaTeX highlighted text
; ──────────────────────────────────────────────────────────────

^+m:: {                                     ; Ctrl+Shift+M → make LaTeX-friendly math text
    saved := ClipboardAll()                 ; backup full clipboard (all formats)

    ; Copy current selection
    A_Clipboard := ""                       ; clear to detect the new copy
    Send "^c"
    if !ClipWait(0.3) {                     ; wait up to 0.3s for clipboard to fill
        Clipboard := saved                  ; restore if nothing copied
        return
    }

    ; Transform: replace spaces with "\ "
    text := A_Clipboard
    text := StrReplace(text, " ", "\ ")

    ; Wrap in $...$
    A_Clipboard := "$" . text . "$"

    ; Paste back over the selection
    Send "{Blind}^v"

    ; Restore original clipboard
    Clipboard := saved
}
