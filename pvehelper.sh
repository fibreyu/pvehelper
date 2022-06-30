#!/bin/bash

set -e
export LANG="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# check user as root
if [[ $EUID -ne 0 ]]; then
  echo "You must run this with superuser priviliges. " 2>&1
  exit 1
fi

VERSION=1.0.0
CHANGE_SOURCE=0
RECOVER_SOURCE=0
ADD_TEMPTURE_SHOW=0
DELETE_TEMPEURE_SHOW=0
ADD_SUBSCRIPTION_INFO=0
DELETE_SUBSCRIPTION_INFO=0
RDM_PASSTHROUGH_DISK=0
PASSTHROUGH_NETWORK_PORT=0
INTERACTIVE=0
SHOW_HELP=0
LANGUAGE=''
SYNCHRONIZE_TIME=0

# default interactive
[[ $# -eq 0 ]] && INTERACTIVE=1

while [[ $# -ge 1 ]]; do
    case $1 in
        -v|--version)
            echo $VERSION
            exit 0
            ;;
        -i|--interactive)
            INTERACTIVE=1
            shift
            ;;
        -s|--synchronizetime)
            SYNCHRONIZE_TIME=1
            shift
            ;;
        -cs|--changesource)
            CHANGE_SOURCE=1
            shift
            ;;
        -rs|--recoversource)
            RECOVER_SOURCE=1
            shift
            ;;
        -at|--addtempture)
            ADD_TEMPTURE_SHOW=1
            shift
            ;;
        -dt|--deletetempture)
            DELETE_TEMPEURE_SHOW=1
            shift
            ;;
        -di|--deletesubinfo)
            DELETE_SUBSCRIPTION_INFO=1
            shift
            ;;
        -ai|--addsubinfo)
            ADD_SUBSCRIPTION_INFO=1
            shift
            ;;
        -rpd|--rdmpassthroughdisk)
            RDM_PASSTHROUGH_DISK=1
            shift
            ;;
        --pn|--PASSTHROUGH_NETWORK_PORT)
            PASSTHROUGH_NETWORK_PORT
            shift
            ;;
        -h|--help)
            SHOW_HELP=1
            ;;
        *)
            echo "user -h or --help for help"
            exit 1
            ;;
    esac
done

function Main() {

    # enter interactive mode
    if [[ $INTERACTIVE -eq 1 ]]; then
        Select_language
        exit 0
    fi

    # change source
    if [[ $CHANGE_SOURCE -eq 1 ]]; then
        Change_source
    fi

    # recover source
    if [[ $RECOVER_SOURCE -eq 1 ]]; then
        Recover_source
    fi

    # add tempture show
    if [[ $ADD_TEMPTURE_SHOW -eq 1 ]]; then
        Add_tempture_show
    fi

    # delete tempture show
    if [[ $DELETE_TEMPEURE_SHOW -eq 1 ]]; then
        Delete_tempture_show
    fi

    # delete subscription info
    if [[ $DELETE_SUBSCRIPTION_INFO -eq 1 ]]; then
        Delete_subscription_info
    fi

    # add subscription info
    if [[ $ADD_SUBSCRIPTION_INFO -eq 1 ]]; then
        Add_subscription_info
    fi

    # synchronize time
    if [[ $SYNCHRONIZETIME -eq 1 ]]; then
        Synchronize_time
    fi

    # rdm passthrough disk
    if [[ $RDM_PASSTHROUGH_DISK -eq 1 ]]; then
        Rdm_passthrough_disk
    fi

    # PASSTHROUGH_NETWORK_PORT
    if [[ $PASSTHROUGH_NETWORK_PORT -eq 1 ]]; then
        Passthrough_network_port
    fi

    # show help
    if [[ $SHOW_HELP -eq 1 ]]; then
        Show_help
    fi

}


# =============================
# ===  select language ========
# =============================

function Select_language() {
    clear
    echo ""
    echo "Select Language: "
    echo "[1] 简体中文"
    echo "[2] English"
    read -p "Choose Language [default 1]: " lang
    case $lang in
        1)
            clear
            LANGUAGE="zh"
            ;;
        2)
            clear
            LANGUAGE="en"
            ;;
        *)
            clear
            LANGUAGE="zh"
            ;;
    esac

    Interactive
}


# =================================
# =========== Show_help ===========
# =================================

