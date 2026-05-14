#!/usr/bin/env python3

import json
import subprocess
import sys


def get_package_info(name: str) -> dict:
    try:
        result = subprocess.run(
            ["yay", "-Si", name],
            capture_output=True,
            text=True,
            timeout=10,
        )
        if result.returncode != 0:
            return {}

        info = {}
        current_key = ""
        for line in result.stdout.split("\n"):
            if ":" in line and not line.startswith(" "):
                parts = line.split(":", 1)
                key = parts[0].strip().lower().replace(" ", "_")
                value = parts[1].strip()
                info[key] = value
                current_key = key
            elif line.startswith(" ") and current_key:
                info[current_key] += " " + line.strip()

        return {
            "name": info.get("name", name),
            "version": info.get("version", ""),
            "description": info.get("description", ""),
            "url": info.get("url", ""),
            "licenses": info.get("licenses", ""),
            "depends_on": info.get("depends_on", "None"),
            "download_size": info.get("download_size", ""),
            "installed_size": info.get("installed_size", ""),
            "repository": info.get("repository", ""),
            "maintainer": info.get("maintainer", ""),
            "packager": info.get("packager", ""),
        }

    except Exception:
        return {}


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("{}")
        sys.exit(0)

    print(json.dumps(get_package_info(sys.argv[1])))
