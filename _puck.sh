#!/bin/bash
deploy_name=""

function init_prj()
{
    _prj_name=$1
    _deploy_sdk=$2
    _local_prj_dir=$DEFAULT_LOCAL_PATH/$_prj_name
    _local_sys_dir=$_local_prj_dir/$_prj_name
    _local_sdk_dir=$_local_prj_dir/$_prj_name"_sdk"

    _local_sys_src=$JENKINS_WORKSPACE_PATH/$_prj_name

    if [ -d "$_local_sys_dir" ]; then
        rm -rf $_local_sys_dir
    fi

    mkdir -p $_local_sys_dir

    if [ "$_deploy_sdk" == "" ] ; then #部署服务，而不是sdk,拷贝整体文件
        cp -r $_local_sys_src/* $_local_sys_dir/
    else #部署sdk，只需要sdk文件
        if [ ! -d $_local_sdk_src ];then
            echo "部署SDK失败，工程中不存在sdk文件夹."
            exit -1
        fi
        cp -r $_local_sys_src/sdk/* $_local_sys_dir/
    fi
}

function arc_prj()
{
    _prj_name=$1
    _prj_tag=$2
    _deploy=$3
    _deploy_sdk=$4

    _ts=`date +%s`

    if [ "$_deploy_sdk" == "" ] ; then
        _deploy_name=$_prj_name"-"$_prj_tag"-"$_deploy"-"$_ts
    else
        _deploy_name=$_prj_name"_sdk-"$_prj_tag"-"$_deploy"-"$_ts
    fi

    cd $DEFAULT_LOCAL_PATH/$_prj_name
    mv $_prj_name $_deploy_name

    _tar=$DEFAULT_LOCAL_PATH/$_prj_name/$_deploy_name.tgz
    tar -zcf $_tar $_deploy_name
    _return=$?
    if [ $_return != 0 ];then
         echo "项目打包失败."
         exit -1
    fi
    echo "tar:"$_tar
    deploy_name=$_deploy_name
}
