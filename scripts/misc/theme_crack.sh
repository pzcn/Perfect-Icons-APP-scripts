#!/sbin/sh
## 余空

#########
# 初始化
#########
umask 022
Start_Time=$(date "+%Y-%m-%d %H:%M:%S")
Print_Time=$(date "+%m.%d %H:%M")

TMPDIR=/dev/tmp
rm -rf $TMPDIR 2>/dev/null
mkdir -p $TMPDIR

Print() {
	echo "$@"
	sleep 0.02
}

CPU_ABI=$(getprop ro.product.cpu.abi)
Android=$(getprop ro.build.version.release)
versionName=$(pm dump com.android.thememanager | grep -m 1 versionName | sed -n 's/.*=//p')

if [ $Android -ge 11 ]; then
    PERSISTDIR=/dev/*/.magisk/mirror/persist
else
    PERSISTDIR=/sbin/.magisk/mirror/persist
fi


## 定义module.prop
id=theme_pojie_apktool
name="主题破解v${versionName} Auto"
version=Apktool
versionCode=210405
author=余空
description="主题/字体xx,任意使用第三方mtz."
Ver=版本：$version，刷入时间：$Print_Time


## 输出module.prop
echo "id=$id
name=$name
version=$Ver
versionCode=$versionCode
author=$author
description=$description" > $TMPDIR/module.prop


## 输出service.sh
echo 'chmod 731 /data/system/theme

tmp_list="ThemeManager"
dda=/data/dalvik-cache/arm
[ -d $dda"64" ] && dda=${dda}64
for i in $tmp_list; do
    rm -f $dda/system@*@${i}*
done
rm -rf /data/system/package_cache/*' > $TMPDIR/service.sh


## 输出uninstall.sh
echo 'tmp_list="ThemeManager"
dda=/data/dalvik-cache/arm
[ -d $dda"64" ] && dda=${dda}64
for i in $tmp_list; do
	rm -f $dda/system@*@{$i}*
done
rm -rf /data/system/package_cache/*
chmod 775 /data/system/theme
rm -rf /data/system/theme/rights
rm -rf /data/app/*/com.android.thememanager*
rm -rf /data/app/com.android.thememanager*' > $TMPDIR/uninstall.sh


