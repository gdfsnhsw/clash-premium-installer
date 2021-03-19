# Clash Premiun Installer

Simple clash premiun core installer with full tun support for Linux. （来源：https://github.com/Kr328/clash-premium-installer ）



### Usage

1. Install dependencies **git**, **nftables**, **iproute2**

2. Clone repository

   ```bash
   git clone https://github.com/xuhuanxxx/clash-premium-installer
   ```

3. Download clash core [link](https://github.com/Dreamacro/clash/releases/tag/premium)

   ```bash
   curl -o clash-premium.gz https://github.com/Dreamacro/clash/releases/download/premium/clash-linux-amd64-2021.03.10.gz && gzip -d clash-premium.gz && mv clash-premium clash-premium-installer/clash
   ```

4. Run Installer

   ```bash
   # install 
   ./installer.sh install
   
   # uninstall 
   ./installer.sh uninstall
   ```
4. Dashboard

   ```bash
   curl -o ui.zip https://github.com/Dreamacro/clash-dashboard/archive/gh-pages.zip && unzip ui.zip && mv clash-dashboard-gh-pages /srv/clash/ui
   ```
