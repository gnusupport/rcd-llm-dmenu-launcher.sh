#!/bin/bash

# This script sets up an audio recording process that starts by
# creating or ensuring the existence of specific directories for
# storing audio files and temporary folders. It then generates a
# filename based on the current date and time, which will be used to
# save your recorded file in MP3 format. When you run it, it opens an
# xterm window where actual sound recording begins using your default
# microphone; this process can be stopped by pressing Ctrl-C within
# that window. Once the recording is complete or interrupted, a
# temporary directory with a symlink pointing back to the saved audio
# file gets created for easy access and management of files. Overall,
# this script helps you easily record an MP3 audio note while keeping
# organized directories and symlinks for quick reference later on.

# Define directories
AUDIO_DIR="/home/data1/protected/tmp/audio-notes"
TEMP_DIRS_DIR="/home/data1/protected/temp-dirs"

# Ensure directories exist
mkdir -p "$AUDIO_DIR"
mkdir -p "$TEMP_DIRS_DIR"

# Get current date and time
CURRENT_DATE=$(date +%Y-%m-%d)
CURRENT_TIME=$(date +%H-%M-%S)

# Define filename
FILENAME="audio-note-$CURRENT_DATE-$CURRENT_TIME.mp3"

# Function to start recording
start_recording() {
    # Start xterm with the recording command and get its PID
    xterm_pid=$(xterm -e "bash -c 'arecord -f cd -t wav -D hw:0,0 | lame - \"$AUDIO_DIR/$FILENAME\";'" & echo $!)

    echo "Recording started with PID $xterm_pid. Press Ctrl-C in the xterm window to stop recording."

    # Wait for the xterm process to finish
    wait $xterm_pid

    # Check if the recording was stopped by user
    if [ $? -eq 0 ]; then
        echo "Recording stopped by user."
    else
        echo "Recording process ended unexpectedly."
    fi
}

# Function to create temporary directory and symlink
create_temp_dir_and_symlink() {
    # Create a temporary directory named after the file (without extension)
    TEMP_DIR="$TEMP_DIRS_DIR/$(basename "$FILENAME" .mp3)"
    
    # Create the temporary directory
    mkdir -p "$TEMP_DIR"
    
    # Create a symlink in the temporary directory pointing to the audio file
    ln -s "$AUDIO_DIR/$FILENAME" "$TEMP_DIR/$FILENAME"
    
    # Open the temporary directory with rox
    rox "$TEMP_DIR"
    
    echo "Recording complete. File saved as $AUDIO_DIR/$FILENAME and temporary directory created at $TEMP_DIR."
}

# Start recording in xterm
start_recording

# Create temp directory and symlink
create_temp_dir_and_symlink
