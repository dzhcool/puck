#!/bin/bash
export PATH=.:/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/usr/local/bin

Inventory=""
post=0
while [ "$1" != "" ]; do
    case $1 in
        --prj )           shift
                          prj_name=$1
                          ;;
        *)                HOST[$post]=$1
                          post=$post+1
    esac
    shift
done

if [ "$prj_name" = "" ]; then
    echo "prj is empty."; exit -1;
fi

if [ ${#HOST[@]} == 0 ];then
    echo ""; exit 0;
fi

_cur=`date "+%Y-%m-%d %H:%M:%S"`
_ts=`date -d "$_cur" +%s`
Inventroy_path="/tmp"
Inventroy_name=$prj_name"-"$_ts".inventory"
Inventroy=$Inventroy_path"/"$Inventroy_name

echo "[all]" >> $Inventroy;

for host in ${HOST[@]}
do
    echo $host >> $Inventroy;
done

echo $Inventroy
exit 0;