## 执行模块安装
on_install() {
  Print "_______________"
  Print "  ※ 模块安装 ※"
  Print "¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯"
  Print "- 正在刷入..."
  Print "- 正在下载并配置Apktool,请稍后..."
  Print "- 正在下载（1/3）..."
curl -skLJo "apktoolaa"  https://shaun-620.coding.net/p/duozw/d/zwgc/git/raw/module/apktoolaa -o $TEMP_DIR/apktoolaa 2>/dev/null 
Print "- 正在下载（2/3）..."
curl -skLJo "$TEMP_DIR/apktoolab"  https://shaun-620.coding.net/p/duozw/d/zwgc/git/raw/module/apktoolaa -o $TEMP_DIR/apktoolaa 2>/dev/null
Print "- 正在下载（3/3）..."
curl -skLJo "$TEMP_DIR/apktoolac"  https://shaun-620.coding.net/p/duozw/d/zwgc/git/raw/module/apktoolaa -o $TEMP_DIR/apktoolaa 2>/dev/null
Print "- 下载完成，开始配置Apktool..."
  cat apktool* > Apktool.tar.xz
  tar -xJf $TEMP_DIR/Apktool.tar.xz -C /data/local >/dev/null
  rm -fr $TEMP_DIR/Apktool.tar.xz
  rm -fr $TEMP_DIR/apktool*
  chmod -R 777 /data/local/Tool-Apk
  hh() {
  sleep 2
  echo "Test kakathic" > /sdcard/jdbfbdk.txt
  if [ -e /sdcard/jdbfbdk.txt ]; then
      if [ -e /data/data/per.pqy.openjdk ]; then
          sleep 0.1
      else
          cp -rf /data/local/Tool-Apk/per.pqy.openjdk /data/data
          chmod -R 777 /data/data/per.pqy.openjdk
      fi
      rm -rf /sdcard/jdbfbdk.txt
  else
      hh
  fi
  }
  hh
  echo 'At='/data/local/Tool-Apk/apktool/dex2jar/d2j_invoke.sh -jar /data/local/Tool-Apk/apktool/apktool-2.4.2.jar -p /data/local/Tool-Apk'
if [ -e /data/local/Tool-Apk/16.apk ];then
sleep 0.1
else
su -c "$At if /system/app/miui/miui.apk
$At if /system/app/miuisystem/miuisystem.apk
$At if /system/framework/framework-res.apk
$At if /system/framework/framework-ext-res/framework-ext-res.apk
$At if /system/priv-app/RtMiCloudSDK/RtMiCloudSDK.apk
$At if /system/priv-app/PersonalAssistant/PersonalAssistant.apk
$At if /system/app/GoogleExtShared/GoogleExtShared.apk 
chmod -R 777 /data/local/Tool-Apk/*.apk"
fi

export LD_PRELOAD=
export LD_LIBRARY_PATH=/data/local/Tool-Apk/apktool/openjdk/lib:$LD_LIBRARY_PATH
umask 000
exec /data/local/Tool-Apk/apktool/dex2jar/d2j_invoke.sh -Djava.io.tmpdir=/data/local/Tool-Apk -jar /data/local/Tool-Apk/apktool/apktool-2.4.2.jar -p /data/local/Tool-Apk "$@"' > /data/local/Tool-Apk/apktool/dex2jar/apktool.sh
  chmod 777 /data/local/Tool-Apk/apktool/dex2jar/apktool.sh
  apktool=/data/local/Tool-Apk/apktool/dex2jar/apktool.sh
  apk=$MODPATH/apktool
  mkdir -p $apk
  LuJing=$(pm path com.android.thememanager | sed 's/package://g')
  Print "- 当前应用安装路径 : $LuJing"
  Print "- 反编译的应用版本 : v$versionName"
  cp -rf $LuJing $apk/base.apk
  mkdir -p $MODPATH/system/app/ThemeManager/
  Print "- 正在处理apk，请稍后..."
  Print "- 这可能需要30秒到3分钟不等的时间,取决于你的设备性能."
  cd $apk
  $apktool d -q -r -f -m $apk/base.apk
  Mod=$(grep -lrw "DRM_ERROR_UNKNOWN" $apk/base/smali/com/android/thememanager/*/*/*.smali)
  Mod1=$(grep -lrw "DRM_ERROR_UNKNOWN" $apk/base/smali_classes2/com/android/thememanager/*/*/*.smali)
  sed -i 's/DRM_ERROR_UNKNOWN/DRM_SUCCESS/g' $Mod
    sed -i 's/DRM_ERROR_UNKNOWN/DRM_SUCCESS/g' $Mod1
  sed -i '/OnlineResourceDetail;->bought:Z/i\const/4 v0, 0x1' $apk/base/smali_classes2/com/android/thememanager/module/detail/presenter/OnlineResourceDetailPresenter.smali
  sed -i '/OnlineResourceDetail;->bought:Z/i\ return v0' $apk/base/smali_classes2/com/android/thememanager/module/detail/presenter/OnlineResourceDetailPresenter.smali
  sed -i '/AdInfo;->targetType:I/i\const/4 v0, 0x0' $apk/base/smali/com/android/thememanager/basemodule/ad/model/AdInfo.smali
  sed -i '/AdInfo;->targetType:I/i\ return v0' $apk/base/smali/com/android/thememanager/basemodule/ad/model/AdInfo.smali
  sed -i '/Parcel;->obtain()Landroid/os/Parcel;/i\ return-void' $apk/base/smali/com/miui/systemAdSolution/splashAd/IAdListener$Stub$Proxy.smali
  sed -i '/"using_theme_show_ad"/i\const/4 v0, 0x0'  $apk/base/smali_classes2/com/android/thememanager/util/gb.smali
  sed -i '/"using_theme_show_ad"/i\ return v0'  $apk/base/smali_classes2/com/android/thememanager/util/gb.smali
  cd $apk
  $apktool b -q -f -c $apk/base -o base.apk
  cp -rf $apk/base.apk $MODPATH/system/app/ThemeManager/ThemeManager.apk
  Print "- 处理apk完成."
  case "$CPU_ABI" in
      arm64*) Type=arm64 Wenj=arm64-v8a;;
      arm*) Type=arm Wenj=armeabi-v7a;;
      x86_64*) Type=x86_64 Wenj=x86_64;;
      x86*) Type=x86 Wenj=x86;;
  esac
  Print "- 正在执行适用于${Type}架构的对应操作."
  mkdir -p $MODPATH/system/app/ThemeManager/lib/$Type
  mkdir -p $MODPATH/ThemeManager
  unzip -o $MODPATH/system/app/ThemeManager/ThemeManager.apk -d $MODPATH/ThemeManager >&2
  cp -rf $MODPATH/ThemeManager/lib/$Wenj/* $MODPATH/system/app/ThemeManager/lib/$Type
  rm -rf $MODPATH/ThemeManager
  rm -rf $apk
  case ${LuJing} in
      /data*) rm -rf $LuJing;;
      *);;
  esac
  tmp_list="ThemeManager"
  dda=/data/dalvik-cache/arm
  [[ -d $dda"64" ]] && dda=${dda}64
  for i in $tmp_list; do
      rm -f $dda/system@*@${i}*
  done
  rm -rf /data/system/package_cache/*
  Print "- 正在清理Apktool."
  rm -rf /data/local/Tool-Apk
  rm -rf /data/data/per.pqy.openjdk
  set_perm_recursive $MODPATH 0 0 0755 0644
  Print "_______________"
  Print "  ※ 注意事项 ※"
  Print "¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯"
  Print "- 由于为自动编译版本，难免可能存在不可预知的问题，"
  Print "- 如果刷入后主题壁纸APP存在问题请卸载模块."
}


## 不支持刷入
require_new_magisk() {
  Print
  Print "- 当前模块不支持此Magisk版本."
  Print "- 请安装 Magisk v20.4+!"
  Print
  Print "- 或Magisk环境不完整."
  Print "- 请修复Magisk环境!"
  Print
  exit 1
}


#########################
# 加载 util_functions.sh
#########################
OUTFD=$2
ZIPFILE=$3

mount /data 2>/dev/null

[ -f /data/adb/magisk/util_functions.sh ] || require_new_magisk
. /data/adb/magisk/util_functions.sh
[ $MAGISK_VER_CODE -lt 20400 ] && require_new_magisk

setup_flashable
mount_partitions
api_level_arch_detect

if $BOOTMODE; then
    boot_actions
else
    recovery_actions
fi

unzip -o "$ZIPFILE" module.prop -d $TMPDIR >&2
[ ! -f $TMPDIR/module.prop ] && abort "! 从 zip 中提取文件失败."

$BOOTMODE && MODDIRNAME=modules_update || MODDIRNAME=modules
MODULEROOT=$NVBASE/$MODDIRNAME
MODID=`grep_prop id $TMPDIR/module.prop`
MODPATH=$MODULEROOT/$MODID

rm -rf $MODPATH 2>/dev/null
mkdir -p $MODPATH
cp -r $TMPDIR/* $MODPATH/

print_modname() {
  Print "- Powered By Magisk"
  Print "_______________"
  Print "  ※ 作者信息 ※"
  Print "¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯"
  Print " 8b        d8           88      a8P"
  Print "  Y8,    ,8P            88    ,88'"
  Print "   Y8,  ,8P             88  ,88\""
  Print "    \"8aa8\"  88       88 88,d88'"
  Print "     \`88'   88       88 8888\"88,"
  Print "      88    88       88 88P   Y8b"
  Print "      88    \"8a,   ,a88 88     \"88,"
  Print "      88     \`\"YbbdP'Y8 88       Y8b"
  Print "_______________"
  Print "  ※ 模块信息 ※"
  Print "¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯"
  Print "- 模块名称: $name"
  Print "- 模块版本: $version"
  Print "- 模块代号: $id"
  Print "- 模块制作: 余空"
}



print_modname
on_install

for TARGET in $REPLACE; do
    Print "- 正在删除目标文件: ${TARGET}."
    mktouch $MODPATH$TARGET/.replace
done

if $BOOTMODE; then
    mktouch $NVBASE/modules/$MODID/update
    cp -af $MODPATH/module.prop $NVBASE/modules/$MODID/module.prop
fi

if [ -f $MODPATH/sepolicy.rule -a -e $PERSISTDIR ]; then
    Print "- 安装自定义sepolicy补丁."
    PERSISTMOD=$PERSISTDIR/magisk/$MODID
    mkdir -p $PERSISTMOD
    cp -af $MODPATH/sepolicy.rule $PERSISTMOD/sepolicy.rule
fi

cd /
$BOOTMODE || recovery_cleanup
rm -rf $MODPATH/tools
rm -rf $TMPDIR

Print "_______________"
Print "  ※ 附加信息 ※"
Print "¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯"
Print "- 刷入时间: $Start_Time"
End_Time=$(date "+%Y-%m-%d %H:%M:%S")
Duration=$(Print $((Sleep_Time + $(date +%s -d "${End_Time}") - $(date +%s -d "${Start_Time}"))) | awk '{t=split("60 秒 60 分 24 时 999 天",a);for(n=1;n<t;n+=2){if($1==0)break;s=$1%a[n]a[n+1]s;$1=int($1/a[n])}print s}')
Print "- 刷入耗时: $Duration"
Print "_______________"
Print "  ※ 刷入成功 ※"
Print "¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯"
Print "- 请重启设备."
exit 0