#!/bin/bash
#
# GitHub Actions自动配置脚本
# 此脚本在GitHub Actions中自动应用自定义配置
#

# 错误时退出
set -e

# 颜色定义
GREEN='\033[0;32m'
PLAIN='\033[0m'

# 打印信息
print_info() {
    echo -e "${GREEN}[信息]${PLAIN} $1"
}

# 主机名和网络配置
HOSTNAME="ImmortalWrt"
IP_ADDR="192.168.1.1"
NETMASK="255.255.255.0"
GATEWAY="192.168.1.1"
DNS="223.5.5.5 223.6.6.6"
ENABLE_DHCP="y"
ENABLE_IPV6="y"

# 添加第三方软件包仓库
add_package_feeds() {
    print_info "添加第三方软件包仓库..."
    
    # 备份原始feeds.conf.default
    cp feeds.conf.default feeds.conf.default.backup
    
    # 添加常用的第三方仓库
    cat >> feeds.conf.default <<EOF
# 第三方软件包
src-git lienol https://github.com/Lienol/openwrt-package.git;master
src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main
src-git passwallpackages https://github.com/xiaorouji/openwrt-passwall-packages.git;main
src-git helloworld https://github.com/fw876/helloworld.git
src-git openclash https://github.com/vernesong/OpenClash.git
src-git luci-theme-argon https://github.com/jerrykuku/luci-theme-argon.git
src-git luci-app-argon-config https://github.com/jerrykuku/luci-app-argon-config.git
EOF
    
    print_info "更新软件包列表..."
    ./scripts/feeds update -a
    ./scripts/feeds install -a
}

# 配置基本系统
configure_system() {
    print_info "配置基本系统..."
    
    # 创建目录
    mkdir -p files/etc/config/
    
    # 配置主机名
    cat > files/etc/config/system <<EOF
config system
	option hostname '$HOSTNAME'
	option timezone 'CST-8'
	option zonename 'Asia/Shanghai'
EOF
    
    # 配置网络
    cat > files/etc/config/network <<EOF
config interface 'loopback'
	option ifname 'lo'
	option proto 'static'
	option ipaddr '127.0.0.1'
	option netmask '255.0.0.0'

config interface 'lan'
	option type 'bridge'
	option ifname 'eth0'
	option proto 'static'
	option ipaddr '$IP_ADDR'
	option netmask '$NETMASK'
	option gateway '$GATEWAY'
	option dns '$DNS'
	option broadcast '${IP_ADDR%.*}.255'
EOF
    
    # 配置DHCP
    if [[ "$ENABLE_DHCP" == "y" ]]; then
        cat > files/etc/config/dhcp <<EOF
config dnsmasq
	option domainneeded '1'
	option boguspriv '1'
	option filterwin2k '0'
	option localise_queries '1'
	option rebind_protection '1'
	option rebind_localhost '1'
	option local '/lan/'
	option domain 'lan'
	option expandhosts '1'
	option nonegcache '0'
	option authoritative '1'
	option readethers '1'
	option leasefile '/tmp/dhcp.leases'
	option resolvfile '/tmp/resolv.conf.auto'
	option nonwildcard '1'
	option localservice '1'
	option noresolv '0'

config dhcp 'lan'
	option interface 'lan'
	option start '100'
	option limit '150'
	option leasetime '12h'
	option dhcpv6 'server'
	option ra 'server'
	option ra_management '1'
EOF
    fi
    
    # 配置IPv6
    if [[ "$ENABLE_IPV6" == "y" ]]; then
        cat >> files/etc/config/network <<EOF

config interface 'wan6'
	option ifname '@wan'
	option proto 'dhcpv6'
EOF
    fi
}

# 创建首次免密登录配置
configure_passwordless_login() {
    print_info "配置首次免密登录..."
    
    mkdir -p files/etc/uci-defaults/
    
    # 创建uci-defaults脚本
    cat > files/etc/uci-defaults/99-passwordless <<EOF
#!/bin/sh

# 设置首次免密登录
uci set rpcd.@login[0].username='root'
uci set rpcd.@login[0].password='lWSJlBq'  # 随机密码，会在运行后首次使用RPCs被重置
uci commit rpcd

# 设置ttyd免密登录
uci set ttyd.@ttyd[0].command='/bin/login'
uci set ttyd.@ttyd[0].interface='@lan'
uci commit ttyd

exit 0
EOF
    
    chmod +x files/etc/uci-defaults/99-passwordless
}

