import argparse
import fnmatch
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

UUID_RE = re.compile(
    r"([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})",
    re.IGNORECASE,
)
UUIDV7_RE = re.compile(
    r"^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$",
    re.IGNORECASE,
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Backfill YAML frontmatter for markdown notes without it."
    )
    parser.add_argument("--vault_root", required=True, help="Root of the Obsidian vault.")
    parser.add_argument(
        "--uuid7_script",
        required=True,
        help="Path to the UUIDv7 generator script (tools_uuid7.py).",
    )
    parser.add_argument(
        "--exclude",
        action="append",
        default=[],
        help="Glob pattern to exclude (repeatable).",
    )
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--dry_run", action="store_true", help="Print changes only.")
    group.add_argument("--apply", action="store_true", help="Apply changes to files.")
    parser.add_argument(
        "--max_files",
        type=int,
        default=0,
        help="Stop after modifying N files (0 = no limit).",
    )
    args = parser.parse_args()

    if not args.dry_run and not args.apply:
        args.dry_run = True

    return args


def normalize_excludes(excludes):
    defaults = [".obsidian/**", ".git/**"]
    all_patterns = defaults + excludes
    return [pattern.replace("\\", "/") for pattern in all_patterns]


def has_yaml_frontmatter(data: bytes) -> bool:
    lines = data.splitlines()
    first_index = None
    for i, line in enumerate(lines):
        if line.strip():
            first_index = i
            break
    if first_index is None:
        return False
    if lines[first_index] != b"---":
        return False

    saw_colon = False
    lines_seen = 0
    for line in lines[first_index + 1 :]:
        lines_seen += 1
        if lines_seen > 200:
            break
        if line == b"---":
            return saw_colon
        if b":" in line:
            saw_colon = True
    return False


def generate_uuid(uuid7_script: str) -> str:
    try:
        result = subprocess.run(
            [sys.executable, uuid7_script],
            capture_output=True,
            text=True,
            timeout=5,
        )
    except subprocess.TimeoutExpired as exc:
        raise RuntimeError("UUIDv7 generator timed out.") from exc

    match = UUID_RE.search(result.stdout or "")
    if not match:
        stderr = (result.stderr or "").strip()
        raise RuntimeError(f"Failed to parse UUIDv7. stderr: {stderr}")

    uuid = match.group(1).lower()
    if not UUIDV7_RE.fullmatch(uuid):
        stderr = (result.stderr or "").strip()
        raise RuntimeError(f"Invalid UUIDv7 format. stderr: {stderr}")

    return uuid


def build_yaml_block(uuid: str) -> bytes:
    yaml_lines = [
        "---",
        f"uuid: {uuid}",
        "note_version: v0.1.0",
        "schema_version: v0.1.2",
        "note_type:",
        "note_status:",
        "note_creation_date:",
        "aliases: []",
        "tags: []",
        "layer:",
        "unity_level:",
        "vector_direction:",
        "register:",
        "register_mode:",
        "pillar:",
        "---",
        "",
    ]
    yaml_text = "\n".join(yaml_lines) + "\n"
    return yaml_text.encode("utf-8")


def write_atomic(path: Path, data: bytes) -> None:
    temp_path = None
    try:
        with tempfile.NamedTemporaryFile(
            delete=False,
            dir=str(path.parent),
            prefix=f"{path.name}.",
            suffix=".tmp",
        ) as handle:
            temp_path = Path(handle.name)
            handle.write(data)
        os.replace(temp_path, path)
    finally:
        if temp_path and temp_path.exists():
            try:
                temp_path.unlink()
            except OSError:
                pass


def main() -> int:
    args = parse_args()
    vault_root = Path(args.vault_root)
    uuid7_script = str(Path(args.uuid7_script))
    excludes = normalize_excludes(args.exclude)

    counts = {
        "scanned": 0,
        "skipped_hidden_dir": 0,
        "skipped_excluded": 0,
        "skipped_has_yaml": 0,
        "modified": 0,
        "errors": 0,
    }
    modified_paths = []
    stop_processing = False

    for root, dirs, files in os.walk(vault_root):
        hidden_dirs = [d for d in dirs if d.startswith(".")]
        for d in hidden_dirs:
            dirs.remove(d)
            counts["skipped_hidden_dir"] += 1

        for filename in files:
            if stop_processing:
                break
            if not filename.lower().endswith(".md"):
                continue

            path = Path(root) / filename
            rel_path = path.relative_to(vault_root).as_posix()
            counts["scanned"] += 1

            if any(fnmatch.fnmatchcase(rel_path, pattern) for pattern in excludes):
                counts["skipped_excluded"] += 1
                continue

            try:
                data = path.read_bytes()
            except OSError as exc:
                counts["errors"] += 1
                print(f"ERROR: {rel_path}: {exc}", file=sys.stderr)
                continue

            if has_yaml_frontmatter(data):
                counts["skipped_has_yaml"] += 1
                continue

            if args.max_files and counts["modified"] >= args.max_files:
                stop_processing = True
                break

            if args.dry_run:
                print(f"DRY RUN: would modify {rel_path}")
                counts["modified"] += 1
                modified_paths.append(rel_path)
                continue

            try:
                uuid = generate_uuid(uuid7_script)
                new_data = build_yaml_block(uuid) + data
                write_atomic(path, new_data)
            except Exception as exc:
                counts["errors"] += 1
                print(f"ERROR: {rel_path}: {exc}", file=sys.stderr)
                continue

            counts["modified"] += 1
            modified_paths.append(rel_path)

        if stop_processing:
            break

    print("Summary:")
    for key in (
        "scanned",
        "skipped_hidden_dir",
        "skipped_excluded",
        "skipped_has_yaml",
        "modified",
        "errors",
    ):
        print(f"{key}: {counts[key]}")

    if modified_paths:
        print("Modified files (up to 20):")
        for rel_path in modified_paths[:20]:
            print(rel_path)

    if args.apply and counts["errors"] > 0:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