function Interactive() {
    option=-1
    if [[ $LANGUAGE == "en" ]]; then
        echo "Options:"
        echo "[1] change sources"
        echo "[2] restore source"
        echo "[3] add tempture show"
        echo "[4] delete tempture show"
        echo "[5] delete subscription info"
        echo "[6] restore subscription info"
        echo "[7] synchronize time"
        echo "[8] update RTL8125 driver"
        echo "[9] RDM passthrough disk"
        echo "[10] Passthrough_network_port"
        read -p "select [default 1]" option
    elif [[ $LANGUAGE == "zh" ]]; then
        echo "选项:"
        echo "[1] 换源"
        echo "[2] 恢复官方源"
        echo "[3] 添加温度显示"
        echo "[4] 去除温度显示"
        echo "[5] 删除订阅提示"
        echo "[6] 恢复订阅提示"
        echo "[7] 同步时间"
        echo "[8] 更新瑞昱R8125驱动"
        echo "[9] RDM直通硬盘"
        echo "[10] 直通网口"
        read -p "请选择[默认 1]:  " option
    fi

    [[ $option == "" ]] && option=1

    case $option in
        1)
            echo "change sources"
            Change_source
            ;;
        2)
            echo "restore source"
            Recover_source
            ;;
        3)
            echo "add tempture show"
            Add_tempture_show
            ;;
        4)
            echo "delete tempture show"
            Delete_tempture_show
            ;;
        5)
            echo "delete subscription info"
            Delete_subscription_info
            ;;
        6)
            echo "add subscription info"
            Add_subscription_info
            ;;
        7)
            echo "synchronize time"
            Synchronize_time
            ;;
        8)
            echo "update r8125 driver"
            Update_r8125_driver
            ;;
        9)
            echo "rdm passthrough disk"
            Rdm_passthrough_disk
            ;;
        10)
            echo "Passthrough network port"
            Passthrough_network_port
            ;;
        *)
            echo "wrong args !"
            Interactive
    esac

}

# =================================
# =========== Show_help ===========
# =================================

function Show_help() {
    echo "help"

    if [[ $INTERACTIVE -eq 1 ]]; then
        Interactive
    fi
}

# =================================
# ======== Synchronize_time =======
# =================================

function Synchronize_time() {
    if ! type ntpdate >/dev/null 2>&1;then
        apt install ntpdate -y

    fi
    ntpdate ntp1.aliyun.com 

    if [[ $INTERACTIVE -eq 1 ]]; then
        Interactive
    fi

}

# =============================
# ======  add tempture ========
# =============================

function Install_temp_tools() {
    if ! type sensors >/dev/null 2>&1;then
        echo "start install lm-sensors"
        apt install -y lm-sensors && echo "install lm-sensors success!" || (echo "install lm-sensors failed!" ; exit 1)
        echo "start config lm-sensors"
        sensors-detect --auto >> ./sensors.log
    fi

    if ! type nvme >/dev/null 2>&1;then
        echo "start install nvme-cli"
        apt install -y nvme-cli && echo "install nvme-cli success!" || (echo "install nvme-cli failed!" ; exit 1)
        chmod 740 /usr/sbin/nvme && chmod +s /usr/sbin/nvme
    fi
    
    if ! type hddtemp >/dev/null 2>&1;then
        echo "start install hddtemp"
        apt install -y hddtemp && echo "install hddtemp success!" || (echo "install hddtemp failed!" ; exit 1)
        chmod 740 /usr/sbin/hddtemp && chmod +s /usr/sbin/hddtemp
    fi
    
    if ! type smartctl >/dev/null 2>&1;then
        echo "start install smartmontools"
        apt install -y smartmontools && echo "install smartmontools success!" || (echo "install smartmontools failed!" ; exit 1)
        chmod 740 /usr/sbin/smartctl && chmod +s /usr/sbin/smartctl
    fi

    [[ -u /usr/sbin/hddtemp ]] && echo "SUID" > /dev/null 2>&1 || chmod +s /usr/sbin/hddtemp
    [[ -u /usr/sbin/nvme ]] && echo "SUID" > /dev/null 2>&1 || chmod +s /usr/sbin/nvme
    [[ -u /usr/sbin/smartctl ]] && echo "SUID" > /dev/null 2>&1 || chmod +s /usr/sbin/smartctl
}

function Add_tempture_show() {
    
    js_o=''
    nodes_o=''

    # install dependency
    Install_temp_tools

    # backup
    [[ -e /usr/share/pve-manager/js/pvemanagerlib.js_bak ]] && cp -f /usr/share/pve-manager/js/pvemanagerlib.js_bak /usr/share/pve-manager/js/pvemanagerlib.js
    [[ -e /usr/share/perl5/PVE/API2/Nodes.pm_bak ]] && cp -f /usr/share/perl5/PVE/API2/Nodes.pm_bak /usr/share/perl5/PVE/API2/Nodes.pm

    cp -f /usr/share/pve-manager/js/pvemanagerlib.js /usr/share/pve-manager/js/pvemanagerlib.js_bak
    cp -f /usr/share/perl5/PVE/API2/Nodes.pm /usr/share/perl5/PVE/API2/Nodes.pm_bak


    js_o=$(Generate_tempture_info_js)
    nodes_o=$(Generate_tempture_info_Nodes)
    
    # echo -e ${js_o} > js
    sed -Ezi "s@(PVE Manager Version[^}]*\},)@\1${js_o}@" /usr/share/pve-manager/js/pvemanagerlib.js
    # echo -e ${nodes_o} > node
    sed -Ezi "s@(swapused\},[^}]*\};)@\1${nodes_o}@" /usr/share/perl5/PVE/API2/Nodes.pm

    # change height
    cols=`echo -e ${js_o} | grep "col" | sed 's/ //g' | sed 's/,/ /g'`
    col_1_num=0
    height=400
    for item in $cols;
    do
        case $item in
        colspan:1)
            col_1_num=$[col_1_num+1]
            ;;
        colspan:2)
            [[ $[col_1_num%2] != 0 ]] && col_1_num=$[col_1_num+1] 
            height=$[(col_1_num/2)*24+30+height]
            col_1_num=0
            ;;
        esac
    done

    sed -Ezi "s/(Ext.define\('PVE.node.StatusView[^0-9]*)[0-9]*/\1${height}/" /usr/share/pve-manager/js/pvemanagerlib.js

    systemctl restart pveproxy

    if [[ $INTERACTIVE -eq 1 ]]; then
        Interactive
    fi
}

