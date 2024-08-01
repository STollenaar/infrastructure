if [ -f /config/config.xml ]; then
    echo "/config/config.xml already exists."
else
    echo "/config/config.xml does not exist. Copying /tmp/config.xml to /config."
    cp /tmp/config.xml /config/config.xml

    # Verify if the copy was successful
    if [ -f /config/config.xml ]; then
        echo "Copy successful!"
    else
        echo "Copy failed!"
        exit 1
    fi
fi
