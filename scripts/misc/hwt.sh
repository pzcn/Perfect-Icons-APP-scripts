
install() {
    echo "- 正在导出主题包..."
    mkdir -p $TEMP_DIR/
    mkdir -p $TEMP_DIR/hwt
    mkdir -p $TEMP_DIR/icons
    mkdir -p $TEMP_DIR/style
    tar -xf "$TEMP_DIR/icons.tar.xz" -C "$TEMP_DIR/" >&2
    tar -xf  $TEMP_DIR/$hwt_theme.tar.xz -C "$TEMP_DIR/hwt/"
    mv $TEMP_DIR/hwt/$sel_theme/icons $TEMP_DIR/hwt/$sel_theme/icons.zip
    unzip $TEMP_DIR/hwt/$sel_theme/icons.zip -d $TEMP_DIR/icons
    rm -rf $TEMP_DIR/hwt/$sel_theme/icons.zip
    echo "- 正在设置形状和大小..."
    tar -xf "$TEMP_DIR/style.tar.xz" -C "$TEMP_DIR/style" >&2
    cp -rf ${TEMP_DIR}/style/${hwt_shape}_${hwt_size}/* $TEMP_DIR/icons
    source ${TEMP_DIR}/style/${hwt_shape}_${hwt_size}/config.ini
    cp -rf $TEMP_DIR/icons
    cd $TEMP_DIR/icons
    zip -r -q $TEMP_DIR/icons.zip * >&2
    cd $TEMP_DIR
    mv $TEMP_DIR/icons.zip $TEMP_DIR/hwt/$sel_theme/icons
    date1=$(TZ=':Asia/Shanghai' date '+%m.%d %H:%M')
    sed -i "s/{name}/$name/g" $TEMP_DIR/hwt/$sel_theme/description.xml
    sed -i "s/{id}/$id/g" $TEMP_DIR/hwt/$sel_theme/description.xml
    sed -i "s/{date}/$date1/g" $TEMP_DIR/hwt/$sel_theme/description.xml
    date2=$(TZ=':Asia/Shanghai' date '+%m%d%H%M')
    cd $TEMP_DIR/hwt/$sel_theme
    zip -q -r $TEMP_DIR/hwt.zip * 
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
    URL=https://emuiicons-generic.pkg.coding.net/files/zip/${hwt_theme}.tar.xz?version=latest
    echo "- 需要下载$theme_name资源... "
    [ $file_size ] || { echo "× 抱歉，在线资源临时维护中，请切换其他主题或稍后再试。" && rm -rf $TEMP_DIR/* 2>/dev/null&& exit 1; }
    echo "- 本次需下载 $(printf '%.1f' `echo "scale=1;$file_size/1048576"|bc`) MB"
    echo "- 正在下载... "
    curl -skLJo "$file" "$URL"
    #进度条待添加
    echo "- $theme_name资源下载完成 "
    md5_loacl=`md5sum $file|cut -d ' ' -f1`
    if [[ "$md5" != "$md5_loacl" ]]; then
        echo '下载完成，但文件MD5与预期的不一致' 1>&2
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