#!/usr/bin/env python3
import os, socket, subprocess

hypr_dir = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "hypr")
instances = os.listdir(hypr_dir)
if not instances:
    exit(1)

sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
sock.connect(os.path.join(hypr_dir, instances[0], ".socket2.sock"))

last = ""
while True:
    data = sock.recv(4096).decode()
    for line in data.splitlines():
        if line.startswith("activelayout"):
            layout = line.split(",", 1)[-1].strip()
            if layout and layout != last:
                last = layout
                if "Russian" in layout:
                    color, text = "rgb(ff6b6b)", "RU"
                elif "English" in layout:
                    color, text = "rgb(6bcbff)", "US"
                else:
                    color, text = "rgb(ffffff)", layout[:2]
                subprocess.run(["hyprctl", "notify", "1", "1500", color, text],
                               capture_output=True)
