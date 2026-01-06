; === CONFIG ===
Uuid7Script := "C:\Users\madis\Desktop\VS Code Workspace\Python\tools_uuid7.py"

; === UUIDv7 generator via python script ===
GetUuid7(scriptPath) {
    if !FileExist(scriptPath)
        throw Error("UUID script not found:`n" scriptPath)

    shell := ComObject("WScript.Shell")
    cmd := Format('python "{}"', scriptPath)

    exec := shell.Exec(cmd)

    timeoutMs := 2000
    start := A_TickCount
    while (exec.Status = 0) {
        if (A_TickCount - start) > timeoutMs {
            try exec.Terminate()
            throw Error("UUID script timed out after " timeoutMs "ms.")
        }
        Sleep(25)
    }

    out := Trim(exec.StdOut.ReadAll())
    err := Trim(exec.StdErr.ReadAll())

    if (out = "")
        throw Error("Empty stdout from uuid script.`nStderr:`n" err)

    if RegExMatch(out, "i)([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})", &m)
        out := m[1]

    if !RegExMatch(out, "i)^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$")
        throw Error("Bad UUID from script:`n" out "`nlen=" StrLen(out))

    return out
}

; === Reliable paste (avoids dropped keystrokes in Electron apps) ===
PasteText(text) {
    oldClip := A_Clipboard
    try {
        A_Clipboard := text
        if !ClipWait(1)
            throw Error("Clipboard did not update in time.")
        Send("^v")
        Sleep(50)
    } finally {
        A_Clipboard := oldClip
    }
}

; === Hotstring: ;uuid7 (press space/enter to trigger; end-char is not inserted) ===
:O:;uuid7::
{
    hwnd := WinGetID("A")
    Critical(2000)

    try {
        ; Generate UUID FIRST (no input blocking while python runs)
        uuid := GetUuid7(Uuid7Script)

        WinActivate("ahk_id " hwnd)
        WinWaitActive("ahk_id " hwnd, , 1)

        BlockInput("On")
        try {
            PasteText(uuid)
        } finally {
            BlockInput("Off")
        }
    } catch as e {
        try BlockInput("Off")  ; extra paranoia
        WinActivate("ahk_id " hwnd)
        MsgBox("UUID failed:`n`n" e.Message)
    }
}

; === Hotstring: ;yamlb (press space/enter to trigger; end-char is not inserted) ===
:O:;yamlb::
{
    hwnd := WinGetID("A")
    Critical(2000)

    try {
        uuid := GetUuid7(Uuid7Script)

        yaml := "---`n"
            . "uuid: " uuid "`n"
            . "note_version: v0.1.0`n"
            . "schema_version: v0.1.2`n"
            . "note_type: `n"
            . "note_status: `n"
            . "note_creation_date: `n"
            . "aliases: []`n"
            . "tags: []`n"
            . "layer: `n"
            . "unity_level: `n"
            . "vector_direction: `n"
            . "register: `n"
            . "register_mode: `n"
            . "pillar: `n"
            . "---`n`n"

        WinActivate("ahk_id " hwnd)
        WinWaitActive("ahk_id " hwnd, , 1)

        BlockInput("On")
        try {
            PasteText(yaml)
        } finally {
            BlockInput("Off")
        }
    } catch as e {
        try BlockInput("Off")
        WinActivate("ahk_id " hwnd)
        MsgBox("yamlb failed:`n`n" e.Message)
    }
}

; === Hotstring: ;yamlj (press space/enter to trigger; end-char is not inserted) ===
:O:;yamlj::
{
    hwnd := WinGetID("A")
    Critical(2000)

    try {
        uuid := GetUuid7(Uuid7Script)

        yaml := "---`n"
            . "uuid: " uuid "`n"
            . "note_version: v0.1.0`n"
            . "schema_version: v0.1.2`n"
            . "note_type: journal_entry`n"
            . "note_status: journal`n"
            . "note_creation_date: `n"
            . 'layer: "1"`n'
            . "unity_level: model`n"
            . "vector_direction: critical`n"
            . "register: indexical`n"
            . "register_mode: experiential_commitment`n"
            . "pillar: dynamic_coherence`n"
            . "temporal_pace: `n"
            . "book_read_today: `n"
            . "hypnagogic_resonance: `n"
            . "reactivity: `n"
            . "racing_thoughts_while_awake: false`n"
            . "ran_script_when_racing: false`n"
            . "dream_motif: `n"
            . "dream_motif_valence: `n"
            . "dream_location: `n"
            . "recall_ability: `n"
            . "dream_lucidity: `n"
            . "transition_attempted: false`n"
            . "ran_script_yesterday: false`n"
            . "---`n`n"

        WinActivate("ahk_id " hwnd)
        WinWaitActive("ahk_id " hwnd, , 1)

        BlockInput("On")
        try {
            PasteText(yaml)
        } finally {
            BlockInput("Off")
        }
    } catch as e {
        try BlockInput("Off")
        WinActivate("ahk_id " hwnd)
        MsgBox("yamlj failed:`n`n" e.Message)
    }
}

