#!/bin/bash

# 服务器信息
SERVER_IP="120.48.169.183"
SERVER_USER="root"
SERVER_DIR="/var/www/comfyui"

# 本地构建目录
LOCAL_DIR="."

# 密钥文件路径
KEY_FILE=".trae/sometab-k-hp6LQQ1N.txt"

# 创建服务器目录
ssh -i "$KEY_FILE" "$SERVER_USER@$SERVER_IP" "mkdir -p $SERVER_DIR"

# 上传文件
scp -i "$KEY_FILE" -r "$LOCAL_DIR/index.html" "$SERVER_USER@$SERVER_IP:$SERVER_DIR/"

echo "部署完成！"
echo "网站地址: http://$SERVER_IP"
echo "HTTPS地址: https://$SERVER_IP"
