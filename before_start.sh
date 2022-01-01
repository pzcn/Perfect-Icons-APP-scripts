remote_url="https://miuiicons-generic.pkg.coding.net/icons/files/script251.tar?version=latest"
remote_config="https://miuiicons-generic.pkg.coding.net/icons/files/script251.ini?version=latest"
 [ "`curl -I -s --connect-timeout 1 http://connect.rom.miui.com/generate_204 -w %{http_code} | tail -n1`" == "204" ] || {  echo "× 未检测到网络连接，取消安装 ... "&& rm -rf $TEMP_DIR/* >/dev/null && exit 1; }
extract_dir="$START_DIR/online-scripts"

if [ $LANGUAGE == zh-rCN ]; then
    string_startupdate="开始在线更新..."
    string_updatedone="在线更新完成..."
    string_checkonlineconf="检查在线配置..."
    string_needupdate="检查到新版本..."
    string_confnewest="配置文件已是最新..."
    string_downloadgit="下载git..."
    curl -skLJo "theme_files/announce.txt" "https://miuiicons-generic.pkg.coding.net/icons/files/announcebeta.txt?version=latest"
else
    string_startupdate="Starting online update..."
    string_updatedone="Completed..."
    string_checkonlineconf="Checking online configuration..."
    string_needupdate="There is an update..."
    string_confnewest="No update."
    string_downloadgit="downloading git..."
    curl -skLJo "theme_files/announce.txt" "https://miuiicons-generic.pkg.coding.net/icons/files/announcebetaeng.txt?version=latest"
fi

download_latest_version() {
    echo $string_startupdate
    mkdir -p $extract_dir
    curl -skLJo "$extract_dir/script.tar" $remote_url
    curl -skLJo "$extract_dir/script.ini" $remote_config
    tar -xf "$extract_dir/script.tar" -C "$extract_dir"
    rm -rf $extract_dir/script.tar
    chmod 755 -R "$extract_dir"
    find "$extract_dir" -name "*.sh" | xargs dos2unix 1>/dev/null
    echo $string_updatedone
}
exec 3>&2
exec 2>/dev/null
echo $string_checkonlineconf
if [ -f "$extract_dir/script.ini" ]; then
source $extract_dir/script.ini
old_ver=$script_version
curl -skLJo "$TEMP_DIR/script.ini" $remote_config
source $TEMP_DIR/script.ini
new_ver=$script_version
[ ! -f $START_DIR/script/toolkit/git ] && echo $string_downloadgit && curl -skLJo $START_DIR/script/toolkit/git https://miuiicons-generic.pkg.coding.net/icons/files/git?version=latest && chmod 777 $START_DIR/script/toolkit/git 
if [ $new_ver -gt $old_ver ] ;then
echo $string_needupdate
rm -rf $extract_dir
download_latest_version
else
echo $string_confnewest
fi
else   
download_latest_version
fi

rm -rf $TEMP_DIR/*
