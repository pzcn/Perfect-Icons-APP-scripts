if [ $1 = list ] ; then
if [ -s theme_files/denylist ] ; then
	list=$(cat theme_files/denylist)
	if [ $list = all ];then
	echo 全部app
	else
	cat theme_files/denylist
	fi
else
	echo 禁用列表为空
fi
fi

if [ $1 = sel ] ; then
if [ -s theme_files/denylist ] ; then
	cat theme_files/denylist
fi
fi