# generate code in nodes
function Generate_tempture_info_Nodes() {
    local o='\n'
    sata=''
    nvme=''
    # cpu
    o=${o}'$res->{cpu_temperatures} = '"\`sensors | grep -iE '(^pack|^core).*:' | sed 's/ *(.*)//g' | sed 's/: */\":\"/g' | sed -E 's/^/\"/g' | sed 's/\\\\$/\",/g' | sed '1 s/^/{/' | sed '\\\\$ s/,\\\\$/}/' | sed -E 's/ +/_/g'\`;\n"

    # hdd
    ls /dev/sd? >/dev/null 2>&1 && satas=`ls /dev/sd?` >/dev/null 2>&1 || satas=''
    for sata in $satas;
    do
        if [[ ${sata} != '' ]]; then
            o=${o}"\$res->{${sata##*/}_temperatures} = ""\`smartctl -a ${sata} | grep -iE 'Device Model|User Capacity|Temperature_Celsius|Power_On_Hours|Temperature_Internal' | sed 's/Device Model/Device_Model/' | sed 's/User Capacity/User_Capacity/'  | sed -E 's/^ *[0-9]+ +//g' | sed -E 's/( +[^ ]+){7}//' | sed -E 's/(: +)| +/\":\"/' | sed 's/^/\"/' | sed 's/\\\\$/\",/' | sed '1 s/^/{/' | sed '\\\\$ s/,\\\\$/}/'\`;\n"
        fi
    done

    # nvme
    ls /dev/nvme? >/dev/null 2>&1 && nvmes=`ls /dev/nvme?` >/dev/null 2>&1 || nvmes=''
    for nvme in $nvmes;
    do
        if [[ ${nvme} != '' ]]; then
            o=${o}"\$res->{${nvme##*/}_temperatures} = ""\`smartctl -a ${nvme} | grep -E 'Model Number|Total NVM Capacity|Temperature:|Power On Hours' | sed 's/: */\":\"/g' | sed -E 's/ +/_/g' | sed 's/^/\"/' | sed 's/\\\\$/\",/g' | sed '1 s/^/{/' | sed '\\\\$ s/,\\\\$/}/'\`;\n;"
        fi
    done

    echo ${o}
}

