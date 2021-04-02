# Clash Premiun Installer

Simple clash premiun core installer with full tun support for Linux.

## Usage

1. Install dependencies **git**, **nftables**, **iproute2**

2. Clone repository

   ```bash
   git clone https://github.com/xuhuanxxx/clash-premium-installer clash-install
   ```

3. Download clash core [link](https://github.com/Dreamacro/clash/releases/tag/premium)

   ```bash
   wget -O clash-premium.gz https://github.com/Dreamacro/clash/releases/download/premium/clash-linux-amd64-2021.03.10.gz && gzip -d clash-premium.gz && mv clash-premium clash-install/clash
   ```

   or

   ```bash
   curl -L -o clash-premium.gz https://github.com/Dreamacro/clash/releases/download/premium/clash-linux-amd64-2021.03.10.gz && gzip -d clash-premium.gz && mv clash-premium clash-install/clash
   ```

4. Run Installer

   ```bash
   cd clash-install
   chmod +x install.sh

   # install

   ./install.sh tun           # transfer TCP and UDP to utun device
   ./install.sh tproxy        # TProxy TCP and TProxy UDP
   ./install.sh tproxy-tun    # TProxy TCP and transfer UDP to utun device(not work, need help)
   ./install.sh redir-tun     # Redirect TCP and transfer UDP to utun device

   # uninstall

   ./install.sh uninstall
   ```

5. Dashboard

   ```bash
   wget -O ui.zip https://github.com/Dreamacro/clash-dashboard/archive/gh-pages.zip && unzip ui.zip && mv clash-dashboard-gh-pages /etc/clash/ui
   ```

   or

   ```bash
   curl -L -o ui.zip https://github.com/Dreamacro/clash-dashboard/archive/gh-pages.zip && unzip ui.zip && mv clash-dashboard-gh-pages /etc/clash/ui
   ```

## Credits

* [Kr328/clash-premium-installer](https://github.com/Kr328/clash-premium-installer)
* [yangliu/alpine-clash-gateway](https://github.com/yangliu/alpine-clash-gateway)
