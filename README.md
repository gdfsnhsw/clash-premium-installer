# Clash Premiun Installer

Simple clash premiun core installer with full tun support for Linux.

## Usage

1. Install dependencies **git**, **nftables**, **iproute2**, **jq**, [**yq**](https://github.com/mikefarah/yq/ "https://github.com/mikefarah/yq/")

2. Clone repository

   ```bash
   git clone https://github.com/xuhuanxxx/clash-premium-installer clash-install
   ```

3. Run Installer

   ```bash
   cd clash-install

   # core
   ./run.sh dl            # Download latest clash premium & dashboard
   ./run.sh dl_proxy      # Download latest clash premium & dashboard with proxy

   # install
   ./run.sh tun           # Transfer TCP and UDP to utun device
   ./run.sh tproxy        # TProxy TCP and TProxy UDP
   ./run.sh tproxy-tun    # TProxy TCP and transfer UDP to utun device(not work, need help)
   ./run.sh redir-tun     # Redirect TCP and transfer UDP to utun device

   # uninstall
   ./run.sh uninstall
   ```

## Credits

* [Kr328/clash-premium-installer](https://github.com/Kr328/clash-premium-installer)
* [yangliu/alpine-clash-gateway](https://github.com/yangliu/alpine-clash-gateway)
