import os
import json
import configparser
from pathlib import Path

def get_apps():
    apps = []
    seen_execs = set()
    paths = [
        Path('/usr/share/applications'),
        Path(os.path.expanduser('~/.local/share/applications'))
    ]
    for d in paths:
        if not d.exists():
            continue
        for f in d.glob('*.desktop'):
            try:
                config = configparser.ConfigParser(interpolation=None)
                config.read(f)
                if 'Desktop Entry' in config:
                    entry = config['Desktop Entry']
                    if entry.getboolean('NoDisplay', False) or entry.getboolean('Hidden', False):
                        continue
                    name = entry.get('Name', '')
                    executable = entry.get('Exec', '').split(' %')[0].replace('"', '')
                    if executable.startswith('/usr/bin/'):
                        executable = executable[9:]
                    
                    icon = entry.get('Icon', '')
                    terminal = entry.getboolean('Terminal', False)
                    if name and executable and executable not in seen_execs:
                        apps.append({
                            'name': name,
                            'exec': entry.get('Exec', '').split(' %')[0],
                            'icon': icon,
                            'terminal': terminal
                        })
                        seen_execs.add(executable)
            except Exception:
                pass
    return sorted(apps, key=lambda x: x['name'].lower())

if __name__ == "__main__":
    print(json.dumps(get_apps()))
