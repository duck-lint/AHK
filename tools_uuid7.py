import os
import time
import json
import secrets
import re
import sys

# --- Where to store monotonic state (per machine/user) ---
# Uses LOCALAPPDATA on Windows; falls back to script directory.
def _state_path() -> str:
    base = os.getenv("LOCALAPPDATA")
    if base:
        d = os.path.join(base, "uuid7")
        os.makedirs(d, exist_ok=True)
        return os.path.join(d, "uuid7_state.json")
    return os.path.join(os.path.dirname(os.path.abspath(__file__)), "uuid7_state.json")


def _now_ms_48() -> int:
    # Milliseconds since epoch, clipped to 48 bits.
    ts_ms = time.time_ns() // 1_000_000
    return ts_ms & ((1 << 48) - 1)


def uuid7_monotonic() -> str:
    """
    UUIDv7 with per-machine monotonicity across separate process invocations.
    Strategy:
      - 48-bit ms timestamp
      - 12-bit "rand_a" becomes a counter that increments within the same ms
      - 62-bit rand_b stays random
      - persistent state: { "last_ts_ms": int, "last_counter": int }
    """

    path = _state_path()
    lock_path = path + ".lock"

    # Lock file to prevent concurrent runs from corrupting state.
    # This is simple and sufficient for your AHK "one at a time" workflow.
    # If a stale lock ever happens (crash), it's safe to delete the .lock file.
    for _ in range(200):  # ~2 seconds max (200 * 10ms)
        try:
            fd = os.open(lock_path, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
            os.close(fd)
            break
        except FileExistsError:
            time.sleep(0.01)
    else:
        raise RuntimeError(f"Could not acquire lock: {lock_path}")

    try:
        # Load state
        state = {"last_ts_ms": -1, "last_counter": -1}
        try:
            with open(path, "r", encoding="utf-8") as f:
                loaded = json.load(f)
                if isinstance(loaded, dict):
                    state["last_ts_ms"] = int(loaded.get("last_ts_ms", -1))
                    state["last_counter"] = int(loaded.get("last_counter", -1))
        except FileNotFoundError:
            pass

        # Decide timestamp + counter
        ts_ms = _now_ms_48()

        last_ts = state["last_ts_ms"]
        last_ctr = state["last_counter"]

        if ts_ms > last_ts:
            # New millisecond: start counter at a random 12-bit value.
            ctr = secrets.randbits(12)
        else:
            # Same (or backwards) millisecond: force monotonicity.
            # If clock went backwards, pin to last_ts to keep ordering.
            ts_ms = last_ts
            ctr = (last_ctr + 1) & 0xFFF
            if ctr == 0:
                # Counter overflow (4096 IDs in the same ms).
                # Extremely unlikely in your use. We wait for next ms.
                while True:
                    ts_ms2 = _now_ms_48()
                    if ts_ms2 > last_ts:
                        ts_ms = ts_ms2
                        ctr = secrets.randbits(12)
                        break
                    time.sleep(0.001)

        # Build UUID bits:
        #  - timestamp: 48 bits at top
        #  - version: 7
        #  - rand_a / counter: 12 bits
        #  - variant: RFC4122 (10xx...)
        #  - rand_b: 62 bits
        rand_b = secrets.randbits(62)
        u = (ts_ms << 80) | (0x7 << 76) | (ctr << 64) | (0x2 << 62) | rand_b

        # Persist state
        with open(path, "w", encoding="utf-8") as f:
            json.dump({"last_ts_ms": ts_ms, "last_counter": ctr}, f)

        # Format UUID
        h = f"{u:032x}"
        s = f"{h[:8]}-{h[8:12]}-{h[12:16]}-{h[16:20]}-{h[20:]}"
        return s

    finally:
        # Release lock
        try:
            os.remove(lock_path)
        except FileNotFoundError:
            pass


if __name__ == "__main__":
    s = uuid7_monotonic()

    # Validate format: version nibble 7 + RFC variant 8/9/a/b
    ok = re.match(
        r"^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$",
        s,
    )
    if not ok:
        print("BAD_UUID:", s, "len=", len(s), file=sys.stderr)
        sys.exit(1)

    print(s)
