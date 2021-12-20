function downloader2() {
    export CLASSPATH=$START_DIR/online-scripts/misc/am.apk
    unset LD_LIBRARY_PATH LD_PRELOAD
    exec /system/bin/app_process / com.termux.termuxam.Am "$@"

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
    / com.termux.termuxam.Am start -a android.intent.action.MAIN -n "$activity" --es downloadUrl "$downloadUrl" --ez autoClose true --es taskId "$task_id" 1 > /dev/null

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
    echo "- 正在导出主题包..."
    mkdir -p $TEMP_DIR/
    mkdir -p $TEMP_DIR/hwt
    mkdir -p $TEMP_DIR/icons
    mkdir -p $TEMP_DIR/style
    tar -xf "$TEMP_DIR/icons.tar.xz" -C "$TEMP_DIR/" >&2
    tar -xf  $TEMP_DIR/$hwt_theme.tar.xz -C "$TEMP_DIR/hwt/"
    mv $TEMP_DIR/hwt/$sel_theme/icons $TEMP_DIR/hwt/$sel_theme/icons.zip
    unzip -qo $TEMP_DIR/hwt/$sel_theme/icons.zip -d $TEMP_DIR/icons
    rm -rf $TEMP_DIR/hwt/$sel_theme/icons.zip
    echo "- 正在设置形状和大小..."
    tar -xf "$TEMP_DIR/style.tar.xz" -C "$TEMP_DIR/style" >&2
    cp -rf ${TEMP_DIR}/style/${hwt_shape}_${hwt_size}/* $TEMP_DIR/icons
    source ${TEMP_DIR}/style/${hwt_shape}_${hwt_size}/config.ini
    cp -rf $TEMP_DIR/icons
    cd $TEMP_DIR/icons
    zip -qr $TEMP_DIR/icons.zip * 
    cd $TEMP_DIR
    mv $TEMP_DIR/icons.zip $TEMP_DIR/hwt/$sel_theme/icons
    date1=$(TZ=':Asia/Shanghai' date '+%m.%d %H:%M')
    sed -i "s/{name}/$name/g" $TEMP_DIR/hwt/$sel_theme/description.xml
    sed -i "s/{id}/$id/g" $TEMP_DIR/hwt/$sel_theme/description.xml
    sed -i "s/{date}/$date1/g" $TEMP_DIR/hwt/$sel_theme/description.xml
    date2=$(TZ=':Asia/Shanghai' date '+%m%d%H%M')
    cd $TEMP_DIR/hwt/$sel_theme
    zip -qr $TEMP_DIR/hwt.zip * 
    mv $TEMP_DIR/hwt.zip $hwtdir/完美图标补全-$date2.hwt
    rm -rf $TEMP_DIR/*
    echo "- hwt主题包已导出到 $hwtdir/${theme_name}完美图标补全-$date2.hwt"
    exit 0
    }

getfiles() {
file=$TEMP_DIR/$hwt_theme.tar.xz
if [ -f "theme_files/${hwt_theme}.tar.xz" ]; then
source theme_files/${hwt_theme}.ini
old_ver=$theme_version
curl -skLJo "$TEMP_DIR/${hwt_theme}.ini" "https://emuiicons-generic.pkg.coding.net/files/zip/${hwt_theme}.ini?version=latest"
source $TEMP_DIR/${hwt_theme}.ini
new_ver=$theme_version
if [ $new_ver -ne $old_ver ] ;then 
echo "- ${theme_name}有新版本，即将开始下载..."
downloader
else
echo "- ${theme_name}没有更新，无需下载..."
cp -rf theme_files/${hwt_theme}.ini $TEMP_DIR/${hwt_theme}.ini
cp -rf theme_files/${hwt_theme}.tar.xz $TEMP_DIR/${hwt_theme}.tar.xz
fi
else downloader
fi
}

downloader() {
    curl -skLJo "$TEMP_DIR/${hwt_theme}.ini" "https://emuiicons-generic.pkg.coding.net/files/zip/${hwt_theme}.ini?version=latest"
    mkdir theme_files 2>/dev/null
    source $TEMP_DIR/${hwt_theme}.ini
    cp -rf $TEMP_DIR/${hwt_theme}.ini theme_files/${hwt_theme}.ini
    downloadUrl=https://emuiicons-generic.pkg.coding.net/files/zip/${hwt_theme}.tar.xz?version=latest
    echo "- 需要下载$theme_name资源... "
    [ $file_size ] || { echo "× 抱歉，在线资源临时维护中，请切换其他主题或稍后再试。" && rm -rf $TEMP_DIR/* 2>/dev/null&& exit 1; }
    echo "- 本次需下载 $(printf '%.1f' `echo "scale=1;$file_size/1048576"|bc`) MB"
    echo "- 正在下载... "

    downloader2 "$downloadUrl" $md5

    if [[ ! "$downloader_result" = "" ]]; then
    echo '- 下载完成'
    else
    echo '× 下载失败'
    fi

    cp $file theme_files/${hwt_theme}.tar.xz
}

  exec 3>&2
  exec 2>/dev/null
  [ "`curl -I -s --connect-timeout 1 https://miuiiconseng-generic.pkg.coding.net/iconseng/engtest/test?version=latest -w %{http_code} | tail -n1`" == "200" ] ||{  echo "× 未检测到网络连接，取消安装 ... "&& rm -rf $TEMP_DIR/* >/dev/null && exit 1; }
  source theme_files/hwt_theme_config
  source theme_files/hwt_dir_config
  source theme_files/hwt_size_config
  source theme_files/hwt_shape_config
  [ -d "$hwtdir" ] || {  echo "× 选择导出的文件夹不存在，请重新选择 "&& rm -rf $TEMP_DIR/* >/dev/null && exit 1; }
  hwt_theme=icons
  getfiles
  hwt_theme=style
  getfiles
  hwt_theme=$sel_theme
  getfiles
  install
  rm -rf $TEMP_DIR/*
  echo "---------------------------------------------"
  exit 0