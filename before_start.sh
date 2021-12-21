text="若本APP未显示新图标，则需要对EMUI/鸿蒙或MIUI完美图标进行更新。上线EMUI/鸿蒙OS主题导出功能，如有问题请及时反馈。"
extract_dir="$START_DIR/online-scripts"
remote_url="https://miuiicons-generic.pkg.coding.net/icons/files/script2.tar?version=latest"
remote_config="https://miuiicons-generic.pkg.coding.net/icons/files/script2.ini?version=latest"
addon_path=/sdcard/Documents/MIUI完美图标自定义
[ -d "theme_files" ] || mkdir theme_files
[ -f "theme_files/theme_config" ] || ( touch theme_files/theme_config && echo "sel_theme=default" > theme_files/theme_config )
[ -f "theme_files/addon_config" ] || ( touch theme_files/addon_config && echo "addon=0" > theme_files/addon_config )
[ -f "theme_files/mtzdir_config" ] || ( touch theme_files/mtzdir_config && echo "mtzdir=/sdcard/Download" > theme_files/mtzdir_config )
[ -f "theme_files/hwt_theme_config" ] || ( touch theme_files/hwt_theme_config && echo "sel_theme=Aquamarine" > theme_files/hwt_theme_config )
[ -f "theme_files/hwt_size_config" ] || ( touch theme_files/hwt_size_config && echo "hwt_size=M" > theme_files/hwt_size_config )
[ -f "theme_files/hwt_shape_config" ] || ( touch theme_files/hwt_shape_config && echo "hwt_shape=Rectangle" > theme_files/hwt_shape_config )
[ -f "theme_files/update_status.ini" ] && ( rm -rf theme_files/update_status.ini )
[ -f "theme_files/download_config" ] || ( touch theme_files/download_config && echo "curlmode=0" > theme_files/download_config )

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

echo $text > $extract_dir/misc/announce.txt