; === Hotstring: ;yamlbdj (press space/enter to trigger; end-char is not inserted) ===
:O:;yamlbdj::
{
    hwnd := WinGetID("A")
    Critical(2000)

    try {
        uuid := GetUuid7(Uuid7Script)

        yaml := "---`n"
            . "uuid: " uuid "`n"
            . "note_version: v0.1.0`n"
            . "schema_version: v0.1.2`n"
            . "note_type: journal_entry`n"
            . "note_status: journal`n"
            . "note_creation_date: `n"
            . 'layer: "1"`n'
            . "unity_level: model`n"
            . "vector_direction: critical`n"
            . "register: indexical`n"
            . "register_mode: experiential_commitment`n"
            . "pillar: dynamic_coherence`n"
            . "---`n`n"

        WinActivate("ahk_id " hwnd)
        WinWaitActive("ahk_id " hwnd, , 1)

        BlockInput("On")
        try {
            PasteText(yaml)
        } finally {
            BlockInput("Off")
        }
    } catch as e {
        try BlockInput("Off")
        WinActivate("ahk_id " hwnd)
        MsgBox("yamlbdj failed:`n`n" e.Message)
    }
}

; === Hotstring: ;yamle (press space/enter to trigger; end-char is not inserted) ===
:O:;yamle::
{
    hwnd := WinGetID("A")
    Critical(2000)

    try {
        uuid := GetUuid7(Uuid7Script)

        yaml := "---`n"
            . "uuid: " uuid "`n"
            . "note_version: v0.1.0`n"
            . "schema_version: v0.1.2`n"
            . "note_type: entity`n"
            . "note_status: indexed`n"
            . "note_creation_date: `n"
            . "aliases: []`n"
            . "tags: []`n"
            . 'layer: "1"`n'
            . "unity_level: model`n"
            . "vector_direction: critical`n"
            . "register: public`n"
            . "register_mode: descriptive`n"
            . "pillar: semantic_geometry`n"
            . "entity_type: `n"
            . "canonical_name: `n"
            . "relationship: `n"
            . "first_met: `n"
            . "birthday: `n"
            . "phone: `n"
            . "email: `n"
            . "address: `n"
            . "occupation: `n"
            . "likes: `n"
            . "dislikes: `n"
            . "---`n`n"

        WinActivate("ahk_id " hwnd)
        WinWaitActive("ahk_id " hwnd, , 1)

        BlockInput("On")
        try {
            PasteText(yaml)
        } finally {
            BlockInput("Off")
        }
    } catch as e {
        try BlockInput("Off")
        WinActivate("ahk_id " hwnd)
        MsgBox("yamle failed:`n`n" e.Message)
    }
}

; === Hotstring: ;yamlm (press space/enter to trigger; end-char is not inserted) ===
:O:;yamlm::
{
    hwnd := WinGetID("A")
    Critical(2000)

    try {
        uuid := GetUuid7(Uuid7Script)

        yaml := "interface: `n"
            . "scope: `n"
            . "speculation_quarantine: `n"
            . "revision_triggers: `n"
            . "stop_rule: `n"
            . "from_register: `n"
            . "to_register: `n"
            . "from_mode: `n"
            . "to_mode: `n"
            . "bridge_methods: `n"
            . "bridge_conditions: `n"
            . "bridge_preservation: `n"
            . "bridge_broken: `n"
            . "bridge_justification: `n"
            . "bridge_ apllicability_scope: `n"
            . "bridge_isomorphism: false`n"
            . "iso_structure: `n"
            . "iso_broken: `n"
            . "iso_justification: `n"
            . "---`n`n"

        WinActivate("ahk_id " hwnd)
        WinWaitActive("ahk_id " hwnd, , 1)

        BlockInput("On")
        try {
            PasteText(yaml)
        } finally {
            BlockInput("Off")
        }
    } catch as e {
        try BlockInput("Off")
        WinActivate("ahk_id " hwnd)
        MsgBox("yamlm failed:`n`n" e.Message)
    }
}

; === Hotstring: ;yamlt (press space/enter to trigger; end-char is not inserted) ===
:O:;yamlt::
{
    hwnd := WinGetID("A")
    Critical(2000)

    try {
        uuid := GetUuid7(Uuid7Script)

        yaml := "root: `n"
            . "tension_type: `n"
            . "rhetoric_allowed: false`n"
            . "rhetorical_device: `n"
            . "bridge_rule_required: false`n"
            . "bridge_rule_applied: false`n"
            . "bridge_rule_uuids: `n"
            . "cash_out: `n"
            . "---`n`n"

        WinActivate("ahk_id " hwnd)
        WinWaitActive("ahk_id " hwnd, , 1)

        BlockInput("On")
        try {
            PasteText(yaml)
        } finally {
            BlockInput("Off")
        }
    } catch as e {
        try BlockInput("Off")
        WinActivate("ahk_id " hwnd)
        MsgBox("yamlt failed:`n`n" e.Message)
    }
}

; === Hotstring: ;yamlc (press space/enter to trigger; end-char is not inserted) ===
:O:;yamlc::
{
    hwnd := WinGetID("A")
    Critical(2000)

    try {
        uuid := GetUuid7(Uuid7Script)

        yaml := "title: `n"
            . "creator: `n"
            . "format: `n"
            . "publish_studio: `n"
            . "original_year_published: `n"
            . "origin: `n"
            . "---`n`n"

        WinActivate("ahk_id " hwnd)
        WinWaitActive("ahk_id " hwnd, , 1)

        BlockInput("On")
        try {
            PasteText(yaml)
        } finally {
            BlockInput("Off")
        }
    } catch as e {
        try BlockInput("Off")
        WinActivate("ahk_id " hwnd)
        MsgBox("yamlc failed:`n`n" e.Message)
    }
}
