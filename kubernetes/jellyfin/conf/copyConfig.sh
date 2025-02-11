parents=$(dirname "$DESTINATION")
if [ ! -d "$parents" ]; then
    mkdir -p "$parents"
fi
if [ -f "$DESTINATION" ]; then
    echo "$DESTINATION already exists."
else
    echo "$DESTINATION does not exist. Copying $SOURCE to /config."

    cp "$SOURCE" "$DESTINATION"

    # Verify if the copy was successful
    if [ -f "$DESTINATION" ]; then
        echo "Copy successful!"
    else
        echo "Copy failed!"
        exit 1
    fi
fi
