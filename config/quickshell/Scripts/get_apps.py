import configparser
import json
import os
from pathlib import Path


def get_apps():
    apps = []
    seen_execs = set()
    paths = [
        Path("/usr/share/applications"),
        Path(os.path.expanduser("~/.local/share/applications")),
    ]

    for d in paths:
        if not d.exists():
            continue
        for f in d.glob("*.desktop"):
            try:
                config = configparser.ConfigParser(interpolation=None)
                config.read(f)
                if "Desktop Entry" in config:
                    entry = config["Desktop Entry"]

                    if (
                        entry.get("NoDisplay", "false").lower() == "true"
                        or entry.get("Hidden", "false").lower() == "true"
                    ):
                        continue

                    name = entry.get("Name", "")
                    raw_exec = entry.get("Exec", "")
                    executable = raw_exec.split(" %")[0].replace('"', "")

                    if executable.startswith("/usr/bin/"):
                        executable = executable[9:]

                    icon = entry.get("Icon", "")
                    terminal = entry.get("Terminal", "false").lower() == "true"

                    actions = []
                    if "Actions" in entry:
                        action_keys = entry.get("Actions", "").strip(';').split(';')
                        for ak in action_keys:
                            ak = ak.strip()
                            if not ak: continue
                            action_group = f"Desktop Action {ak}"
                            if action_group in config:
                                a_entry = config[action_group]
                                a_name = a_entry.get("Name", "")
                                a_exec = a_entry.get("Exec", "")
                                if a_name and a_exec:
                                    actions.append({
                                        "name": a_name,
                                        "exec": a_exec.split(" %")[0].replace('"', '')
                                    })

                    if name and executable and executable not in seen_execs:
                        apps.append(
                            {
                                "name": name,
                                "exec": raw_exec.split(" %")[0],
                                "icon": icon,
                                "terminal": terminal,
                                "actions": actions,
                            }
                        )
                        seen_execs.add(executable)
            except Exception:
                pass

    return sorted(apps, key=lambda x: x["name"].lower())


if __name__ == "__main__":
    print(json.dumps(get_apps()))
