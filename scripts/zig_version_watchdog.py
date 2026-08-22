#!/usr/bin/env python3
"""
Zig Release Watchdog & Version Translation Pipeline
1. Queries https://ziglang.org/download/index.json daily.
2. If a new Zig release is published, extracts docs, updates tracked versions, builds and deploys.
"""

import json
import urllib.request
import os
import sys
import subprocess
from pathlib import Path

REPO_ROOT = Path("/home/cycorld/projects/zig-guide-kr")
TRACKED_FILE = REPO_ROOT / "tracked_versions.json"


def fetch_versions():
    url = "https://ziglang.org/download/index.json"
    req = urllib.request.Request(url, headers={"User-Agent": "ZigGuideKR-Watchdog/1.0"})
    with urllib.request.urlopen(req, timeout=20) as resp:
        data = json.loads(resp.read().decode("utf-8"))
    releases = [k for k in data.keys() if k != "master"]
    return releases, data


def main():
    releases, data = fetch_versions()
    if not releases:
        print(json.dumps({"error": "No releases found"}))
        return

    latest_upstream = releases[0]  # First key is the latest release

    if not TRACKED_FILE.exists():
        initial_state = {
            "latest_release": latest_upstream,
            "all_known": releases,
            "last_checked_at": "init",
        }
        TRACKED_FILE.write_text(json.dumps(initial_state, indent=2), encoding="utf-8")
        print(json.dumps({"status": "initialized", "latest_version": latest_upstream}))
        return

    state = json.loads(TRACKED_FILE.read_text(encoding="utf-8"))
    known_latest = state.get("latest_release", "")

    if latest_upstream == known_latest:
        print(json.dumps({"status": "no_change", "current_version": known_latest}))
        return

    # New version detected!
    print(
        json.dumps(
            {
                "status": "new_version_detected",
                "old_version": known_latest,
                "new_version": latest_upstream,
                "release_date": data.get(latest_upstream, {}).get("date"),
                "release_notes": data.get(latest_upstream, {}).get("notes"),
                "docs_url": data.get(latest_upstream, {}).get("docs"),
            }
        )
    )


if __name__ == "__main__":
    main()
