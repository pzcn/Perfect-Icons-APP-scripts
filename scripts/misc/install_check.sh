var_version="`getprop ro.build.version.release`"
var_miui_version="`getprop ro.miui.ui.version.code`"
var hasRoot = KrScriptCore.rootCheck()
if (hasRoot); then
if [ $var_version -lt 10 ] ;then
echo 0
elif [ $var_miui_version -lt 10 ] ;then
echo 0
else
echo 1
fi
else
echo 0
fi