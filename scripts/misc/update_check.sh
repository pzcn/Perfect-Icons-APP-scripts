  [ "`curl -I -s --connect-timeout 1 https://miuiiconseng-generic.pkg.coding.net/iconseng/engtest/test?version=latest -w %{http_code} | tail -n1`" == "200" ] || ( echo "× 未检测到网络连接... "&& rm -rf $TEMP_DIR/* 2>/dev/null && exit 1; )

check() {
curl -skLJo "$TEMP_DIR/$f" "$url/$f?version=latest"
source $TEMP_DIR/$f
new_ver=$theme_version
if [ $new_ver -ne $old_ver ] ;then 
echo "- ${theme_name}有新版本"
else
echo "- ${theme_name}已是最新"
fi
}


echo 
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
exit 0
fi
if [[ modules_installed=1 ]]; then
url=https://miuiicons-generic.pkg.coding.net/icons/files/
echo "- 检查MIUI完美图标补全模块更新情况："
if [ -z $themeid ]; then
echo "- 检测到您安装了旧版本，无法获取已安装版本号。完成首次更新后即可正常检查更新。"
fi
var_theme=iconsrepo
url=https://miuiicons-generic.pkg.coding.net/icons/files/
old_ver=$version
$f=iconsrepo.ini
check
$f=${themeid}.ini
eval old_ver='$'$var_theme
check
echo 
echo "------------------------"
echo 
fi

#MIUI主图标包资源
cd theme_files
flist=$(ls | grep \.ini$)
if [ ! -z $flist ]; then
echo "- 检查MIUI图标缓存资源更新情况："
url=https://emuiicons-generic.pkg.coding.net/files/zip/
for f in $flist
do
source $f
old_ver=$theme_version
check
done
cd..
echo 
echo "------------------------"
echo 
fi


#EMUI资源

cd theme_files/hwt
flist=$(ls | grep \.ini$)
if [ ! -z $flist ]; then
echo "- 检查EMUI/鸿蒙OS图标缓存资源更新情况："
url=https://emuiicons-generic.pkg.coding.net/files/zip/
for f in $flist
do
source $f
old_ver=$theme_version
check
done
cd..
echo 
echo "------------------------"
echo 
fi