#!/bin/bash

python3 -c "import socket; s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM); s.connect('/tmp/quickshell_clipboard'); s.close()" 2>/dev/null
