function downloader() {
    local downloadUrl="$1"
    local md5="$2"
    downloader_result="" # 清空变量，后续此变量将用于存放文件下载后的存储路径

    # 检查是否下载过相同MD5的文件，并且文件文件还存在
    # 如果存在相同md5的文件，直接输出其路径，并跳过下载
    # downloader/path 目录存储的是此前下载过的文件路径，以md5作为区分
    local hisotry="$START_DIR/downloader/path/$md5"
    if [[ -f "$hisotry" ]]; then
        local abs_path=`cat "$hisotry"`
        if [[ -f "$abs_path" ]]; then
            # 此前下载的文件还在，检查md5是否一致
            local local_file=`md5sum "$abs_path"`
            if [[ "$local_file" = "$md5" ]]; then
                downloader_result="$abs_path"
                return
            fi
        fi
    fi

    local task_id=`cat /proc/sys/kernel/random/uuid`
    # intent参数
    # --es downloadUrl 【url】下载路径
    # --ez autoClose autoClose 【true/false】 是否下载完成后自动关闭界面
    # --es taskId 【taskId】下载任务的唯一标识 用于跟踪进度

    activity="$PACKAGE_NAME/com.projectkr.shell.ActionPageOnline"
    am start -a android.intent.action.MAIN -n "$activity" --es downloadUrl "$downloadUrl" --ez autoClose true --es taskId "$task_id" 1 > /dev/null

    # 等待下载完成
    # downloader/status 存储的是所有下载任务的进度
    # 0~100 为下载进度百分比，-1表示创建下载任务失败
    local task_path="$START_DIR/downloader/status/$task_id"
    local result_path="$START_DIR/downloader/result/$task_id"
    while [[ '1' = '1' ]]
    do
        if [[ -f "$task_path" ]]; then
            local status=`cat "$task_path"`
            if [[ "$status" = 100 ]] || [[ -f "$result_path" ]]; then
                echo "progress:[$status/100]"
                break
            elif [[ "$status" -gt 0 ]]; then
                echo "progress:[$status/100]"
                # echo '已下载：'$status
            elif [[ "$status" = '-1' ]]; then
                echo '文件下载失败' 1>&2
                # 退出
                return 10
            fi
        fi
        sleep 1
    done

    # 再次检查md5，以便校验下载后的文件md5是否一致
    if [[ "$md5" != "" ]]; then
        local hisotry="$START_DIR/downloader/path/$md5"
        if [[ -f "$hisotry" ]]; then
            downloader_result=`cat "$hisotry"`
        else
            echo '下载完成，但文件MD5与预期的不一致' 1>&2
        fi
    else
        downloader_result=`cat $START_DIR/downloader/result/$task_id`
    fi
}
install() {
    echo "- 正在导出$theme_name..."
    tar -xf "$TEMP_DIR/icons.tar.xz" -C "$TEMP_DIR/" >&2
    mv $TEMP_DIR/icons $TEMP_DIR/icons.zip
    cd $TEMP_DIR
    tar -xf  $TEMP_DIR/$var_theme.tar.xz -C "$TEMP_DIR/"
    mkdir -p ./res/drawable-xxhdpi
    mv  icons/* ./res/drawable-xxhdpi 2>/dev/null
    rm -rf icons
    zip -r icons.zip ./layer_animating_icons >/dev/null
    zip -r icons.zip ./res >/dev/null
    rm -rf res
    rm -rf layer_animating_icons
    cd ..
    [ $addon == 1 ] && addon
    mkdir $TEMP_DIR/mtztmp
    tar -xf "$TEMP_DIR/mtz.tar.xz" -C "$TEMP_DIR/mtztmp" >&2
    cp -rf $TEMP_DIR/icons.zip $TEMP_DIR/mtztmp/icons
    sed -i "s/themename/$theme_name/g" $TEMP_DIR/mtztmp/description.xml
    cd $TEMP_DIR/mtztmp
    time=$(date '+%Y%m%d%H%M')
    zip -r mtz.zip * >/dev/null
    mv mtz.zip $mtzdir/${theme_name}完美图标补全-$time.mtz
    rm -rf $TEMP_DIR/*
    echo "- mtz主题包已导出到 $mtzdir/${theme_name}完美图标补全-$time.mtz。"
    echo "- 需要设计师账号或主题破解才能导入并使用。"
    exit 0
    }

getfiles() {
file=$TEMP_DIR/$var_theme.tar.xz
if [ -f "theme_files/${var_theme}.tar.xz" ]; then
source theme_files/${var_theme}.ini
old_ver=$theme_version
curl -skLJo "$TEMP_DIR/${var_theme}.ini" "https://miuiicons-generic.pkg.coding.net/icons/files/${var_theme}.ini?version=latest"
source $TEMP_DIR/${var_theme}.ini
new_ver=$theme_version
if [ $new_ver -ne $old_ver ] ;then 
echo "- ${theme_name}有新版本，即将开始下载..."
downloader
else
echo "- ${theme_name}没有更新，无需下载..."
cp -rf theme_files/${var_theme}.ini $TEMP_DIR/${var_theme}.ini
cp -rf theme_files/${var_theme}.tar.xz $TEMP_DIR/${var_theme}.tar.xz
fi
else downloader
fi
}

downloader() {
curl -skLJo "$TEMP_DIR/${var_theme}.ini" "https://miuiicons-generic.pkg.coding.net/icons/files/${var_theme}.ini?version=latest"
    mkdir theme_files 2>/dev/null
    source $TEMP_DIR/${var_theme}.ini
    cp -rf $TEMP_DIR/${var_theme}.ini theme_files/${var_theme}.ini
    downloadUrl=https://miuiicons-generic.pkg.coding.net/icons/files/${var_theme}.tar.xz?version=latest
    echo "- 需要下载$theme_name资源... "
    [ $file_size ] || { echo "× 抱歉，在线资源临时维护中，请切换其他主题或稍后再试。" && rm -rf $TEMP_DIR/* 2>/dev/null&& exit 1; }
    echo "- 本次需下载 $(printf '%.1f' `echo "scale=1;$file_size/1048576"|bc`) MB"
    curl -skLJo "$file" "$URL"
    #进度条待添加
    downloader2 "$downloadUrl" $md5

    if [[ ! "$downloader_result" = "" ]]; then
    echo '- 下载完成'
    else
    echo '× 下载失败'
    fi
    cp $file theme_files/${var_theme}.tar.xz
}


addon(){
    addon_path=/sdcard/Documents/MIUI完美图标自定义
    if [ -d "$addon_path" ];then
    echo "- 检测到自定义图标，正在导入..."
    mkdir -p $TEMP_DIR/res/drawable-xxhdpi/
    mkdir -p $TEMP_DIR/layer_animating_icons
    cp -rf $addon_path/动态图标/* $TEMP_DIR/layer_animating_icons/ >/dev/null
    cp -rf $addon_path/静态图标/* $TEMP_DIR/res/drawable-xxhdpi/ >/dev/null
    cd $TEMP_DIR
    zip -r icons.zip res >/dev/null
    zip -r icons.zip layer_animating_icons >/dev/null
    cd ..
    fi
}
  exec 3>&2
  exec 2>/dev/null
  [ "`curl -I -s --connect-timeout 1 https://miuiiconseng-generic.pkg.coding.net/iconseng/engtest/test?version=latest -w %{http_code} | tail -n1`" == "200" ] ||{  echo "× 未检测到网络连接，取消安装 ... "&& rm -rf $TEMP_DIR/* >/dev/null && exit 1; }
  source theme_files/theme_config
  source theme_files/mtzdir_config
  source theme_files/addon_config
  var_theme=icons
  getfiles
  var_theme=mtz
  getfiles
  var_theme=$sel_theme
  getfiles
  install
  rm -rf $TEMP_DIR/*
  echo "---------------------------------------------"
  exit 0