# 应用常用配置到.config文件
apply_common_configs() {
    print_info "应用常用配置..."
    
    # 确保 .config 存在
    touch .config
    
    # 添加常用配置
    cat >> .config <<EOF
# 使用最新内核版本
CONFIG_LINUX_5_15=y

# 基本系统
CONFIG_PACKAGE_dnsmasq-full=y
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_wget=y
CONFIG_PACKAGE_ip-full=y

# 网络工具
CONFIG_PACKAGE_tcpdump=y
CONFIG_PACKAGE_ipset=y
CONFIG_PACKAGE_iptables-mod-extra=y
CONFIG_PACKAGE_iptables-mod-tproxy=y
CONFIG_PACKAGE_iptables-mod-conntrack-extra=y

# SSH和Web服务
CONFIG_PACKAGE_openssh-sftp-server=y
CONFIG_PACKAGE_luci-ssl=y
CONFIG_PACKAGE_luci-ssl-nginx=y
CONFIG_PACKAGE_nginx=y

# 常用应用
CONFIG_PACKAGE_luci-app-ttyd=y
CONFIG_PACKAGE_luci-app-openclash=y
CONFIG_PACKAGE_luci-app-passwall=y
CONFIG_PACKAGE_luci-app-passwall2=y
CONFIG_PACKAGE_luci-app-ssr-plus=y
CONFIG_PACKAGE_luci-app-filetransfer=y
CONFIG_PACKAGE_luci-app-firewall=y
CONFIG_PACKAGE_luci-app-nlbwmon=y
CONFIG_PACKAGE_luci-app-upnp=y
CONFIG_PACKAGE_luci-app-wol=y
CONFIG_PACKAGE_luci-app-ddns=y
CONFIG_PACKAGE_luci-app-statistics=y
CONFIG_PACKAGE_luci-app-watchcat=y
CONFIG_PACKAGE_luci-app-wifischedule=y
CONFIG_PACKAGE_luci-app-mwan3=y
CONFIG_PACKAGE_luci-app-syncdial=y
CONFIG_PACKAGE_luci-app-webadmin=y

# 主题
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_luci-app-argon-config=y
CONFIG_PACKAGE_luci-theme-material=y
CONFIG_PACKAGE_luci-theme-netgear=y

# 文件系统支持
CONFIG_PACKAGE_kmod-fs-ext4=y
CONFIG_PACKAGE_kmod-fs-ntfs=y
CONFIG_PACKAGE_kmod-fs-exfat=y
CONFIG_PACKAGE_kmod-fs-vfat=y

# USB支持
CONFIG_PACKAGE_kmod-usb-core=y
CONFIG_PACKAGE_kmod-usb-storage=y
CONFIG_PACKAGE_kmod-usb-storage-extras=y
CONFIG_PACKAGE_kmod-usb3=y

# IPv6支持
CONFIG_PACKAGE_ipv6helper=y
CONFIG_PACKAGE_ip6tables=y
CONFIG_PACKAGE_ip6tables-mod-nat=y
CONFIG_PACKAGE_kmod-ip6tables=y
CONFIG_PACKAGE_kmod-ipt-nat6=y
CONFIG_PACKAGE_odhcp6c=y
CONFIG_PACKAGE_odhcpd-ipv6only=y

# 其他
CONFIG_PACKAGE_htop=y
CONFIG_PACKAGE_iperf3=y
CONFIG_PACKAGE_luci-app-adguardhome=y
CONFIG_PACKAGE_luci-app-unblockmusic=y
CONFIG_PACKAGE_luci-app-smartdns=y
CONFIG_PACKAGE_luci-app-zerotier=y
CONFIG_PACKAGE_luci-app-docker=y
EOF
}

# 主函数
main() {
    print_info "ImmortalWrt GitHub Actions自动配置脚本"
    print_info "----------------------------"
    
    add_package_feeds
    configure_system
    configure_passwordless_login
    apply_common_configs
    
    print_info "GitHub Actions自动配置完成！"
}

main "$@"
