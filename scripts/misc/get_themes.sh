if [ -d "/data/adb/modules_update/MIUIiconsplus" ]; then
moduledir=/data/adb/modules_update/MIUIiconsplus
else
moduledir=/data/adb/modules/MIUIiconsplus
fi
source $moduledir/module.prop
if [ "$theme" = "" ]; then
echo "以 Magisk 模块形式进行安装，当前未安装。"
else
echo "以 Magisk 模块形式进行安装，当前已安装$theme。"
fi