# AHK Workflow Utilities

Small AutoHotkey + Python utilities for reducing repetitive admin friction and enforcing structured metadata in knowledge workflows.

## Use case (why this exists)

I use this repo to speed up high-frequency “paperwork” actions: consistent IDs, consistent frontmatter, and fewer manual edits across a large note vault. It’s meant for situations where small inconsistencies snowball into messy retrieval, broken links, or unclear provenance later. The AHK layer handles fast insertion/typing helpers, while the Python layer handles deterministic generation (UUIDv7) and safe bulk edits (YAML backfill). The tooling is intentionally simple: explicit paths, inspectable scripts, and dry-run before mutation. If you’re doing implementation-style work (enablement + process + repeatability), this is the same muscle—just applied to personal workflows.

---

## Components

### 1) Global hotstrings and typing helpers (AutoHotkey v2)

- Short string expansions
- Longer command-style insertions
- Double-tap period helper
- UUIDv7 insertion (via Python script)

`main.ahk` is the entry point and includes the individual modules.

To run at startup:

```
Win + R
shell:startup
````

Place `main.ahk` in the Startup folder.

---

### 2) UUIDv7 generation

`uuid7.ahk` calls a small Python script (`tools_uuid7.py`) to generate sortable UUIDv7 values.

Why UUIDv7?
- Time-ordered identifiers
- Better sorting behavior
- Useful for stable note IDs / audit trails

Update the path in `uuid7.ahk`:

```python
Uuid7Script := "path\\to\\tools_uuid7.py"
````

---

### 3) YAML frontmatter backfill

`backfill_yaml.py` scans a vault and inserts missing YAML frontmatter using UUIDv7.

Designed for:

* Retrofitting structured IDs into legacy notes
* Enforcing schema consistency
* Safe, staged runs (dry-run first)

Dry run:

```powershell
python backfill_yaml.py --vault_root "C:\path\to\vault" --uuid7_script "path\to\tools_uuid7.py" --dry_run
```

Apply changes:

```powershell
python backfill_yaml.py --vault_root "C:\path\to\vault" --uuid7_script "path\to\tools_uuid7.py" --apply
```

Apply with a cap:

```powershell
python backfill_yaml.py --vault_root "C:\path\to\vault" --uuid7_script "path\to\tools_uuid7.py" --apply --max_files 50
```

---

## Design principles

* Automate repetitive friction.
* Prefer structured metadata over ad-hoc conventions.
* Always support dry-run before mutation.
* Keep tooling small, explicit, and inspectable.

---

## Requirements

* AutoHotkey v2
* Python 3.x
