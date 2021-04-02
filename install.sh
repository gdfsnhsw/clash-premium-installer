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

function _install() {
    assert_command install
    assert_command nft
    assert_command ip

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
    
    assert install -m 0644 scripts/clash-default /etc/default/clash

    assert install -m 0755 scripts/bypass-proxy-pid /bin/bypass-proxy-pid
    assert install -m 0755 scripts/bypass-proxy /bin/bypass-proxy

    assert install -m 0700 scripts/cgroup.sh /lib/clash/cgroup.sh

    assert install -m 0700 scripts/$1.sh /lib/clash/rules.sh

    assert install -m 0644 scripts/clash.service /etc/systemd/system/clash.service
    assert install -m 0644 scripts/99-clash.rules /etc/udev/rules.d/99-clash.rules

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

    . /lib/clash/rules.sh clean
    systemctl stop clash
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
    echo "Usage: ./install.sh [option]"
    echo ""
    echo "Options:"
    echo "  tun         - transfer TCP and UDP to utun device"
    echo "  tproxy      - TProxy TCP and TProxy UDP"
    echo "  tproxy-tun  - TProxy TCP and transfer UDP to utun device(not work)"
    echo "  redir-tun   - Redirect TCP and transfer UDP to utun device"
    echo "  uninstall   - uninstall installed clash premiun core"
    echo ""

    exit 0
}

function _debug() {
    assert_command touch
    echo "Clash Premiun Installer"
    echo "$1 is $1"
    touch $1-123.sh
    exit 0
}

case "$1" in
"tun") _install $1;;
"tproxy") _install $1;;
"tproxy-tun") _install $1;;
"redir-tun") _install $1;;
"uninstall") _uninstall $1;;
"debug") _debug $1;;
*) _help;
esac
