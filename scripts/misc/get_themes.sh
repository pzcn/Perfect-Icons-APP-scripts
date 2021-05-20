if [ -d "/data/adb/modules_update/MIUIiconsplus" ]; then
moduledir=/data/adb/modules_update/MIUIiconsplus
echo "以 Magisk 模块形式进行安装，您已安装$theme，重启后应用。"
elif [ -d "/data/adb/modules/MIUIiconsplus" ]
moduledir=/data/adb/modules/MIUIiconsplus
echo "以 Magisk 模块形式进行安装，当前已安装$theme。"
else
echo "以 Magisk 模块形式进行安装，当前未安装。"
fi