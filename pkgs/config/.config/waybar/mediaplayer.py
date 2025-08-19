#!/usr/bin/env python3
import sys, json, subprocess

try:
    status = subprocess.check_output(
        ["playerctl", "metadata", "--format", "{{artist}} - {{title}}"],
        text=True
    ).strip()
    if not status:
        status = "No media"
except:
    status = "No player"

data = {
    "text": status,
    "alt": status,
    "tooltip": status,
    "class": "media"
}
print(json.dumps(data))

