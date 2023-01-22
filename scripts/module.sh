modile_files() { 
  mkdir -p META-INF/com/google/android
  cat > META-INF/com/google/android/update-binary << 'EOF'
#!/sbin/sh

#################
# Initialization
#################

umask 022

# Global vars
TMPDIR=/dev/tmp
PERSISTDIR=/sbin/.magisk/mirror/persist

rm -rf $TMPDIR 2>/dev/null
mkdir -p $TMPDIR

# echo before loading util_functions
ui_print() { echo "$1"; }

require_new_magisk() {
  ui_print "*******************************"
  ui_print " Please install Magisk v19.0+! "
  ui_print "*******************************"
  exit 1
}

is_legacy_script() {
  unzip -l "$ZIPFILE" install.sh | grep -q install.sh
  return $?
}

print_modname() {
  local len
  len=`echo -n $MODNAME | wc -c`
  len=$((len + 2))
  local pounds=`printf "%${len}s" | tr ' ' '*'`
  ui_print "$pounds"
  ui_print " $MODNAME "
  ui_print "$pounds"
  ui_print "*******************"
  ui_print " Powered by Magisk "
  ui_print "*******************"
}

##############
# Environment
##############

OUTFD=$2
ZIPFILE=$3

mount /data 2>/dev/null

# Load utility functions
[ -f /data/adb/magisk/util_functions.sh ] || require_new_magisk
. /data/adb/magisk/util_functions.sh
[ $MAGISK_VER_CODE -gt 18100 ] || require_new_magisk

# Preperation for flashable zips
setup_flashable

# Mount partitions
mount_partitions

# Detect version and architecture
api_level_arch_detect

# Setup busybox and binaries
$BOOTMODE && boot_actions || recovery_actions

##############
# Preparation
##############

# Extract prop file
unzip -o "$ZIPFILE" module.prop -d $TMPDIR >&2
[ ! -f $TMPDIR/module.prop ] && abort "! Unable to extract zip file!"

$BOOTMODE && MODDIRNAME=modules_update || MODDIRNAME=modules
MODULEROOT=$NVBASE/$MODDIRNAME
MODID=`grep_prop id $TMPDIR/module.prop`
MODPATH=$MODULEROOT/$MODID
MODNAME=`grep_prop name $TMPDIR/module.prop`

# Create mod paths
rm -rf $MODPATH 2>/dev/null
mkdir -p $MODPATH

##########
# Install
##########

if is_legacy_script; then
  unzip -oj "$ZIPFILE" module.prop install.sh uninstall.sh 'common/*' -d $TMPDIR >&2

  # Load install script
  . $TMPDIR/install.sh

  # Callbacks
  print_modname
  on_install

  # Custom uninstaller
  [ -f $TMPDIR/uninstall.sh ] && cp -af $TMPDIR/uninstall.sh $MODPATH/uninstall.sh

  # Skip mount
  $SKIPMOUNT && touch $MODPATH/skip_mount

  # prop file
  $PROPFILE && cp -af $TMPDIR/system.prop $MODPATH/system.prop

  # Module info
  cp -af $TMPDIR/module.prop $MODPATH/module.prop

  # post-fs-data scripts
  $POSTFSDATA && cp -af $TMPDIR/post-fs-data.sh $MODPATH/post-fs-data.sh

  # service scripts
  $LATESTARTSERVICE && cp -af $TMPDIR/service.sh $MODPATH/service.sh

  ui_print "- Setting permissions"
  set_permissions
else
  print_modname

  unzip -o "$ZIPFILE" customize.sh -d $MODPATH >&2

  if ! grep -q '^SKIPUNZIP=1$' $MODPATH/customize.sh 2>/dev/null; then
    ui_print "- Extracting module files"
    unzip -o "$ZIPFILE" -x 'META-INF/*' -d $MODPATH >&2

    # Default permissions
    set_perm_recursive $MODPATH 0 0 0755 0644
  fi

  # Load customization script
  [ -f $MODPATH/customize.sh ] && . $MODPATH/customize.sh
fi

# Handle replace folders
for TARGET in $REPLACE; do
  ui_print "- Replace target: $TARGET"
  mktouch $MODPATH$TARGET/.replace
done

if $BOOTMODE; then
  # Update info for Magisk Manager
  mktouch $NVBASE/modules/$MODID/update
  cp -af $MODPATH/module.prop $NVBASE/modules/$MODID/module.prop
fi

# Copy over custom sepolicy rules
if [ -f $MODPATH/sepolicy.rule -a -e $PERSISTDIR ]; then
  ui_print "- Installing custom sepolicy patch"
  PERSISTMOD=$PERSISTDIR/magisk/$MODID
  mkdir -p $PERSISTMOD
  cp -af $MODPATH/sepolicy.rule $PERSISTMOD/sepolicy.rule
fi

# Remove stuffs that don't belong to modules
rm -rf \
$MODPATH/system/placeholder $MODPATH/customize.sh \
$MODPATH/README.md $MODPATH/.git* 2>/dev/null

##############
# Finalizing
##############

cd /
$BOOTMODE || recovery_cleanup
rm -rf $TMPDIR

ui_print "- Done"
exit 0
EOF

  echo "id=MIUIiconsplus
name=MIUI ${string_projectname}
author=@PedroZ
description=${string_moduledescription_1}${theme_name}${string_moduledescription_2}
version=$(TZ=$(getprop persist.sys.timezone) date '+%Y%m%d%H%M')
theme=$theme_name
themeid=$var_theme" >> module.prop

}
disable_dynamicicon() {
test=`head -n 1 ${START_DIR}/theme_files/denylist`
if [ "$test" = "all" ] ; then
  echo "- 禁用所有动态图标..."
  rm -rf $TEMP_DIR/layer_animating_icons
elif [ "$test" = "" ] ; then
  :
else
  echo "- 禁用下列app的动态图标："
  list=`cat ${START_DIR}/theme_files/denylist`
  for p in $list
  do
    [ -d "$TEMP_DIR/layer_animating_icons/$p" ] && rm -rf  $TEMP_DIR/layer_animating_icons/$p && echo "  ""$p"
  done
fi
}

