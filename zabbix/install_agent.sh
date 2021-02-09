#!/bin/bash
ZBX_SRV="dollar"
HOST=`hostname`
# install zabbix-server
sudo apt update && sudo apt install -y zabbix-agent
# rewrite config
sudo sed -e "s/Server=127.0.0.1/Server=$ZBX_SRV/g" -e "s/ServerActive=127.0.0.1/ServerActive=$ZBX_SRV/g" -e "s/^Hostname=.*?/Hostname=${HOST}/g" zabbix/zabbix_agentd.conf.master > /etc/zabbix/zabbix_agentd.conf
sudo systemctl enable zabbix-agent.service
# setup for GPU
if [ -e /proc/driver/nvidia/version ] ; then
    if [ ! -d zabbix-nvidia-smi-multi-gpu ] ; then
        git clone https://github.com/plambe/zabbix-nvidia-smi-multi-gpu.git
    fi
    sudo cat zabbix-nvidia-smi-multi-gpu/userparameter_nvidia-smi.conf.linux >> /etc/zabbix/zabbix_agentd.conf
    if [ ! -d /etc/zabbix/scripts ] ; then
        sudo mkdir /etc/zabbix/scripts
    fi
    sudo cp zabbix-nvidia-smi-multi-gpu/get_gpus_info.sh /etc/zabbix/scripts/
    sudo chmod +x /etc/zabbix/scripts/get_gpus_info.sh
fi
sudo systemctl restart zabbix-agent.service