# generate code in js
function Generate_tempture_info_js() {
    local o=""

    cpus=`sensors | grep -iE '(^pack|^core).*:' | sed 's/:.*$//g' | sed -E 's/\s+/_/g'`
    o="${o}"`Generate_tempture_info_js_box "CPU Temperature" "fa fa-thermometer-half"`
    item_num=0
    for item in $cpus;
    do
        o="${o}"`Generate_tempture_info_js_item "cpu_temperatures_${item}" ${item} "cpu_temperatures" "" ${item}`
        item_num=$[item_num+1]
    done
    [[ $[item_num%2] -ne 0 ]] && o="${o}"`Generate_tempture_info_js_blank "cpu_temperatures_blank"`

    # hdd
    ls /dev/sd? >/dev/null 2>&1 && satas=`ls /dev/sd?` >/dev/null 2>&1 || satas=''
    for sata in $satas;
    do
        sata_name=${sata##*/}
        items=`smartctl -a ${sata} | grep -iE 'Device Model|User Capacity|Temperature_Internal|Temperature_Celsius|Power_On_Hours' | sed 's/Device Model/Device_Model/g' | sed 's/User Capacity/User_Capacity/g' | sed 's/Temperature_Celsius/Temperature_Celsius:/g' | sed 's/Power_On_Hours/Power_On_Hours:/g' | sed 's/Temperature_Internal/Temperature_Internal:/g' | sed -E 's/^\s*[0-9]*\s+//g' | sed 's/:.*$//g' | sed 's/\s+/_/g'`
        o="${o}"`Generate_tempture_info_js_box "${sata_name} Info" "fa fa-hdd-o"`
        item_num=0
        for item in $items;
        do
            o="${o}"`Generate_tempture_info_js_item "${sata_name}_${item}" ${item} "${sata_name}_temperatures" "" ${item}`
            item_num=$[item_num+1]
        done
        [[ $[item_num%2] -ne 0 ]] && o="${o}"`Generate_tempture_info_js_blank "${sata_name}_blank"`
    done

    # nvme
    ls /dev/nvme? >/dev/null 2>&1 && nvmes=`ls /dev/nvme?` >/dev/null 2>&1 || nvmes=''
    for nvme in $nvmes;
    do
        nvme_name=${nvme##*/}
        items=`smartctl -a ${nvme} | grep -E 'Model Number|Total NVM Capacity|Temperature:|Power On Hours' | sed 's/:.*$//g' | sed -E 's/\s+/_/g'`
        o=${o}`Generate_tempture_info_js_box "${nvme_name} Info" "fa fa-microchip"`
        item_num=0
        for item in $items;
        do
            o="${o}"`Generate_tempture_info_js_item "${nvme_name}_${item}" "${item}" "${nvme_name}_temperatures" "" ${item} `
            item_num=$[item_num+1]
        done
        [[ $[item_num%2] -ne 0 ]] && o="${o}"`Generate_tempture_info_js_blank "${nvme_name}_blank"`
    done
    echo ${o}
}

# 1.itemID
# 2.title
# 3.textField
# 4.iconCls
# 5.key
function Generate_tempture_info_js_item() {
    local o=""

    itemID=${1}
    title=${2}
    textField=${3}
    iconCls=${4}
    key=${5}

    o="${o}{\n"
    [[ $iconCls != '' ]] && o="${o}iconCls: '${iconCls}',\n"
    [[ $itemID != '' ]] && o="${o}itemId: '${itemID}',\n"
    o="${o}colspan: 1,\n"
    o="${o}printBar: false,\n"
    o="${o}printSize: false,\n"
    [[ $textField != '' ]] && o="${o}title: gettext('$title'),\n"
    [[ $textField != '' ]] && o="${o}textField: '${textField}',\n"
    o="${o}renderer:function(value) {\n"
    o="${o} let d = JSON.parse(value)\n"
    o="${o} d = d['${key}'].replaceAll('_', '')\n"
    o="${o} return d.replaceAll('Â°C', '°C')"
    o="${o}}\n"
    o="${o}},\n"

    echo ${o}
}

# 1.itemID
function Generate_tempture_info_js_blank() {
    local o="\n"

    itemID=${1}

    o="${o}{\n"
    o="${o}itemId: '${itemID}',\n"
    o="${o}colspan: 1,\n"
    o="${o}printBar: false,\n"
    o="${o}printSize: false,\n"
    o="${o}title: gettext(' '),\n"
    o="${o}},\n"

    echo ${o}
}

function Generate_tempture_info_js_box() {
    local o=""
    
    title=${1}
    icon=${2}

    o="${o}{\n"
    o="${o}xtype: 'box',\n"
    o="${o}colspan: 2,\n"
    o="${o}html: '<div style=\"height: 20px; width: 100%; margin-top: 5px; font-size: 15px; font-weight: 40px\"><i class=\"${icon}\"></i> ${title}</div>',\n"
    o="${o}},\n"

    echo ${o}

}

# =================================
# ===== delete tempture show ====== 
# =================================

function Delete_tempture_show() {

    # recover
    [[ -e /usr/share/pve-manager/js/pvemanagerlib.js_bak ]] && mv -f /usr/share/pve-manager/js/pvemanagerlib.js_bak /usr/share/pve-manager/js/pvemanagerlib.js
    [[ -e /usr/share/perl5/PVE/API2/Nodes.pm_bak ]] && mv -f /usr/share/perl5/PVE/API2/Nodes.pm_bak /usr/share/perl5/PVE/API2/Nodes.pm

    systemctl restart pveproxy

    if [[ $INTERACTIVE -eq 1 ]]; then
        Interactive
    fi
}

# =================================
# ===== install r8125 driver ====== 
# =================================

function Update_r8125_driver() {

    wget https://gitee.com/fibreyu/pve_realtek_r8125_dkms/raw/main/auto_install.sh -O auto_install.sh && chmod +x auto_install.sh && bash auto_install.sh && rm -rf auto_install.sh

}


# =================================
# ======== change sources ========= 
# =================================

function Change_source() {
    # recover
    [[ -e /etc/apt/sources.list_bak ]] && mv -f /etc/apt/sources.list_bak /etc/apt/sources.list
    [[ -e /etc/apt/sources.list.d/pve-enterprise.list_bak ]] && mv -f /etc/apt/sources.list.d/pve-enterprise.list_bak /etc/apt/sources.list.d/pve-enterprise.list
    [[ -e /usr/share/perl5/PVE/APLInfo.pm_back ]] && mv -f /usr/share/perl5/PVE/APLInfo.pm_back /usr/share/perl5/PVE/APLInfo.pm
    [[ -e /etc/apt/sources.list.d/ceph.list_bak ]] && mv -f /etc/apt/sources.list.d/ceph.list_bak /etc/apt/sources.list.d/ceph.list
    [[ -e /usr/share/perl5/PVE/CLI/pveceph.pm_bak ]] && mv -f /usr/share/perl5/PVE/CLI/pveceph.pm_bak /usr/share/perl5/PVE/CLI/pveceph.pm
    [[ -e /etc/apt/sources.list.d/ceph.list ]] && rm -rf /etc/apt/sources.list.d/ceph.list

    # backup
    cp -af /etc/apt/sources.list /etc/apt/sources.list_bak
    cp -af /etc/apt/sources.list.d/pve-enterprise.list /etc/apt/sources.list.d/pve-enterprise.list_bak
    cp -af /usr/share/perl5/PVE/APLInfo.pm /usr/share/perl5/PVE/APLInfo.pm_bak
    # cp -af /etc/apt/sources.list.d/ceph.list /etc/apt/sources.list.d/ceph.list_bak
    cp -af /usr/share/perl5/PVE/CLI/pveceph.pm /usr/share/perl5/PVE/CLI/pveceph.pm_bak
    option=-1

    if [[ $LANGUAGE -eq "en" ]]; then
        clear
        echo "sources list:"
        echo "[1] ustc"
        echo "[2] tuna"
        echo "[3] aliyun"
        read -p "select [default 1]: " option
    elif [[ $LANGUAGE -eq "zh" ]]; then
        clear
        echo "源列表:"
        echo "[1] 中科大源"
        echo "[2] 清华源"
        echo "[3] 阿里云"
        read -p "请选择 [默认 1]: " option
    fi

    [[ $option == "" ]] && option=1

    case $option in
        1)  # ustc
            source /etc/os-release
            # debian source
            sed -i 's|^deb http://ftp.debian.org|deb https://mirrors.ustc.edu.cn|g' /etc/apt/sources.list
            sed -i 's|^deb http://security.debian.org|deb https://mirrors.ustc.edu.cn/debian-security|g' /etc/apt/sources.list
            # pve source
            echo "deb https://mirrors.ustc.edu.cn/proxmox/debian/pve $VERSION_CODENAME pve-no-subscription" > /etc/apt/sources.list.d/pve-enterprise.list
            # backup server source
            # echo "deb https://mirrors.ustc.edu.cn/proxmox/debian/pbs $VERSION_CODENAME pve-no-subscription" >> /etc/apt/sources.list.d/pve-enterprise.list
            # mail gateway source
            # echo "deb https://mirrors.ustc.edu.cn/proxmox/debian/pmg $VERSION_CODENAME pve-no-subscription" >> /etc/apt/sources.list.d/pve-enterprise.list
            # CT Templates source
            sed -i 's|http://download.proxmox.com|https://mirrors.ustc.edu.cn/proxmox|g' /usr/share/perl5/PVE/APLInfo.pm
            # ceph source
            # echo "deb https://mirrors.ustc.edu.cn/proxmox/debian/ceph-pacific bullseye main" > /etc/apt/sources.list.d/ceph.list
            echo "deb https://mirrors.ustc.edu.cn/proxmox/debian/ceph-pacific $VERSION_CODENAME main" > /etc/apt/sources.list.d/ceph.list
            echo "deb https://mirrors.ustc.edu.cn/proxmox/debian/ceph-octopus $VERSION_CODENAME main" >> /etc/apt/sources.list.d/ceph.list
            # sed -i 's|download.ceph.com|mirrors.ustc.edu.cn/ceph|g' /usr/share/perl5/PVE/CLI/pveceph.pm
            sed -i "s|http://download.proxmox.com/debian|https://mirrors.ustc.edu.cn/proxmox/debian|g" /usr/share/perl5/PVE/CLI/pveceph.pm
            ;;
        2)  # tuna
            source /etc/os-release
            # install cert
            apt -y install apt-transport-https ca-certificates
            # debian sources
            sed -i 's|^deb http://ftp.debian.org|deb https://mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list
            sed -i 's|^deb http://security.debian.org|deb https://mirrors.tuna.tsinghua.edu.cn/debian-security|g' /etc/apt/sources.list
            # pve source
            echo "deb https://mirrors.tuna.tsinghua.edu.cn/proxmox/debian $VERSION_CODENAME pve-no-subscription" > /etc/apt/sources.list.d/pve-enterprise.list
            # CT Templates source
            sed -i 's|http://download.proxmox.com|https://mirrors.tuna.tsinghua.edu.cn/proxmox|g' /usr/share/perl5/PVE/APLInfo.pm
            # ceph source
            # sed -i 's|download.ceph.com|mirrors.tuna.tsinghua.edu.cn/ceph|g' /usr/share/perl5/PVE/CLI/pveceph.pm
            # sed -i "s| http://download.proxmox.com/debian/ceph-octopus|https://mirrors.tuna.tsinghua.edu.cn/proxmox/debian|g" /usr/share/perl5/PVE/CLI/pveceph.pm
            # sed -i "s| http://download.proxmox.com/debian/ceph-pacific|https://mirrors.tuna.tsinghua.edu.cn/proxmox/debian|g" /usr/share/perl5/PVE/CLI/pveceph.pm
            ;;
        3)  # aliyun
            source /etc/os-release
            # debian sources
            sed -i 's|^deb http://ftp.debian.org|deb https://mirrors.aliyun.com|g' /etc/apt/sources.list
            sed -i 's|^deb http://security.debian.org|deb http://mirrors.aliyun.com/debian-security|g' /etc/apt/sources.list
            # pve source
            echo "deb http://download.proxmox.com/debian/pve $VERSION_CODENAME pve-no-subscription" >  /etc/apt/sources.list.d/pve-enterprise.list
            sed -i 's/pve-enterprise/pve-no-enterprise/g' /etc/apt/sources.list.d/pve-enterprise.list
            # ceph source
            # sed -i 's|download.ceph.com|mirrors.aliyun.com/ceph|g' /usr/share/perl5/PVE/CLI/pveceph.pm
            # sed -i "s|http://download.proxmox.com/debian|https://mirrors.aliyun.com/proxmox/debian|g" /usr/share/perl5/PVE/CLI/pveceph.pm
            ;;
        *)
            echo "wrong option"
            Change_source
            ;;    
    esac

    apt update -y
    echo ""
    echo "========================="
    echo "sources changed success !"
    echo "========================="

    if [[ $INTERACTIVE -eq 1 ]]; then
        Interactive
    fi
}

