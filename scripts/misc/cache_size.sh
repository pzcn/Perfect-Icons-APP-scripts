cache_size=$((`du theme_files|awk '{print $1}'`))
echo "当前缓存大小：$(printf '%.1f' `echo "scale=1;$cache_size/1024"|bc`) MB。出现问题时可以尝试清理缓存，清理后下次安装时会重新下载资源。"