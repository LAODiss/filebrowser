#!/bin/bash
#=================================================
# FileBrowser 一键安装与配置脚本 (国内加速版)
# 使用 GitHub 国内镜像源代理下载，解决网络阻断问题
#=================================================

# 定义颜色
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

# 1. 检查 root 权限
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}错误：请使用 root 权限运行此脚本 (例如: sudo bash $0)${RESET}"
  exit 1
fi

echo -e "${GREEN}>>> 正在检查并安装必要依赖 (curl, tar)...${RESET}"
for pkg in curl tar; do
  if ! command -v $pkg >/dev/null 2>&1; then
      if command -v apt >/dev/null 2>&1; then apt update && apt install -y $pkg
      elif command -v yum >/dev/null 2>&1; then yum install -y $pkg
      else echo -e "${RED}无法自动安装 $pkg，请手动安装后重试。${RESET}"; exit 1; fi
  fi
done

# 2. 识别系统架构
ARCH=$(uname -m)
case $ARCH in
    x86_64)  FB_ARCH="amd64" ;;
    aarch64) FB_ARCH="arm64" ;;
    armv7l)  FB_ARCH="armv7" ;;
    *) echo -e "${RED}未知的系统架构: $ARCH，脚本退出。${RESET}"; exit 1 ;;
esac

# 3. 通过国内加速节点下载官方二进制包
# 这里使用 ghproxy.cn 作为加速前缀，如果你有其他偏好的镜像源，可直接修改下方变量
GH_PROXY="https://v4.gh-proxy.org/" 
DOWNLOAD_URL="${GH_PROXY}https://github.com/filebrowser/filebrowser/releases/latest/download/linux-${FB_ARCH}-filebrowser.tar.gz"

echo -e "${GREEN}>>> 正在通过国内加速节点拉取 FileBrowser (架构: $FB_ARCH)...${RESET}"
if ! curl -fsSL "$DOWNLOAD_URL" -o filebrowser.tar.gz; then
    echo -e "${RED}错误：下载失败，请检查网络连接或更换代理节点前缀。${RESET}"
    exit 1
fi

echo -e "${GREEN}>>> 解压并安装二进制文件...${RESET}"
tar -zxvf filebrowser.tar.gz filebrowser
mv filebrowser /usr/local/bin/
chmod +x /usr/local/bin/filebrowser
rm -f filebrowser.tar.gz

# 4. 定义关键目录及变量
FB_DIR="/etc/filebrowser"
DATA_DIR="/var/filebrowser_data"
DB_FILE="$FB_DIR/filebrowser.db"
LOG_FILE="$FB_DIR/filebrowser.log"
PORT=8080

echo -e "${GREEN}>>> 初始化文件目录与配置文件...${RESET}"
mkdir -p "$FB_DIR"
mkdir -p "$DATA_DIR"

# 备份可能存在的旧数据库
[ -f "$DB_FILE" ] && mv "$DB_FILE" "$DB_FILE.bak.$(date +%s)"

# 5. 初始化配置与数据库
filebrowser config init -d "$DB_FILE" >/dev/null
filebrowser config set -a 0.0.0.0 -p "$PORT" -r "$DATA_DIR" -l "$LOG_FILE" -d "$DB_FILE" >/dev/null

# 6. 添加默认管理员账户 (admin/admin)
echo -e "${GREEN}>>> 配置默认管理员账户...${RESET}"
filebrowser users add admin admin12345678 --perm.admin -d "$DB_FILE" >/dev/null

# 7. 配置 Systemd 守护进程
echo -e "${GREEN}>>> 配置 Systemd 开机自启服务...${RESET}"
cat > /etc/systemd/system/filebrowser.service <<EOF
[Unit]
Description=FileBrowser Service
After=network.target

[Service]
ExecStart=/usr/local/bin/filebrowser -d $DB_FILE
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# 8. 启动服务并放行防火墙 (尝试放行，非强制)
systemctl daemon-reload
systemctl enable filebrowser --now

if command -v ufw >/dev/null 2>&1; then ufw allow $PORT/tcp >/dev/null 2>&1; fi
if command -v firewall-cmd >/dev/null 2>&1; then firewall-cmd --zone=public --add-port=$PORT/tcp --permanent >/dev/null 2>&1 && firewall-cmd --reload >/dev/null 2>&1; fi

# 获取服务器 IP
IP=$(curl -s ifconfig.me || ip route get 1.2.3.4 | awk '{print $7}' | head -n 1)

# 9. 打印结果
echo -e "\n${YELLOW}======================================================${RESET}"
echo -e "${GREEN}  FileBrowser 加速版安装完毕并已在后台稳定运行！${RESET}"
echo -e "${YELLOW}======================================================${RESET}"
echo -e "访问地址:     ${GREEN}http://$IP:$PORT${RESET}"
echo -e "默认账号:     ${GREEN}admin${RESET}"
echo -e "默认密码:     ${GREEN}admin${RESET}"
echo -e "网盘根目录:   ${GREEN}$DATA_DIR${RESET}"
echo -e "配置文件路径: ${GREEN}$DB_FILE${RESET}"
echo -e "${YELLOW}======================================================${RESET}"
echo -e "${RED}安全提示: 请务必登录系统前往【设置】修改默认密码！${RESET}"
echo -e "${YELLOW}======================================================${RESET}"