# =================================
# ======= recover sources ========= 
# =================================

function Recover_source() {
    [[ -e /etc/apt/sources.list_bak ]] && mv -f /etc/apt/sources.list_bak /etc/apt/sources.list
    
    [[ -e /etc/apt/sources.list.d/pve-enterprise.list_bak ]] && mv -f /etc/apt/sources.list.d/pve-enterprise.list_bak /etc/apt/sources.list.d/pve-enterprise.list

    [[ -e /usr/share/perl5/PVE/APLInfo.pm_back ]] && mv -f /usr/share/perl5/PVE/APLInfo.pm_back /usr/share/perl5/PVE/APLInfo.pm

    [[ -e /etc/apt/sources.list.d/ceph.list_bak ]] && mv -f /etc/apt/sources.list.d/ceph.list_bak /etc/apt/sources.list.d/ceph.list

    [[ -e /usr/share/perl5/PVE/CLI/pveceph.pm_bak ]] && mv -f /usr/share/perl5/PVE/CLI/pveceph.pm_bak /usr/share/perl5/PVE/CLI/pveceph.pm

    [[ -e /etc/apt/sources.list.d/ceph.list ]] && rm -rf /etc/apt/sources.list.d/ceph.list

    apt update -y

    if [[ $INTERACTIVE -eq 1 ]]; then
        Interactive
    fi
}

