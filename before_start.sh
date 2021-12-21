
remote_url="https://miuiicons-generic.pkg.coding.net/icons/files/script23.tar?version=latest"
remote_config="https://miuiicons-generic.pkg.coding.net/icons/files/script23.ini?version=latest"

download_latest_version() {
    echo "开始在线更新..."
    mkdir -p $extract_dir
    curl -skLJo "$extract_dir/script.tar" $remote_url
    curl -skLJo "$extract_dir/script.ini" $remote_config
    tar -xf "$extract_dir/script.tar" -C "$extract_dir"
    rm -rf $extract_dir/script.tar
    chmod 755 -R "$extract_dir"
    find "$extract_dir" -name "*.sh" | xargs dos2unix 1>/dev/null
    echo '在线更新完成...'
}
exec 3>&2
exec 2>/dev/null
echo "检查在线配置..."
if [ -f "$extract_dir/script.ini" ]; then
source $extract_dir/script.ini
old_ver=$script_version
curl -skLJo "$extract_dir/script.ini" $remote_config
source $extract_dir/script.ini
new_ver=$script_version

if [ $new_ver -ne $old_ver ] ;then
echo '检查到新版本...'
rm -rf $extract_dir
download_latest_version
else
echo "配置文件已是最新..."
fi
else   
download_latest_version
fi