[ "`curl -I -s --connect-timeout 1 https://miuiiconseng-generic.pkg.coding.net/iconseng/engtest/test?version=latest -w %{http_code} | tail -n1`" == "200" ] || ( echo "× 未检测到网络连接... "&& rm -rf $TEMP_DIR/* 2>/dev/null && exit 1; )

check() {
curl -skLJo "$TEMP_DIR/$f" "$url/$f?version=latest"
source $TEMP_DIR/$f
new_ver=$theme_version
echo "- 检查${theme_name}"
echo "  旧版本：$old_ver"
echo "  新版本：$new_ver"
if [ $new_ver -ne $old_ver ] ;then 
echo "  ${theme_name}有新版本"
else
echo "  ${theme_name}已是最新"
fi
echo
}


echo "------------------------"
echo
modules_installed=0
#MIUI模块
if [ -d "/data/adb/modules_update/MIUIiconsplus" ]; then
source /data/adb/modules_update/MIUIiconsplus/module.prop
modules_installed=1
elif [ -d "/data/adb/modules/MIUIiconsplus" ]; then
source /data/adb/modules/MIUIiconsplus/module.prop
modules_installed=1
fi

if [[ $modules_installed == 1 ]]; then
url=https://miuiicons-generic.pkg.coding.net/icons/files/
echo "- 检查MIUI完美图标补全模块更新情况："
echo
if [ -z $themeid ]; then
echo "- 检测到您安装了旧版本，无法获取已安装版本号。完成首次更新后即可正常检查更新。"
fi
url=https://miuiicons-generic.pkg.coding.net/icons/files/
old_ver=$iconsrepo
f=iconsrepo.ini
check
f=${themeid}.ini
eval old_ver='$'$themeid
check
echo "------------------------"
echo 
else
install1=1
fi


#MIUI主图标包资源
cd theme_files
flist=$(ls *.ini) 2>/dev/null
if [ ! -z "$flist" ]; then
echo "- 检查MIUI图标缓存资源更新情况："
echo
url=https://miuiicons-generic.pkg.coding.net/icons/files/
for f in $flist
do
source ./$f
old_ver=$theme_version
check
done
echo "------------------------"
echo 
else
install2=1
fi

#EMUI资源
if [ -d hwt ] && cd hwt && flist=$(ls | grep \.ini$) && [ ! -z "$flist" ]; then
echo "- 检查EMUI/鸿蒙OS图标缓存资源更新情况："
echo
url=https://emuiicons-generic.pkg.coding.net/files/zip/
for f in $flist
do
source ./$f
old_ver=$theme_version
check
done
echo "------------------------"
echo 
else
install3=1
fi

if [ $(expr $install1 + $install2 + $install3) = 3 ];then
echo "- 未发现已安装/已缓存的文件"
echo
echo "------------------------"
 
fi

rm -rf $TEMP_DIR/*