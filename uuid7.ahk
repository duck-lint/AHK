#Requires AutoHotkey v2.0
#SingleInstance Force

; === CONFIG ===
Uuid7Script := "C:\Users\madis\Desktop\kháos\tools_uuid7.py"

; === UUIDv7 generator via python script ===
GetUuid7(scriptPath) {
    if !FileExist(scriptPath)
        throw Error("UUID script not found:`n" scriptPath)

    shell := ComObject("WScript.Shell")
    cmd := Format('python "{}"', scriptPath)

    ; Exec() avoids spawning a visible console window
    exec := shell.Exec(cmd)

    out := Trim(exec.StdOut.ReadAll())
    err := Trim(exec.StdErr.ReadAll())

    if (out = "")
        throw Error("Empty stdout from uuid script.`nStderr:`n" err)

    ; If extra output exists, grab the first UUID-looking token
    if RegExMatch(out, "i)([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})", &m)
        out := m[1]

    ; Strict UUIDv7-ish check: version=7, variant=8/9/a/b
    if !RegExMatch(out, "i)^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$")
        throw Error("Bad UUID from script:`n" out "`nlen=" StrLen(out))

    return out
}

; === Reliable paste (avoids dropped keystrokes in Electron apps) ===
PasteText(text) {
    oldClip := A_Clipboard
    A_Clipboard := text
    if !ClipWait(1)
        throw Error("Clipboard did not update in time.")
    Send("^v")
    Sleep(50)
    A_Clipboard := oldClip
}

; === Hotstring: ;uuid7 (press space/enter to trigger; end-char is not inserted) ===
:O:;uuid7::
{
    hwnd := WinGetID("A")
    Critical(2000)
    BlockInput("On")
    try {
        uuid := GetUuid7(Uuid7Script)
        WinActivate("ahk_id " hwnd)
        Sleep(30)
        PasteText(uuid)
    } catch as e {
        WinActivate("ahk_id " hwnd)
        MsgBox("UUID failed:`n`n" e.Message)
    }
    BlockInput("Off")
}

; === Hotstring: ;yamlmin (press space/enter to trigger; end-char is not inserted) ===
:O:;yamlmin::
{
    hwnd := WinGetID("A")
    Critical(2000)
    BlockInput("On")
    try {
        uuid := GetUuid7(Uuid7Script)

        yaml := "---`n"
            . "note_type: `n"
            . "note_status: inbox`n"
            . "note_version: v`n"
            . "uuid: " uuid "`n"
            . "aliases: []`n"
            . "tags: []`n"
            . "note_creation_date: `n"
            . "last_modified_date: `n"
            . "schema_version: v0.1.0`n"
            . "layer: `n"
            . "unity_level: `n"
            . "vector_direction: `n"
            . "register: `n"
            . "register_mode: `n"
            . "pillar: `n"
            . "---`n`n"

        WinActivate("ahk_id " hwnd)
        Sleep(30)
        PasteText(yaml)
    } catch as e {
        WinActivate("ahk_id " hwnd)
        MsgBox("yamlmin failed:`n`n" e.Message)
    }
    BlockInput("Off")
}
