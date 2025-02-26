  #!/bin/bash

# When you start ComfyUI using this script, it first sets up the
# necessary environment and checks if a specific command ("kill") is
# given. If so, it looks for any running instances of the application
# and stops them accordingly. Otherwise, it navigates to where
# ComfyUI's files are stored on your computer system. The script then
# ensures that only one instance runs at a time; if another is already
# active, you'll be notified via speech synthesis ("espeak"). If
# everything checks out fine, it starts up the application in the
# background and opens its interface automatically within your web
# browser using an IP address obtained from connected network
# interfaces. This way, ComfyUI becomes accessible through that link
# for further interaction right away after startup.

source /home/data1/protected/venv/bin/activate
DIR="/home/data1/protected/Programming/git/ComfyUI"

# Check if 'kill' argument is passed
if [ "$1" == "kill" ]; then
    # Get the process ID of the running script
    PID=$(pgrep -f "python main.py --listen")
    if [ -z "$PID" ]; then
        espeak "No running script found to kill"
        exit 0
    fi

    # Kill the process
    kill "$PID" && espeak "Script terminated successfully" || espeak "Failed to terminate script"
    exit 0
fi

cd "$DIR" || { espeak "Failed to change directory to $DIR"; exit 1; }

# Check if the process is already running
if pgrep -f "python main.py --listen" > /dev/null; then
    espeak "Script is already running"
    exit 1
fi

nohup python main.py --listen "$(get_ethernet_interface.sh)" > $TMPDIR/nohup.out 2>&1 &

if [ $? -ne 0 ]; then
    espeak "Failed to run main.py with nohup"
    exit 1
fi

IP=$(get_ethernet_interface.sh | awk '{print $1}')

if [ -z "$IP" ]; then
    espeak "Failed to get IP address"
    exit 1
fi

sleep 2
xdg-open "http://$IP:8188/" || espeak "Failed to open web browser"
