#!/bin/bash

# Show een klein help menu
if [ -z "$1" ]; then
    echo "Arguments: <tar-file> <script>"
    echo "Example:"
    echo "  $ ./download.tgz ./template/python.sh"
    exit;
fi

# Cleanup previous trash
rm -rf ./sortme

ROOT=$(pwd)
FILE_TO_EXTRACT=$1
SCRIPT=$2

echo -e "\e[0m\e[2mLoading File: \e[0m$FILE_TO_EXTRACT\e[0m"
echo -e "\e[0m\e[2mScript: \e[0m$SCRIPT\e[0m"

# Make sure the sorting directory exists
mkdir sortme

# Extract and remove original file
tar -xvf "$FILE_TO_EXTRACT" -C ./sortme/ > /dev/null

# Get Bash Ready for **/*.py
shopt -s globstar

cd sortme

# Loop alle dirs
for dir in */
do
    cd "$ROOT/sortme/$dir"
    VAK=$(echo "$dir" | awk -F '_' '{print $3}')
    DUE=$(echo "$dir" | awk -F '_' '{print $5}' | sed 's/\///g' | sed 's/-//g')
    # Loop door alles
    for D in ./*
    do
        # Make sure dat we in de correcte dir zitten
        cd "$ROOT/sortme/$dir"

        # Zet de filenaam voor verder gebruik
        FILE=$(echo "$D" | awk -F '/' '{print $2}')
        
        # Calculate naam van taak
        TAAK=$(echo "$FILE" | awk -F '_' '{print $1}')
       
        # Calculate de Naam
        NAAM2=$(echo "$FILE" | awk -F '_' '{print $2}')
        NAAM1=$(echo "$NAAM2" | sed 's/\./ /g')
        NAAM5=$(echo "$NAAM1" | sed 's/ s ua//g')
        NAAM3=$(echo "$NAAM5" | awk '{ for (i=2; i<=NF; i++) printf("%s ",$i) }' | sed 's/ //g')
        NAAM4=$(echo "$NAAM5" | awk '{ print $1 }')
        NAAM="$NAAM3.$NAAM4"

        # Calculate de Submit Datum
        LATE5=$(echo "$FILE" | awk -F '_' '{print $4}')
        LATE4=$(echo "$LATE5" | sed 's/\.tgz//g')
        LATE3=$(echo "$LATE4" | sed 's/-//g')
        LATE=LATE3

        # Maak de path aan en extract alles naar daar
        PAD="$ROOT/$VAK/$TAAK/$NAAM"
        mkdir -p "$PAD"
        tar -xvf "./$FILE" -C "$PAD/" > /dev/null
        cd "$PAD"

        # Delete ._ bestanden
        find "$PAD" -name '\._*' -delete

        # Pull alle py bestanden
        # Gebruik 2> om hem stil te laten zijn
        # mv **/*.py ./ 2> /dev/null
        find . -name '*.py' -exec mv {} "$PAD" \;

        # Delete lege folders
        # find . -type d -empty -delete

        # Delete alle folders
        find . -type d -exec rm -rf {} + 2> /dev/null

        # Input Handige info
        echo -e "\e[31m------------------------------\e[0m"
        echo -e "\e[0m\e[2mNaam: \e[0m$NAAM5\e[0m"
        if (( LATE < DUE )); then
        echo -e "\e[0m\e[2mSubmission: \e[0m$LATE4 \e[0m\e[33m\e[1m(LATE)\e[0m"
        else
        echo -e "\e[0m\e[2mSubmission: \e[0m$LATE4\e[0m"
        fi
        FILECOUNT=$(ls "$PAD" | wc -l)
        echo -e "\e[0m\e[2mFiles Submitted: \e[0m$FILECOUNT\e[0m"

        if [ $FILECOUNT -eq 0 ]; then
            echo -e "\e[0m\e[31m\e[7m\e[5mNO FILES FOUND"
        fi

        # Maak een late file aan indien nodig
        if (( LATE < DUE )); then
            touch "$ROOT/$VAK/$TAAK/$NAAM/late_inzending"
        fi

        if (( $FILECOUNT == 1 )); then
            FILE=$(ls "$PAD" | grep -v "late_inzending")
        else
            select val in $(ls "$PAD" | grep -v "late_inzending"); do
                case $val in
                * ) FILE=$val; break;;
                esac
            done
        fi

        cd $ROOT
        NPAD="$ROOT/$VAK/$TAAK/Oplossingen"
        mkdir -p "$NPAD"
        # Execute het script
        $SCRIPT "$PAD/$FILE" > "$NPAD/$NAAM _output.txt" 2> "$NPAD/$NAAM _error.txt"
        # Delete alle empty files
        find "$NPAD" -size  0 -print -delete &> /dev/null
    done
done

cd "$ROOT"

rm -rf ./sortme > /dev/null