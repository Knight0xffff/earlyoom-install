#!/bin/bash
#
# earlyoom pre-kill hook (-N): dump the victim's memory state before it is signalled.
#
# Must be bash, and the victim vars must not be named UID: on AL2023 /bin/sh is bash,
# which then runs in POSIX mode where assigning to the readonly UID is fatal. The old
# `UID=$EARLYOOM_UID` aborted this script on line 4 and silently produced no dump.

VICTIM_PID=$EARLYOOM_PID
VICTIM_UID=$EARLYOOM_UID
VICTIM_NAME=$EARLYOOM_NAME
RESULT_PATH=/tmp

TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

if echo "$VICTIM_NAME" | grep -iq "java"; then
    echo "Executing jmap for Java process PID: $VICTIM_PID, UID: $VICTIM_UID, NAME: $VICTIM_NAME"
    FILENAME="jmap_histo_${TIMESTAMP}.txt"
    jmap -histo "$VICTIM_PID" > "$RESULT_PATH/$FILENAME"
    echo "jmap output saved to $RESULT_PATH/$FILENAME"
elif echo "$VICTIM_NAME" | grep -iq "starrocks_be"; then
    echo "Executing memz dump for starrocks_be process PID: $VICTIM_PID, UID: $VICTIM_UID, NAME: $VICTIM_NAME"
    FILENAME="memz_${TIMESTAMP}.html"
    curl --max-time 10 http://localhost:8040/memz > "$RESULT_PATH/$FILENAME"
    echo "memz output saved to $RESULT_PATH/$FILENAME"
    TRACKER_FILENAME="mem_tracker_${TIMESTAMP}.html"
    curl --max-time 10 "http://localhost:8040/mem_tracker?upper_level=5" > "$RESULT_PATH/$TRACKER_FILENAME"
    echo "mem_tracker output saved to $RESULT_PATH/$TRACKER_FILENAME"
else
    echo "No Java or starrocks_be process found for PID: $VICTIM_PID"
fi
