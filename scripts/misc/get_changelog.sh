#!/system/bin/sh
curl -skLJo "$TEMP_DIR/changelog.xml" https://miuiicons-generic.pkg.coding.net/icons/files/changelog.xml?version=latest
cp -rf "$START_DIR/online-scripts/pic/push.png" "$TEMP_DIR/push.png"
echo "$TEMP_DIR/changelog.xml"