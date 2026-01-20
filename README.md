# Put main.ahk into startup folder
```
win+R
shell:startup
```

## Prefilled frontmatter strings in uuid7 script are specific to custom YAML key schema

# AHK Utilities

## Backfill YAML frontmatter

Dry run:

```powershell
python backfill_yaml.py --vault_root "\path\to\vault" --uuid7_script "\path\to\tools_uuid7.py" --dry_run
```

Apply changes:

```powershell
python backfill_yaml.py --vault_root "C:\path\to\vault" --uuid7_script "\path\to\tools_uuid7.py" --apply
```

Apply with a cap:

```powershell
python backfill_yaml.py --vault_root "C:\path\to\vault" --uuid7_script "\path\to\tools_uuid7.py" --apply --max_files 50
```