# =================================
# ==== Add_subscription_info ======
# =================================

function Add_subscription_info() {

    # [[ -e /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js_info_bak ]] && mv -f /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js_info_bak /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
    cp -af /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js_info_bak

    sed -Ezi "s/void\(\{ \/\/Ext.Msg.show\(\{/Ext.Msg.show\(\{/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js

    clear
    [[ $LANGUAGE == 'zh' ]] && echo "添加成功" || echo "add success"
    echo ""


    if [[ $INTERACTIVE -eq 1 ]]; then
        Interactive
    fi
}

# =================================
# == Delete_subscription_info =====
# =================================

function Delete_subscription_info() {

    cp -af /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js_info_bak

    sed -Ezi "s/(Ext.Msg.show\(\{\s+title: gettext\('No valid sub)/void\(\{ \/\/\1/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js

    clear
    [[ $LANGUAGE == 'zh' ]] && echo "删除成功" || echo "delete success"
    echo ""

    if [[ $INTERACTIVE -eq 1 ]]; then
        Interactive
    fi
}


# =================================
# == Rdm_passthrough_disk =====
# =================================

function Add_grub_passthrough_args() {

    # CHECK BIOS
    local kvm_intel=`lsmod | grep kvm_intel`
    local kvm_amd=`lsmod | grep kvm_amd`
    if [[ $kvm_intel == '' && $kvm_amd == '' ]];then
        [[ $LANGUAGE == 'zh' ]] && echo "请在BIOS中开启AMD-V或VT-X" || echo "please enable AMD-V or VT-X in BIOS"
        exit 1
    fi

    local iommu_group=
    if compgen -G "/sys/kernel/iommu_groups/*/devices/*" > /dev/null; then
        echo ""
    else
        [[ $LANGUAGE == 'zh' ]] && echo "请在BIOS中开启AMD IOMMU或VT-D" || echo "please enable AMD's IOMMU or Intel's VT-D in BIOS"
        exit 1
    fi

    # check if iommu on
    local c=`dmesg | grep -e DMAR -e IOMMU -e AMD-Vi | grep -i -e "Enabled IRQ remapping" -e "Directed I/O"`
    local if_update_grub=0
    local if_reboot=0
    
    if [[ ${c} == '' ]];then    
        local d=`cat /proc/cpuinfo | grep -i "intel"`
        echo "add IOMMU in grub.cfg"
        [[ $d != '' ]] && sed -i 's|quiet|quiet intel_iommu=on video=efifb:off,vesafb:off pcie_acs_override=downstream|' /etc/default/grub
        [[ $d == '' ]] && sed -i 's|quiet|quiet amd_iommu=on video=efifb:off,vesafb:off pcie_acs_override=downstream|' /etc/default/grub
        if_reboot=1
    fi 

    # check /etc/modules
    cp -af /etc/modules /etc/modules_bak
    # sed -Ei 's/vfio|vfio_iommu_type1|vfio_pci|vfio_virqfd//g' /etc/modules
    # sed -i '/^$/d' /etc/modules
    if [[ `cat /etc/modules | grep '^vfio$'` ]];then
        echo "vfio loaded" > /dev/null
    else
        echo "vfio" >> /etc/modules
        modprobe vfio
        if_update_grub=1
    fi

    if [[ `cat /etc/modules | grep '^vfio_iommu_type1$'` ]];then
        echo "vfio_iommu_type1 loaded" > /dev/null
    else
        echo "vfio_iommu_type1" >> /etc/modules
        modprobe vfio_iommu_type1
        if_update_grub=1
    fi
   
    if [[ `cat /etc/modules | grep '^vfio_pci$'` ]];then
        echo "vfio_pci loaded" > /dev/null
    else
        echo "vfio_pci" >> /etc/modules
        modprobe vfio_pci
        if_update_grub=1
    fi

    if [[ `cat /etc/modules | grep '^vfio_virqfd$'` ]];then
        echo "vfio_virqfd loaded" > /dev/null
    else
        echo "vfio_virqfd" >> /etc/modules
        modprobe vfio_virqfd
        if_update_grub=1
    fi

    if [[ ${if_update_grub} -eq 1 ]];then
        echo "update grub"
        update-grub
        update-initramfs -u -k all
    fi
    
    [[ ${if_reboot} -eq 1 ]] && reboot || echo "" 
}


