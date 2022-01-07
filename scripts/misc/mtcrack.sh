require_new_magisk() {
  echo
  echo "$string_MagiskNotSupport"
  echo
  echo "$string_NeedNewMagisk"
  echo
  exit 1
}

rm -rf $TEMP_DIR/*
[ -f /data/adb/magisk/util_functions.sh ] || require_new_magisk
. /data/adb/magisk/util_functions.sh
[ $MAGISK_VER_CODE -gt 20000 ] || require_new_magisk
MODULEROOT=/data/adb/modules_update
MODPATH=/data/adb/modules_update/antimithemerestore
rm -rf $MODPATH 2>/dev/null

echo "id=antimithemerestore
name=MIUI ${string_antimodulename}
author=@PedroZ
description=${string_antimoduledescription}
version=1.0
versionCode=1" >> $TEMP_DIR/module.prop

echo '#!/system/bin/sh
chmod 731 /data/system/theme
rm -rf /data/system/package_cache/*' >$TMPDIR/service.sh

echo '#!/system/bin/sh
rm -rf /data/system/package_cache/*
chmod 775 /data/system/theme
rm -rf /data/system/theme/rights' >$TMPDIR/uninstall.sh

  mkdir -p $MODPATH
  cp -rf $FAKEMODPATH/. $MODPATH
  set_perm_recursive $MODPATH 0 0 0755 0644
  cp -af $TMPDIR/module.prop /data/adb/modules_update/antimithemerestore/module.prop
  cp -af $TMPDIR/service.sh /data/adb/modules_update/antimithemerestore/service.sh
  cp -af $TMPDIR/uninstall.sh /data/adb/modules_update/antimithemerestore/uninstall.sh
  mktouch /data/adb/modules/antimithemerestore/update
  rm -rf \
  $MODPATH/system/placeholder $MODPATH/customize.sh \
  $MODPATH/README.md $MODPATH/.git* 2>/dev/null
  cd /
  rm -rf $TEMP_DIR/*
  echo ""
  echo "${string_installsuccess}"
  echo "---------------------------------------------"
  exit 0