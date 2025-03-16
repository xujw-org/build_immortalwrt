# ImmortalWrt 自定义编译

本仓库包含了自定义编译 ImmortalWrt 的 GitHub Actions 工作流及配置脚本，可以方便地编译带有常用功能和第三方软件包的 ImmortalWrt 固件。

## 功能特点

- 通过 GitHub Actions 自动化编译
- 支持 SSH 连接 Actions 进行配置修改
- 添加多个常用第三方软件包仓库
- 自定义网络设置（主机名、IP地址、子网掩码、网关、DNS等）
- 免密登录设置
- ttyd 终端免密登录
- 常用软件包预配置（PassWall、SSR-Plus、OpenClash等）
- 多种主题支持（Argon、Material、Netgear）
- IPv6 支持
- USB 支持和文件系统支持

## 目录结构

```
.
├── .github
│   └── workflows
│       └── build-immortalwrt.yml    # GitHub Actions 工作流配置
├── config
│   └── config.seed                  # 可选的默认配置文件
├── scripts
│   ├── custom-immortalwrt.sh        # 交互式配置脚本
│   └── github-actions-custom-config.sh  # GitHub Actions 自动配置脚本
└── README.md                        # 本说明文件
```

## 使用方法

### 方法一：使用 GitHub Actions 在线编译

1. Fork 本仓库
2. 设置 GitHub Secrets：
   - `REPO_TOKEN`: 具有仓库访问权限的个人访问令牌
   - （可选）`TELEGRAM_CHAT_ID` 和 `TELEGRAM_BOT_TOKEN`: 用于 SSH 连接通知
3. 在 Actions 页面手动触发工作流：
   - 可选择是否启用 SSH 连接
   - 可选择使用哪个配置文件

### 方法二：本地交互式配置和编译

1. 克隆 ImmortalWrt 仓库
   ```bash
   git clone https://github.com/immortalwrt/immortalwrt.git
   cd immortalwrt
   ```

2. 下载并运行配置脚本
   ```bash
   wget -O custom-script.sh https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/scripts/custom-immortalwrt.sh
   chmod +x custom-script.sh
   ./custom-script.sh
   ```

3. 编译固件
   ```bash
   make -j$(nproc)
   ```

## 预置软件包

本项目预置了以下常用软件包：

### 网络应用
- PassWall / PassWall2
- SSR-Plus
- OpenClash
- AdGuard Home
- UnblockMusic
- SmartDNS
- ZeroTier
- DDNS
- UPnP
- WOL (Wake on LAN)

### 系统工具
- ttyd (终端访问)
- 文件传输
- 网络监控
- Web管理
- Docker

### 主题
- Argon (默认)
- Material
- Netgear

### 网络支持
- IPv6 助手
- 多WAN口支持
- 负载均衡

## 配置指南

### 网络配置

默认网络配置：
- IP地址: 192.168.1.1
- 子网掩码: 255.255.255.0
- 网关: 192.168.1.1
- DNS: 223.5.5.5 223.6.6.6
- DHCP: 开启
- IPv6: 开启

### 自定义设置

1. 修改 `scripts/github-actions-custom-config.sh` 中的变量来自定义自动编译的设置
2. 或使用交互式脚本 `scripts/custom-immortalwrt.sh` 进行配置

### SSH 连接使用说明

在 GitHub Actions 中启用 SSH 连接后：
1. 等待工作流程执行到 SSH 连接步骤
2. 使用提供的 SSH 命令连接到 Actions 环境
3. 连接后可以修改配置、调试问题等
4. 退出 SSH 后，工作流程将继续执行

## 注意事项

- 编译过程可能需要较长时间（1-2小时）
- 确保 GitHub Actions 有足够的空间和时间完成编译
- 如遇到编译错误，可以尝试启用 SSH 调试
- 本项目仅供学习和研究使用，请遵守相关法律法规
