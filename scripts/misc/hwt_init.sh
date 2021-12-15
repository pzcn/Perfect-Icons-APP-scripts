[ -f "theme_files/hwt_theme_config" ] || ( touch theme_files/hwt_theme_config && echo "sel_theme=Aquamarine" > theme_files/hwt_theme_config )
[ -f "theme_files/hwt_size_config" ] || ( touch theme_files/hwt_size_config && echo "hwt_size=M" > theme_files/hwt_size_config )
[ -f "theme_files/hwt_shape_config" ] || ( touch theme_files/hwt_shape_config && echo "hwt_shape=Rectangle" > theme_files/hwt_shape_config )

if [[ ! -f "theme_files/hwt_shape_config" ]]; then
touch theme_files/mtzdir_config
if [[ -d "/sdcard/Huawei/Theme" ]]; then
echo "hwtdir=/sdcard/Huawei/Theme" > theme_files/mtzdir_config
elif [[ -d "/sdcard/Download" ]]; then
echo "hwtdir=/sdcard/Download" > theme_files/mtzdir_config
else
echo "hwtdir=/sdcard" > theme_files/mtzdir_config
fi
fi