# =================================
# ===== Rdm_passthrough_disk ======
# =================================

function Rdm_passthrough_disk() {

    Add_grub_passthrough_args

    local vmid=''
    local disk_serial=''
    qm list

    echo ""
    
    # set vmid
    while true
    do
        [[ $LANGUAGE == 'zh' ]] && read -p "输入VMID: " vmid|| read -p "Enter VMID: " vmid
        [[ `echo ${vmid} | sed -n '/^[0-9][0-9]*$/p'` ]] && break
    done
    
    # check vmid
    # ls /etc/pve/qemu-server | grep -q "${vmid}.conf"
    vms=`ls /etc/pve/qemu-server | sed -n "/"${vmid}.conf"/p"`
    if [[ ${vms} == '' ]]; then
        [[ $LANGUAGE == 'zh' ]] && echo "vmid: ${vmid} 不存在 !" || echo "vmid: ${vmid} not exists !"
        sleep 2
        return
    fi

    if [[ `qm status ${vmid} | grep 'stop'` == '' ]]; then
        [[ $LANGUAGE == 'zh' ]] && echo "请先关闭虚拟机 ${vmid}" || echo "please stop vm ${vmid}"
        return 
    fi

    echo ""

    [[ $LANGUAGE == 'zh' ]] && echo "硬盘列表：" || echo "Disk List："


    # set disk serial
    local disk_list=()
    disk_list[0]="ID:Device:Capacity:Modal:Serial"
    local disk_ids=`ls -al /dev/disk/by-id | grep "^l" | sed -E 's/\s+/:/g' | cut -d ':' -f 10,12 | grep -vE "^dm|^lvm|^wwn|-part[0-9]+"`
    local idx=1
    # get disk for show seperated by : 
    for item in ${disk_ids};do
        disk=()
        disk[0]=${idx}
        disk[1]=`echo ${item} | sed 's|.*/||'`
        disk[2]=`smartctl -a /dev/${disk[1]} | grep -iE 'Total NVM Capacity|User Capacity' | sed -E 's/.*\[(.*)\].*/\1/'`
        disk[3]=`smartctl -a /dev/${disk[1]} | grep -iE 'Model Number|Device Model' | sed -E 's/^.*:\s*//'`
        disk[4]=`echo ${item} | sed 's/:.*$//'`
        disk_list[${idx}]=`echo "${disk[0]}:${disk[1]}:${disk[2]}:${disk[3]}:${disk[4]}" | sed -E 's/\s+/_/g'`
        idx=$[idx+1]
    done

    # show disk list
    for item in ${disk_list[@]};do
        s=`echo ${item} | sed 's/:/\t/g'`
        echo -e "${s}"
    done

    idx=''
    while true
    do
        [[ $LANGUAGE == 'zh' ]] && read -p "请输入直通硬盘的ID: " idx || read -p "Enter Disk ID: " idx
        [[ `echo ${idx} | sed -n '/^[0-9][0-9]*$/p'` ]] && [[ ${idx} -lt ${#disk_list[@]} && ${idx} -gt 0 ]] && break || echo "error index" 
    done

    disk_serial=`echo ${disk_list[${idx}]} | cut -d ':' -f 5`

    local c=`cat "/etc/pve/qemu-server/${vmid}.conf" | sed -n "/${disk_serial}/p"`
    if [[ $c != '' ]]; then
        [[ $LANGUAGE == 'zh' ]] && echo "硬盘已经直通" || echo "disk is already passthrough"
        sleep 1
        return
    fi

    echo ""

    # set port type
    local disk_type=2
    local max_number=0
    echo "passthrough type list:"
    echo "[1] ide"
    echo "[2] sata"
    echo "[3] scsi"
    echo "[4] virtio"
    while true
    do
        [[ $LANGUAGE == 'zh' ]] && read -p "输入直通类型[默认 2]: " disk_type || read -p "Enter passthrough type[default 2]: " disk_type
        [[ `echo ${disk_type} | sed -n '/^[0-9][0-9]*$/p'` ]] && [[ ${disk_type} -ge 1 && ${disk_type} -le 4 ]] && break || echo "bad arg !"
    done
    

    case ${disk_type} in
        1)
            disk_type='ide'
            max_number=3
            ;;
        2)
            disk_type='sata'
            max_number=5
            ;;
        3)
            disk_type='scsi'
            max_number=30
            ;;
        4)
            disk_type='virtio'
            max_number=15
            ;;
        *)
            disk_type='sata'
            max_number=5
            ;;
    esac

    local disk_type_num=''
    for ((i=0; i<=${max_number}; i++));do
        # cat "/etc/pve/qemu-server/${vmid}.conf" | grep -qE "^${disk_type}${i}"
        local r=`cat "/etc/pve/qemu-server/${vmid}.conf" | sed -n "/^${disk_type}${i}:/p"`
        if [[ $r == '' ]]; then
            disk_type_num="${disk_type}${i}"
            break
        fi
    done

    if [[ $disk_type_num == '' ]]; then
        [[ $LANGUAGE == 'zh' ]] && echo "${disk_type} 端口已用尽" || echo "no more port for ${disk_type}"
        sleep 1
        return 
    fi

    echo "command: qm set ${vmid} --${disk_type_num} /dev/disk/by-id/${disk_serial}"
    sleep 1
    qm set ${vmid} --${disk_type_num} /dev/disk/by-id/${disk_serial}


    if [[ $INTERACTIVE -eq 1 ]]; then
        Interactive
    fi
}


