# ComfyUI 网站部署指南

## 项目结构

```
.
├── index.html          # 网站首页
├── deploy.sh           # 部署脚本
├── nginx.conf          # Nginx配置文件
└── .trae/
    └── sometab-k-hp6LQQ1N.txt  # 服务器密钥对
```

## 部署步骤

1. **准备工作**
   - 确保本地安装了 Git Bash 或其他支持 bash 脚本的终端
   - 确保服务器已安装 Nginx
   - 确保域名 comfyui.com 已解析到服务器 IP 120.48.169.183

2. **生成 SSL 证书**
   - 在服务器上创建 SSL 证书目录：`mkdir -p /etc/nginx/ssl`
   - 生成自签名证书（或使用真实证书）：
     ```bash
     openssl req -x509 -newkey rsa:4096 -keyout /etc/nginx/ssl/comfyui.com.key -out /etc/nginx/ssl/comfyui.com.crt -days 365 -nodes
     ```

3. **配置 Nginx**
   - 将 `nginx.conf` 文件上传到服务器：
     ```bash
     scp -i .trae/sometab-k-hp6LQQ1N.txt nginx.conf root@120.48.169.183:/etc/nginx/sites-available/comfyui.com
     ```
   - 创建符号链接：
     ```bash
     ssh -i .trae/sometab-k-hp6LQQ1N.txt root@120.48.169.183 "ln -s /etc/nginx/sites-available/comfyui.com /etc/nginx/sites-enabled/"
     ```
   - 重启 Nginx：
     ```bash
     ssh -i .trae/sometab-k-hp6LQQ1N.txt root@120.48.169.183 "systemctl restart nginx"
     ```

4. **部署网站**
   - 运行部署脚本：
     ```bash
     bash deploy.sh
     ```

## 网站功能

- **首页**：显示网站名称和欢迎信息
- **合作联系**：显示联系邮箱 Boss@sometab.com
- **免责声明**：声明本网站与 comfy.org 和 comfy.com 无关

## 访问方式

- HTTP：http://120.48.169.183
- HTTPS：https://120.48.169.183
- 域名：http://comfyui.com (将重定向到 HTTPS)
- 域名：https://comfyui.com
