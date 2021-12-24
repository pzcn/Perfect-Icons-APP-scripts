remote_url="https://miuiicons-generic.pkg.coding.net/icons/files/script23.tar?version=latest"
remote_config="https://miuiicons-generic.pkg.coding.net/icons/files/script23.ini?version=latest"
 [ "`curl -I -s --connect-timeout 1 http://connect.rom.miui.com/generate_204 -w %{http_code} | tail -n1`" == "204" ] || {  echo "× 未检测到网络连接，取消安装 ... "&& rm -rf $TEMP_DIR/* >/dev/null && exit 1; }
extract_dir="$START_DIR/online-scripts"
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
[ ! -f $extract_dir/script/tookit/git ] && echo 下载git... && curl -skLJo $extract_dir/script/tookit/git https://miuiicons-generic.pkg.coding.net/icons/files/git?version=latest && chmod 777 $extract_dir/script/tookit/git 
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

curl -skLJo "theme_files/announce.txt" "https://miuiicons-generic.pkg.coding.net/icons/files/announcebeta.txt?version=latest"