install() {
    echo "${string_exporting}$theme_name..."
    cd theme_files/miui
    zip -r $TEMP_DIR/icons.zip * -x './res/drawable-xxhdpi/.git/*' >/dev/null
    cd ../..
    cd $TEMP_DIR
    toybox tar -xf  $TEMP_DIR/$var_theme.tar.xz -C "$TEMP_DIR/"
    mkdir -p ./res/drawable-xxhdpi
    mv  icons/* ./res/drawable-xxhdpi 2>/dev/null
    rm -rf icons
    [ -f ${START_DIR}/theme_files/denylist ] && disable_dynamicicon
    zip -r icons.zip ./layer_animating_icons >/dev/null
    zip -r icons.zip ./res >/dev/null
    rm -rf res
    rm -rf layer_animating_icons
    cd ..
    [ $addon == 1 ] && addon
    mkdir $TEMP_DIR/moduletmp
    cp -rf $TEMP_DIR/icons.zip $TEMP_DIR/moduletmp/icons
    cd $TEMP_DIR/moduletmp
    modile_files
    zip -r module.zip * >/dev/null
    if [ "$1" == kernelsu ]; then 
      [ -f /data/adb/ksud ]  && /data/adb/ksud module install module.zip
    else
    time=$(TZ=$(getprop persist.sys.timezone) date '+%Y%m%d%H%M')
    modulefilepath=$moduledir/${theme_name}${string_projectname}-$time.zip
    mv module.zip $modulefilepath
    fi
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
echo "${string_newverdown_1}${theme_name}${string_newverdown_2}"
download
else
echo "${string_vernoneedtodown_1}${theme_name}${string_vernoneedtodown_2}"
cp -rf theme_files/${var_theme}.ini $TEMP_DIR/${var_theme}.ini
cp -rf theme_files/${var_theme}.tar.xz $TEMP_DIR/${var_theme}.tar.xz
fi
else download
fi
}

download() {
curl -skLJo "$TEMP_DIR/${var_theme}.ini" "https://miuiicons-generic.pkg.coding.net/icons/files/${var_theme}.ini?version=latest"
    mkdir theme_files 2>/dev/null
    source $TEMP_DIR/${var_theme}.ini
    cp -rf $TEMP_DIR/${var_theme}.ini theme_files/${var_theme}.ini
    if [ $file_size -gt 5242880 ] ;then
    downloadUrl=${link_miui}/${var_theme}.tar.xz
    downloader "$downloadUrl" $md5
    [ $var_theme == iconsrepo ] || cp $downloader_result theme_files/${var_theme}.tar.xz
    mv $downloader_result $TEMP_DIR/$var_theme.tar.xz
    else
echo "${string_needtodownloadname_1}${theme_name}${string_needtodownloadname_2}"
  [ $file_size ] || { echo ${string_cannotdownload} && rm -rf $TEMP_DIR/* 2>/dev/null&& exit 1; }
  echo "${string_needtodownloadsize_1}$(printf '%.1f' `echo "scale=1;$file_size/1048576"|bc`)${string_needtodownloadsize_2}"
      curl -skLJo "$TEMP_DIR/${var_theme}.tar.xz" "https://miuiicons-generic.pkg.coding.net/icons/files/${var_theme}.tar.xz?version=latest"
      [ $var_theme == iconsrepo ] || cp "$TEMP_DIR/${var_theme}.tar.xz" "theme_files/${var_theme}.tar.xz"
    md5_loacl=`md5sum $TEMP_DIR/${var_theme}.tar.xz|cut -d ' ' -f1`
    if [[ "$md5" = "$md5_loacl" ]]; then
      echo $string_downloadsuccess
    else
      echo ${string_downloaderror}
    rm -rf $TEMP_DIR/* >/dev/null
    exit 1
    fi
    fi
}



addon(){
    addon_path=$SDCARD_PATH/Documents/${string_addonfolder}
    if [ -d "$addon_path" ];then
    echo "${string_importaddonicons}"
    mkdir -p $TEMP_DIR/res/drawable-xxhdpi/
    mkdir -p $TEMP_DIR/layer_animating_icons
    cp -rf $addon_path/${string_animatingicons}/* $TEMP_DIR/layer_animating_icons/ >/dev/null
    cp -rf $addon_path/${string_staticicons}/* $TEMP_DIR/res/drawable-xxhdpi/ >/dev/null
    cd $TEMP_DIR
    zip -r icons.zip res >/dev/null
    zip -r icons.zip layer_animating_icons >/dev/null
    cd ..
    fi
}
  exec 3>&2
  exec 2>/dev/null
  curl -skLJo "$TEMP_DIR/link.ini" "https://miuiicons-generic.pkg.coding.net/icons/files/link.ini?version=latest"
  source $TEMP_DIR/link.ini
  http_code="`curl -I -s --connect-timeout 1 ${link_check} -w %{http_code} | tail -n1`" 
  if [ "$http_code" != null ];then
    if [[ ! $httpcode == *$http_code* ]]; then
    {  echo "${string_nonetworkdetected}" && rm -rf $TEMP_DIR/* >/dev/null && exit 1; }
  fi
else
  {  echo "${string_nonetworkdetected}" && rm -rf $TEMP_DIR/* >/dev/null && exit 1; }
fi

  source theme_files/theme_config
  source theme_files/moduledir_config
  source theme_files/addon_config
  source $START_DIR/online-scripts/misc/downloader.sh
  [ -d "$moduledir" ] || {  echo ${string_dirnotexist} && rm -rf $TEMP_DIR/* >/dev/null && exit 1; }
  var_theme=iconsrepo
  if [[ -d theme_files/miui/res/drawable-xxhdpi/.git ]]; then
    source theme_files/${var_theme}.ini
    old_ver=$theme_version
    curl -skLJo "$TEMP_DIR/${var_theme}.ini" "https://miuiicons-generic.pkg.coding.net/icons/files/${var_theme}.ini?version=latest"
    source $TEMP_DIR/${var_theme}.ini
    new_ver=$theme_version
    if [ $new_ver -ne $old_ver ] ;then 
    echo "${string_newverdown_1}${theme_name}${string_newverdown_2}"
    echo "${string_gitpull}"
        cd theme_files/miui/res/drawable-xxhdpi
        export LD_LIBRARY_PATH=${START_DIR}/script/toolkit/so: $LD_LIBRARY_PATH
        git pull --rebase >/dev/null
        cp -rf $TEMP_DIR/${var_theme}.ini ${START_DIR}/theme_files/${var_theme}.ini
    cd ../../../..
    else
    echo "${string_vernoneedtodown_1}${theme_name}${string_vernoneedtodown_2}"
    fi
    echo "$var_theme=$theme_version" >> $TEMP_DIR/module.prop
  else
    getfiles
        echo "${string_extracting}${theme_name}..."
    toybox tar -xf "$TEMP_DIR/iconsrepo.tar.xz" -C "$TEMP_DIR/" >&2
    mv $TEMP_DIR/icons $TEMP_DIR/icons.zip
    unzip $TEMP_DIR/icons.zip -d theme_files/miui >/dev/null
    rm -rf $TEMP_DIR/icons.zip
    rm -rf $TEMP_DIR/iconsrepo.tar.xz
  fi
  var_theme=$sel_theme
  getfiles
  install
  rm -rf $TEMP_DIR/*
  echo "---------------------------------------------"
  exit 0
