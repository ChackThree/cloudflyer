#!/bin/bash
echo "==========Starting the service=========="
# Cleanup function to perform cleanup operations on script exit
cleanup() {
    echo "Performing cleanup..."
    if [ -n "$XVFB_PID" ] && ps -p "$XVFB_PID" > /dev/null 2>&1; then
        echo "Terminating Xvfb process (PID: $XVFB_PID)..."
        kill -15 "$XVFB_PID" 2>/dev/null || kill -9 "$XVFB_PID" 2>/dev/null
    fi
    echo "Cleanup completed"
}
# Set exit trap
trap cleanup EXIT INT TERM
# Function: Find available DISPLAY
find_free_display() {
    local display_num=1
    while true; do
        local lock_file="/tmp/.X${display_num}-lock"
        local socket_file="/tmp/.X11-unix/X${display_num}"
        if [ ! -e "$lock_file" ] && [ ! -e "$socket_file" ]; then
            echo ":${display_num}"
            return
        fi
        display_num=$((display_num + 1))
    done
}
# Automatically get available DISPLAY
DISPLAY=$(find_free_display)
echo "Using DISPLAY=${DISPLAY}"
# Define lock file path
LOCK_FILE="/tmp/.X${DISPLAY#:}-lock"
echo "Checking existing Xvfb processes and lock files..."
# Check and clean up possible leftover lock files and processes
if [ -f "$LOCK_FILE" ]; then
    PID=$(cat "$LOCK_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "Found running Xvfb process (PID: $PID), terminating..."
        kill -15 "$PID"
        sleep 1
        if ps -p "$PID" > /dev/null 2>&1; then
            echo "Process did not terminate, force killing..."
            kill -9 "$PID"
        fi
    fi
    echo "Removing lock file $LOCK_FILE..."
    rm -f "$LOCK_FILE"
fi
echo "Starting Xvfb..."
Xvfb "${DISPLAY}" -screen 0 1024x768x24 2>&1 | tee xvfb.log &
XVFB_PID=$!
# Wait for Xvfb to start and check if it succeeded
echo "Waiting for Xvfb to start..."
for i in {1..10}; do
    if [ -e "$LOCK_FILE" ] && ps -p "$XVFB_PID" > /dev/null 2>&1; then
        echo "Xvfb started successfully, PID: $XVFB_PID"
        break
    fi
    if [ $i -eq 10 ]; then
        echo "Xvfb failed to start, please check xvfb.log"
        exit 1
    fi
    echo "Waiting... ($i/10)"
    sleep 1
done
export DISPLAY=$DISPLAY
echo "Set DISPLAY=${DISPLAY}"
echo "Current DISPLAY:$DISPLAY"
# Whether to use environment variables for startup
START_BY_ENV=${START_BY_ENV:-false}
if [ "$START_BY_ENV" = "true" ]; then
    # Get values from environment variables
    CLIENT_KEY=${CLIENT_KEY:-"123456"}
    MAX_TASKS=${MAX_TASKS:-1}
    PORT=${PORT:-3000}
    HOST=${HOST:-"0.0.0.0"}
    TIMEOUT=${TIMEOUT:-120}
    # Print environment variable values
    echo "CLIENT_KEY: $CLIENT_KEY"
    echo "MAX_TASKS: $MAX_TASKS"
    echo "PORT: $PORT"
    echo "HOST: $HOST"
    echo "TIMEOUT: $TIMEOUT"
    # Start the service
    echo "Starting the service (using environment variables)..."
    echo "/app/venv/bin/python -m cloudflyer -K $CLIENT_KEY -M $MAX_TASKS -P $PORT -H $HOST -T $TIMEOUT"
    /app/venv/bin/python -m cloudflyer -K $CLIENT_KEY -M $MAX_TASKS -P $PORT -H $HOST -T $TIMEOUT
else
    # Start the service (using command line arguments)
    echo "Starting the service (using command line arguments)..."
    /app/venv/bin/python -m cloudflyer $@
fi
echo "==========Service started successfully=========="