#!/bin/sh

PID=$EARLYOOM_PID
UID=$EARLYOOM_UID
NAME=$EARLYOOM_NAME
RESULT_PATH=/tmp

TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

if echo "$NAME" | grep -iq "java"; then
    echo "Executing jmap for Java process PID: $PID, UID: $UID, NAME: $NAME"
    FILENAME="jmap_histo_${TIMESTAMP}.txt"
    jmap -histo "$PID" > "$RESULT_PATH/$FILENAME"
    echo "jmap output saved to $RESULT_PATH/$FILENAME"
elif echo "$NAME" | grep -iq "starrocks_be"; then
    echo "Executing memz dump for starrocks_be process PID: $PID, UID: $UID, NAME: $NAME"
    FILENAME="memz_${TIMESTAMP}.html"
    curl --max-time 10 http://localhost:8040/memz > "$RESULT_PATH/$FILENAME"
    echo "memz output saved to $RESULT_PATH/$FILENAME"
    TRACKER_FILENAME="mem_tracker_${TIMESTAMP}.html"
    curl --max-time 10 "http://localhost:8040/mem_tracker?upper_level=5" > "$RESULT_PATH/$TRACKER_FILENAME"
    echo "mem_tracker output saved to $RESULT_PATH/$TRACKER_FILENAME"
else
    echo "No Java or starrocks_be process found for PID: $PID"
fi
