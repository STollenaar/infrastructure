echo "Checking if db already exists"

if [[ ! -d "$DB_PATH" ]]; then
    mkdir -p "$DB_PATH"
    ls -la "$DB_PATH"
fi

if [[ ! -f "$DB_PATH/$DB_NAME" ]]; then
    sqlite3 "$DB_PATH/$DB_NAME" </tmp/restore.sql
    ls -la "$DB_PATH"
fi

if [[ "$SETTINGS_PATH" != "" && ! -f "$SETTINGS_PATH/$SETTINGS_FILE" ]]; then
    cp "/tmp/$SETTINGS_FILE" "$SETTINGS_PATH/$SETTINGS_FILE"
fi

if [[ "$LIBRARY_PATH" != "" && ! -f "$LIBRARY_PATH/$LIBRARY_NAME" ]]; then
    sqlite3 "$LIBRARY_PATH/$LIBRARY_NAME" </tmp/library.sql
fi

ls -la "$DB_PATH"
echo "Done restoring"