# =================================
# == Passthrough_network_port =====
# =================================

function Passthrough_network_port() {

    Add_grub_passthrough_args

    echo ""
    qm list
    echo ""
    
    # set vmid
    while true
    do
        [[ $LANGUAGE == 'zh' ]] && read -p "输入VMID: " vmid|| read -p "Enter VMID: " vmid
        [[ `echo ${vmid} | sed -n '/^[0-9][0-9]*$/p'` ]] && break
    done
    
    # check vmid
    # ls /etc/pve/qemu-server | grep -q "${vmid}.conf"
    vms=`ls /etc/pve/qemu-server | sed -n "/"${vmid}.conf"/p"`
    if [[ ${vms} == '' ]]; then
        [[ $LANGUAGE == 'zh' ]] && echo "vmid: ${vmid} 不存在 !" || echo "vmid: ${vmid} not exists !"
        sleep 2
        return
    fi

    if [[ `qm status ${vmid} | grep 'stop'` == '' ]]; then
        [[ $LANGUAGE == 'zh' ]] && echo "请先关闭虚拟机 ${vmid}" || echo "please stop vm ${vmid}"
        return 
    fi

    # set network port
    local lspci_ethernet=`lspci | grep -i 'ethernet'`
    local network_port_idx=''
    # show network port
    local lspci_ethernet_show=`echo "${lspci_ethernet}" | sed -E 's/( Ether)/\t\1/' | sed '=' | sed 'N; s/\n/\t/'`
    echo ""
    echo -e "ID\tPCIE_ID\tMODAL"
    echo "${lspci_ethernet_show}"

    while true
    do
        [[ $LANGUAGE == 'zh' ]] && read -p "直通的网口ID: " network_port_idx || read -p "Enter network port ID: " network_port_idx
        [[ `echo ${network_port_idx} | sed -n '/^[0-9][0-9]*$/p'` ]] && break
    done

    local pci_id=`echo "${lspci_ethernet}" | head -n ${network_port_idx} | tail -n -1 | awk -F ' ' '{print $1}'`

    if [[ `cat "/etc/pve/qemu-server/${vmid}.conf" | grep -i "${pci_id}"` != '' ]]; then
        [[ $LANGUAGE == 'zh' ]] && echo "网口已直通" || echo "this port is already passthrough"
        return
    fi

    # set hostpci num
    local num=0
    while true
    do

        local c=`cat "/etc/pve/qemu-server/${vmid}.conf" | grep -i "hostpci${num}"`
        if [[ ${c} == '' ]];then
            break
        fi
        num=$[num+1]
        if [[ ${num} -ge 20 ]]; then
            echo "too many net ports"
            return
        fi
    done

    echo "qm set ${vmid} -hostpci${num} ${pci_id}"

    qm set ${vmid} -hostpci${num} ${pci_id}

    if [[ $INTERACTIVE -eq 1 ]]; then
        Interactive
    fi
}

Main