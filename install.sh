#!/bin/bash
set -ex

if [ -f /etc/os-release ]; then
    OS_ID=$(grep "^ID=" /etc/os-release | cut -d'=' -f2 | tr -d '"')

    if [ "$OS_ID" == "ubuntu" ]; then
        sudo apt-get install earlyoom
    elif [ "$OS_ID" == "centos" ]; then
        sudo yum install earlyoom -y
    else
        echo "current OS is not supported：$OS_ID"
    fi
else
    echo "can not check OS，/etc/os-release does not exists."
fi



ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then
    if [ "$OS_ID" == "ubuntu" ]; then
        PKG=earlyoom-amd64
    elif [ "$OS_ID" == "centos" ]; then
        PKG=earlyoom-centos
    else
        echo "current OS is not supported：$OS_ID"
    fi
elif [ "$ARCH" = "aarch64" ]; then
    PKG=earlyoom-aarch64
else
    echo "current arch is not supported: $ARCH"
    exit 1
fi

sudo curl -o /opt/starrocks-init/earlyoom "https://raw.githubusercontent.com/CelerData/earlyoom-install/main/pkg/$PKG"
sudo curl -o /opt/starrocks-init/jmap.sh "https://raw.githubusercontent.com/CelerData/earlyoom-install/main/jmap.sh"
sudo mv /opt/starrocks-init/earlyoom /usr/bin/earlyoom
sudo chmod a+x /usr/bin/earlyoom
sudo sed -i 's/^EARLYOOM_ARGS=.*$/EARLYOOM_ARGS="-M 512000 -m 5 -r 600 --ignore-root-user --prefer '\''(^|\/)(starrocks_be|java|agent-service)$'\'' --prefer-only -N \/opt\/starrocks-init\/jmap.sh"/' /etc/default/earlyoom
sudo sed -i '/^DynamicUser=/s/^/#/' /lib/systemd/system/earlyoom.service
sudo sed -i '/^TasksMax=/s/^/#/' /lib/systemd/system/earlyoom.service
sudo sed -i '/^MemoryMax=/s/^/#/' /lib/systemd/system/earlyoom.service
sudo sed -i '/\[Install\]/i ReadWritePaths=\/tmp' /lib/systemd/system/earlyoom.service
sudo chmod a+x /opt/starrocks-init/jmap.sh

sudo systemctl enable --now earlyoom