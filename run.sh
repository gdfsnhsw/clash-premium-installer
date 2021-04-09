#!/bin/bash

cd "`dirname $0`"

function assert() {
    "$@"

    if [ "$?" != 0 ]; then
        echo "Execute $@ failure"
        exit 1
    fi
}

function assert_command() {
    if ! which "$1" > /dev/null 2>&1;then
        echo "Command $1 not found"
        exit 1
    fi
}

function _download() {
    assert_command curl
    assert_command gzip
    assert_command unzip

    case "$(uname -ms | tr ' ' '_' | tr '[A-Z]' '[a-z]')" in
    "linux_x86_64") 
        AARCH="linux-amd64"
        ;;
    "linux_aarch64")
        AARCH="linux-armv8"
        ;;
    *)
        echo "Not support platform"
        exit 1
        ;;
    esac

    release_info_url="https://api.github.com/repos/Dreamacro/clash/releases/tags/premium"

    if [[ "$1" =~ "proxy" ]]; then
        url_prefix="https://ghproxy.com/"
    else
        url_prefix=""
    fi

    echo "Get Clash Premium release information"
    assert curl -s -o clash_premium_release.json "${release_info_url}"

    if [ ! -f clash_premium_release.json ]; then
        echo "Failed to get Clash Premium release information"
        exit 1
    fi

    clash_premium_download_url=$(jq ".assets[${i}].browser_download_url" clash_premium_release.json | tr -d '"' | grep -m1 ${AARCH})
    if [ "${clash_premium_download_url}" == "" ]; then
        echo "No compatible Clash Premium for your platform"
        exit 1
    fi

    echo "Start download Clash Premium from ${clash_premium_download_url}"
    assert curl -L -# -o clash-premium.gz "${url_prefix}${clash_premium_download_url}"
    if [ ! -f clash-premium.gz ]; then
        echo "Failed to download Clash Premium"
        echo "Please download and upload it to current directory manually"
        exit 1
    fi
    assert gzip -d clash-premium.gz
    assert install clash-premium clash

    clash_dashboard_download_url="https://github.com/Dreamacro/clash-dashboard/archive/gh-pages.zip"
    echo "Start download Clash Dashboard from ${clash_dashboard_download_url}"
    assert curl -L -# -o ui.zip "${url_prefix}${clash_dashboard_download_url}"
    if [ ! -f ui.zip ]; then
        echo "Failed to download Clash Dashboard"
        echo "Please download and upload it to current directory manually"
        exit 1
    fi
    assert unzip ui.zip
    assert install -d clash-dashboard-gh-pages ui

    echo "Clash Premium core & dashboard have been downloaded successfully "
    exit 1
}

function _install() {
    assert_command install
    assert_command nft
    assert_command ip
    assert_command sed
    assert_command systemctl
    assert_command udevadm

    if [ ! -d "/lib/udev/rules.d" ];then
        echo "udev not found"
        exit 1
    fi

    if [ ! -d "/lib/systemd/system" ];then
        echo "systemd not found"
        exit 1
    fi

    if ! grep net_cls "/proc/cgroups" 2> /dev/null > /dev/null ;then
        echo "cgroup not support net_cls"
        exit 1
    fi

    if [ ! -f "./clash" ];then
        echo "Clash core not found."
        echo "Please download it from https://github.com/Dreamacro/clash/releases/tag/premium, and rename to ./clash"
    fi
    
    assert install -d -m 0755 /etc/default/
    assert install -d -m 0755 /lib/clash/
    assert install -d -m 0600 /etc/clash/

    assert install -m 0755 ./clash /bin/clash
    
    assert install -m 0644 files/clash-default /etc/default/clash

    assert install -m 0755 scripts/bypass-proxy-pid /bin/bypass-proxy-pid
    assert install -m 0755 scripts/bypass-proxy /bin/bypass-proxy

    assert install -m 0700 scripts/cgroup.sh /lib/clash/cgroup.sh
    assert install -m 0700 scripts/$1.sh /lib/clash/rules.sh

    assert install -m 0644 files/clash.service /etc/systemd/system/clash.service
    assert install -m 0644 files/99-clash.rules /etc/udev/rules.d/99-clash.rules
    assert install -d -m 0600 ui /etc/clash/ui

    if [ ! -f "/etc/clash/config.yaml" ];then
        assert install -m 0600 files/config.yaml /etc/clash/config.yaml
    fi

    if [[ ! "$1" =~ "tun" ]]; then
        sed -i '/^ExecStart=/a ExecStopPost=\/lib\/clash/rules.sh clean' /etc/systemd/system/clash.service
        sed -i '/^ExecStart=/a ExecStartPost=\/lib\/clash\/rules.sh setup' /etc/systemd/system/clash.service
        systemctl daemon-reload
    fi

    DISTRO_NAME=$(awk '/^ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }')
    if [[ " centos fedora " =~ " ${DISTRO_NAME} " ]]; then
        sed -i 's/RUN+="/RUN+="\/bin\/sudo /g' /etc/udev/rules.d/99-clash.rules
        udevadm control --reload-rules
        udevadm trigger
    fi

    echo "Install successfully"
    echo ""
    echo "Home directory at /etc/clash"
    echo ""
    echo "All dns traffic will be redirected to :1053"
    echo ""
    echo "Use 'systemctl start clash' to start"
    echo "Use 'systemctl enable clash' to enable auto-restart on boot"

    exit 0
}

function _uninstall() {
    assert_command systemctl
    assert_command rm
    assert_command sleep

    systemctl stop clash
    sleep 0.5
    systemctl disable clash
    rm -rf /lib/clash
    rm -rf /etc/systemd/system/clash.service
    rm -rf /etc/udev/rules.d/99-clash.rules
    rm -rf /bin/clash
    rm -rf /bin/bypass-proxy-uid
    rm -rf /bin/bypass-proxy
    rm -rf /etc/default/clash

    echo "Uninstall successfully"

    exit 0
}

function _help() {
    echo "Clash Premiun Installer"
    echo ""
    echo "Usage: ./run.sh [option]"
    echo ""
    echo "Options:"
    echo "  core        - Download latest clash premium"
    echo "  core_proxy  - Download latest clash premium with proxy"
    echo "  tun         - Transfer TCP and UDP to utun device"
    echo "  tproxy      - TProxy TCP and TProxy UDP"
    echo "  tproxy-tun  - TProxy TCP and transfer UDP to utun device(not work)"
    echo "  redir-tun   - Redirect TCP and transfer UDP to utun device"
    echo "  uninstall   - uninstall installed clash premiun core"
    echo ""

    exit 0
}

case "$1" in
"dl") _download $1;;
"dl_proxy") _download $1;;
"tun") _install $1;;
"tproxy") _install $1;;
"tproxy-tun") _install $1;;
"redir-tun") _install $1;;
"uninstall") _uninstall $1;;
*) _help;
esac
