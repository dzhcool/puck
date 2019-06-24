#!/bin/bash
export PATH=.:/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/usr/local/bin

CUR_DIR=$(cd "$(dirname "$0")"; pwd)
source $CUR_DIR/conf.sh
cd $CUR_DIR

function usage() {
    echo "usage: $0 --prj prj --tag tag --env env --deploy deploy[pub|patch] --debug on"
}

while [ "$1" != "" ]; do
    case $1 in
        --prj )           shift
                          prj_name=$1
                          ;;
        --tag )           shift
                          prj_tag=$1
                          ;;
        --env )           shift
                          env=$1
                          ;;
        --deploy )        shift
                          deploy=$1
                          ;;
        --debug )         shift
                          debug="-vvv"
                          ;;
        -h | --help )     usage
                          exit
                          ;;
        * )               usage
                          exit 1
    esac
    shift
done

if [ "$deploy" = "sdk" ]; then
    . ./sdk.sh --prj "$prj_name" --tag "$prj_tag" --env "$env"
    exit 0;
fi

if [ "$prj_name" = "" ] || [ "$prj_tag" = "" ]; then
    usage
    exit -1
fi

source $CUR_DIR/_puck.sh
export CRYPTOGRAPHY_ALLOW_OPENSSL_098=1

mod="SYS"
deploy_dir=${DEFAULT_SYS_DIR}
inventory=$JENKINS_WORKSPACE_PATH/${prj_name}/_prj/hosts

#初始化项目
init_prj $prj_name
#对项目打包
arc_prj $prj_name $prj_tag $deploy

echo "---> 开始部署项目：" $prj_name
echo "---> $mod 版本号：" $prj_tag
echo "---> 机器列表：" $env
echo "---> 部署模式：" $deploy

cd $CUR_DIR
ansible-playbook src/deploy.yml -i $inventory --extra-var "env=${env} deploy=${deploy} deploy_dir=${deploy_dir} deploy_name=${deploy_name} prj_name=${prj_name} pkgs_dir=${DEFAULT_PKGS_DIR} local_path=${DEFAULT_LOCAL_PATH} ruser=${DEFAULT_REMOTE_USER}" -u ${DEFAULT_REMOTE_USER} -f 10 ${debug}

echo "rm -rf ${DEFAULT_LOCAL_PATH}/${prj_name}/*"
rm -rf ${DEFAULT_LOCAL_PATH}/${prj_name}/*
