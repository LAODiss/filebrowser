# FileBrowser 一键安装脚本 (国内加速版)

本项目提供了一个适用于 Linux 系统的高效、稳定的 [FileBrowser](https://filebrowser.org/) 一键安装与自动化配置脚本。特别针对中国大陆的网络环境进行了优化，彻底解决了官方脚本因 GitHub 连通性问题导致的安装失败或超时情况。

## ✨ 核心特性

- 🚀 **国内网络加速**：通过镜像节点（`ghproxy`）直接拉取官方二进制包，告别网络阻断。
- 🤖 **全自动化配置**：自动创建运行目录、初始化数据库并设置好基础参数。
- 🛡️ **Systemd 守护**：自动配置 `filebrowser.service`，支持进程崩溃重启与开机自启动。
- ⚙️ **架构自适应**：自动识别 `x86_64` (AMD64) 与 `aarch64` (ARM64) 架构，兼容主流云服务器、树莓派及 NAS 设备。

---

## 🚀 一键安装命令

由于脚本需要创建系统服务和配置文件，**请确保你拥有 root 权限**（或使用 `sudo` 执行）。

### 中国大陆服务器推荐（加速版）：
```bash
curl -fsSL https://v4.gh-proxy.org/https://raw.githubusercontent.com/LAODiss/filebrowser/main/install.sh | sudo bash
```

### 海外服务器备用（官方直连）：
```bash
curl -fsSL https://raw.githubusercontent.com/LAODiss/filebrowser/main/install.sh | sudo bash
```

---

## ⚙️ 安装后默认配置

安装脚本执行成功后，FileBrowser 将自动在后台运行。你可以通过浏览器访问以下信息：

* **访问地址**: `http://<你的服务器IP>:8080`
* **默认账号**: `admin`
* **默认密码**: `admin`
* **网盘根目录**: `/var/filebrowser_data` (存放文件的位置)
* **配置文件与库**: `/etc/filebrowser/filebrowser.db`

> ⚠️ **安全警告**：初次登录后，请务必前往**【设置】** -> **【全局设置】/【用户管理】** 中修改默认管理员密码，以免造成数据泄露！

---

## 🛠️ 常用服务管理命令

本项目已将 FileBrowser 注册为 Systemd 系统服务，你可以使用以下标准命令进行日常管理：

| 功能 | 命令 |
| :--- | :--- |
| **查看运行状态** | `sudo systemctl status filebrowser` |
| **停止服务** | `sudo systemctl stop filebrowser` |
| **重启服务** | `sudo systemctl restart filebrowser` |
| **查看运行日志** | `sudo journalctl -u filebrowser -f` |

---

## 📝 自定义修改说明

如果你需要更改默认端口（8080）或默认网盘目录，可以在安装后使用以下步骤修改：

1. 停止服务：`systemctl stop filebrowser`
2. 修改配置项，例如修改端口为 8888：
   ```bash
   filebrowser config set -p 8888 -d /etc/filebrowser/filebrowser.db
   ```
3. 重启服务：`systemctl start filebrowser`

## 📄 开源协议
MIT License
