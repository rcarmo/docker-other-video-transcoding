#!/bin/bash

shopt -s nullglob

if [ -z "${EXTENSION}" ]; then 
   EXTENSION=mkv
fi

if [ -z "${AUDIO_CODEC}" ]; then 
   AUDIO_CODEC=AAC
fi

if [ -z "${VIDEO_CODEC}" ]; then 
   VIDEO_CODEC=H.265
fi

export WORKDIR="$PWD"

encode_file () {
    export TARGET="${FILE%.$EXTENSION}"
    export MARKER="${FILE%.$EXTENSION}.lock"
    export LOGFILE="$WORKDIR/${FILE%.$EXTENSION}.log"
    export METADATA="${FILE%.$EXTENSION}.nfo"
    if [ "$PAUSES" != "false" ]; then 
       # Pause before check
       sleep 5
       sleep $((RANDOM % 11))
    fi
    if [ ! -f "$MARKER" ]; then
        echo "====> Processing $FILE" >> "$LOGFILE"
        echo "$HOSTNAME" > "$MARKER"
        if [ ! -z "$SCRATCH_FOLDER" ]; then
            echo "====> Copying $FILE to $SCRATCH_FOLDER" >> "$LOGFILE"
            cp "$FILE" "$SCRATCH_FOLDER/$FILE"
            cd "$SCRATCH_FOLDER"
        fi
        echo "====> Currently in $PWD" >> "$LOGFILE"
        echo "====> Transcoding $FILE -> $TARGET" >> "$LOGFILE" 
        if [ "$AUDIO_CODEC" != "EAC3" ]; then
            stdbuf -oL -eL other-transcode --mp4 --hevc --mp4 "$FILE" --name "$TARGET" 2>> "$LOGFILE"
        else
            stdbuf -oL -eL other-transcode --mp4 --hevc --eac3 --mp4 "$FILE" --name "$TARGET" 2>> "$LOGFILE"
        fi
        if [ $? -eq 0 ]; then
            if [ ! -z "$SCRATCH_FOLDER" ]; then
                echo "====> Removing original file in $SCRATCH_FOLDER" >> "$LOGFILE"
                rm -f "$SCRATCH_FOLDER/$FILE"
                echo "====> Moving new file $TARGET to $WORKDIR" >> "$LOGFILE"
                mv "$SCRATCH_FOLDER/$TARGET" "$WORKDIR/$TARGET"
            fi
            echo "====> Transcoding successful, removing $FILE" >> "$LOGFILE"
            rm -f "$WORKDIR/$FILE"
            echo "====> Removing $TARGET.log as well" >> "$LOGFILE"
            rm -f "$WORKDIR/$TARGET.log"
        fi
        cd "$WORKDIR"
        echo "====> Removing lock and old metadata inside $PWD" >> "$LOGFILE"
        rm -f "$MARKER"
        rm -f "$METADATA" # remove old Plex metadata
        echo "====> Done encoding $FILE" >> "$LOGFILE"
    fi
}

if [ "$RANDOM_PICK" = true ]; then
    ls *.$EXTENSION | shuf | while read FILE; do 
        encode_file
    done
else
    for FILE in *.$EXTENSION; do
        encode_file
    done
fi
