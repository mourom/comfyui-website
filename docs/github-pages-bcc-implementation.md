# GitHub Pages + 百度BCC服务器 实施方案

## 架构设计

### 整体架构
- **前端**：静态网站托管在 GitHub Pages
- **后端**：API 服务部署在百度BCC服务器
- **通信方式**：前端通过 AJAX 调用后端 API
- **域名配置**：前端使用自定义域名，后端使用 IP 地址或未备案域名

### 技术栈选择
- **前端**：HTML5 + CSS3 + JavaScript（可选：React、Vue 等框架）
- **后端**：Node.js + Express（可选：Python + Flask、PHP + Laravel 等）
- **数据库**：MongoDB（可选：MySQL、PostgreSQL 等）
- **部署工具**：Git、PM2（进程管理）

## 实现步骤

### 步骤 1：部署前端（GitHub Pages）

#### 1.1 创建 GitHub 仓库
1. 登录 GitHub，点击 "New repository"
2. 仓库名称：`comfyui-web`
3. 勾选 "Initialize this repository with a README"
4. 点击 "Create repository"

#### 1.2 启用 GitHub Pages
1. 进入仓库设置（Settings）
2. 滚动到 "GitHub Pages" 部分
3. 在 "Source" 下拉菜单中选择 "main branch"
4. 点击 "Save"
5. 稍等片刻，GitHub Pages 会生成访问 URL

#### 1.3 配置自定义域名
1. 在 "GitHub Pages" 部分，找到 "Custom domain"
2. 输入你的域名，例如：`comfyui.com`
3. 点击 "Save"
4. 在你的域名注册商处，添加 CNAME 记录，将域名指向 `mourom.github.io`

#### 1.4 上传前端代码
1. 克隆仓库到本地：`git clone https://github.com/mourom/comfyui-web.git`
2. 进入仓库目录：`cd comfyui-web`
3. 创建前端文件（index.html、style.css、script.js 等）
4. 提交并推送代码：
   ```bash
   git add .
   git commit -m "Initial commit"
   git push origin main
   ```

### 步骤 2：部署后端（百度BCC服务器）

#### 2.1 连接服务器
使用 SSH 连接到百度BCC服务器：
```bash
ssh -i ".trae/sometab-k-hp6LQQ1N.txt" root@120.48.169.183
```

#### 2.2 安装必要软件
```bash
# 更新系统
apt update && apt upgrade -y

# 安装 Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# 安装 Nginx
apt install -y nginx

# 安装 PM2（进程管理工具）
npm install -g pm2

# 安装 MongoDB（可选）
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list
apt update
apt install -y mongodb-org
```

#### 2.3 创建后端项目
```bash
# 创建项目目录
mkdir -p /var/www/comfyui-api
cd /var/www/comfyui-api

# 初始化项目
npm init -y

# 安装依赖
npm install express cors mongoose dotenv

# 创建 API 代码
```

#### 2.4 编写后端代码
创建 `server.js` 文件：

```javascript
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// 配置 CORS
app.use(cors({
  origin: 'https://comfyui.com', // 你的 GitHub Pages 域名
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// 解析 JSON 请求
app.use(express.json());

// 示例 API 路由
app.get('/api', (req, res) => {
  res.json({ message: 'Hello from BCC server!' });
});

// 用户相关 API
app.get('/api/users', (req, res) => {
  res.json({ users: [{ id: 1, name: 'User 1' }, { id: 2, name: 'User 2' }] });
});

app.post('/api/users', (req, res) => {
  const newUser = req.body;
  res.json({ message: 'User created', user: newUser });
});

// 启动服务器
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

#### 2.5 配置环境变量
创建 `.env` 文件：

```env
# 服务器配置
PORT=3000

# 数据库配置（可选）
MONGODB_URI=mongodb://localhost:27017/comfyui
```

#### 2.6 启动后端服务
```bash
# 使用 PM2 启动服务
pm install pm2 -g
pm run start

# 或直接使用 PM2
pm start

# 查看服务状态
pm list
```

#### 2.7 配置防火墙
```bash
# 允许 3000 端口访问
ufw allow 3000/tcp
ufw reload

# 查看防火墙状态
ufw status
```

### 步骤 3：前端调用后端 API

#### 3.1 编写前端 API 调用代码

在前端 `script.js` 文件中添加：

```javascript
// API 基础 URL
const API_BASE_URL = 'http://120.48.169.183:3000/api';

// 示例：获取用户列表
async function fetchUsers() {
  try {
    const response = await fetch(`${API_BASE_URL}/users`);
    if (!response.ok) {
      throw new Error('API 调用失败');
    }
    const data = await response.json();
    console.log('用户数据:', data);
    // 处理数据...
  } catch (error) {
    console.error('错误:', error);
  }
}

// 示例：创建用户
async function createUser(userData) {
  try {
    const response = await fetch(`${API_BASE_URL}/users`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(userData)
    });
    if (!response.ok) {
      throw new Error('创建用户失败');
    }
    const data = await response.json();
    console.log('创建结果:', data);
    // 处理结果...
  } catch (error) {
    console.error('错误:', error);
  }
}

// 页面加载时调用
window.addEventListener('DOMContentLoaded', () => {
  fetchUsers();
});
```

#### 3.2 测试 API 调用
1. 打开浏览器，访问你的 GitHub Pages 网站
2. 打开开发者工具（F12）
3. 查看控制台输出，确认 API 调用是否成功

## 代码示例

### 完整前端示例

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ComfyUI</title>
  <style>
    /* 基本样式 */
    body {
      font-family: Arial, sans-serif;
      margin: 0;
      padding: 20px;
      background-color: #f5f5f5;
    }
    .container {
      max-width: 1200px;
      margin: 0 auto;
    }
    .api-result {
      background-color: #e8f4f8;
      padding: 15px;
      border-radius: 5px;
      margin-top: 20px;
    }
    button {
      padding: 10px 20px;
      background-color: #4CAF50;
      color: white;
      border: none;
      border-radius: 4px;
      cursor: pointer;
    }
    button:hover {
      background-color: #45a049;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>ComfyUI - 测试 API 调用</h1>
    
    <button onclick="fetchUsers()">获取用户列表</button>
    <button onclick="testCreateUser()">创建测试用户</button>
    
    <div class="api-result" id="result">
      <h3>API 响应结果：</h3>
      <pre id="response"></pre>
    </div>
  </div>

  <script>
    const API_BASE_URL = 'http://120.48.169.183:3000/api';
    const responseDiv = document.getElementById('response');

    async function fetchUsers() {
      try {
        responseDiv.textContent = '加载中...';
        const response = await fetch(`${API_BASE_URL}/users`);
        if (!response.ok) {
          throw new Error('API 调用失败');
        }
        const data = await response.json();
        responseDiv.textContent = JSON.stringify(data, null, 2);
      } catch (error) {
        responseDiv.textContent = `错误: ${error.message}`;
      }
    }

    async function testCreateUser() {
      try {
        responseDiv.textContent = '创建中...';
        const userData = {
          name: '测试用户',
          email: 'test@example.com'
        };
        const response = await fetch(`${API_BASE_URL}/users`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(userData)
        });
        if (!response.ok) {
          throw new Error('创建用户失败');
        }
        const data = await response.json();
        responseDiv.textContent = JSON.stringify(data, null, 2);
      } catch (error) {
        responseDiv.textContent = `错误: ${error.message}`;
      }
    }

    // 页面加载时测试 API 连接
    window.addEventListener('DOMContentLoaded', async () => {
      try {
        responseDiv.textContent = '测试 API 连接...';
        const response = await fetch(`${API_BASE_URL}`);
        if (!response.ok) {
          throw new Error('API 连接失败');
        }
        const data = await response.json();
        responseDiv.textContent = `API 连接成功: ${JSON.stringify(data)}`;
      } catch (error) {
        responseDiv.textContent = `API 连接失败: ${error.message}`;
      }
    });
  </script>
</body>
</html>
```

### 完整后端示例

```javascript
const express = require('express');
const cors = require('cors');
const app = express();
const PORT = process.env.PORT || 3000;

// 配置 CORS
app.use(cors({
  origin: 'https://comfyui.com', // 替换为你的 GitHub Pages 域名
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// 解析 JSON 请求
app.use(express.json());

// 模拟数据库
let users = [
  { id: 1, name: '张三', email: 'zhangsan@example.com' },
  { id: 2, name: '李四', email: 'lisi@example.com' }
];

// 健康检查
app.get('/api', (req, res) => {
  res.json({ 
    message: 'Hello from BCC server!',
    timestamp: new Date().toISOString(),
    server: 'Baidu BCC'
  });
});

// 获取所有用户
app.get('/api/users', (req, res) => {
  res.json({ 
    success: true,
    users: users,
    count: users.length
  });
});

// 获取单个用户
app.get('/api/users/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const user = users.find(u => u.id === id);
  
  if (user) {
    res.json({ success: true, user });
  } else {
    res.status(404).json({ success: false, message: '用户不存在' });
  }
});

// 创建用户
app.post('/api/users', (req, res) => {
  const { name, email } = req.body;
  
  if (!name || !email) {
    return res.status(400).json({ success: false, message: '姓名和邮箱不能为空' });
  }
  
  const newUser = {
    id: users.length + 1,
    name,
    email
  };
  
  users.push(newUser);
  res.status(201).json({ success: true, message: '用户创建成功', user: newUser });
});

// 更新用户
app.put('/api/users/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const { name, email } = req.body;
  const userIndex = users.findIndex(u => u.id === id);
  
  if (userIndex === -1) {
    return res.status(404).json({ success: false, message: '用户不存在' });
  }
  
  users[userIndex] = {
    ...users[userIndex],
    name: name || users[userIndex].name,
    email: email || users[userIndex].email
  };
  
  res.json({ success: true, message: '用户更新成功', user: users[userIndex] });
});

// 删除用户
app.delete('/api/users/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const userIndex = users.findIndex(u => u.id === id);
  
  if (userIndex === -1) {
    return res.status(404).json({ success: false, message: '用户不存在' });
  }
  
  users.splice(userIndex, 1);
  res.json({ success: true, message: '用户删除成功' });
});

// 启动服务器
app.listen(PORT, () => {
  console.log(`Server running on http://0.0.0.0:${PORT}`);
  console.log(`API documentation: http://0.0.0.0:${PORT}/api`);
});
```

## 部署脚本

### 前端部署脚本（deploy-frontend.sh）

```bash
#!/bin/bash

# 前端部署脚本

echo "=== 开始部署前端 ==="

# 拉取最新代码
git pull origin main

echo "=== 前端部署完成 ==="
echo "访问地址: https://comfyui.com"
```

### 后端部署脚本（deploy-backend.sh）

```bash
#!/bin/bash

# 后端部署脚本

SERVER_IP="120.48.169.183"
SERVER_USER="root"
SERVER_DIR="/var/www/comfyui-api"
KEY_FILE=".trae/sometab-k-hp6LQQ1N.txt"

echo "=== 开始部署后端 ==="

# 上传文件
scp -i "$KEY_FILE" -r "server.js" "package.json" "package-lock.json" "$SERVER_USER@$SERVER_IP:$SERVER_DIR/"

# 安装依赖并重启服务
ssh -i "$KEY_FILE" "$SERVER_USER@$SERVER_IP" "cd $SERVER_DIR && npm install && pm2 restart server || pm2 start server"

echo "=== 后端部署完成 ==="
echo "API 地址: http://$SERVER_IP:3000/api"
```

## 注意事项

### 1. 安全性
- **API 密钥**：生产环境中，建议实现 API 密钥或 JWT 认证
- **HTTPS**：考虑为后端 API 配置 HTTPS，使用 Let's Encrypt 免费证书
- **防火墙**：只开放必要的端口，其他端口全部关闭
- **输入验证**：对所有用户输入进行严格验证，防止注入攻击

### 2. 性能优化
- **缓存**：使用 Redis 缓存频繁访问的数据
- **压缩**：启用 GZIP 压缩，减少传输数据量
- **CDN**：将静态资源（图片、CSS、JS）放在 CDN 上
- **数据库索引**：为数据库查询字段添加索引

### 3. 可靠性
- **错误处理**：实现完善的错误处理机制
- **日志记录**：使用 Winston 等日志库记录详细日志
- **监控**：设置服务器监控，及时发现异常
- **备份**：定期备份数据库和重要配置

### 4. 跨域问题
- 确保后端正确配置 CORS 头
- 如需支持多个域名，可使用通配符或数组形式配置 origin
- 生产环境中，建议明确指定允许的域名，不要使用通配符

## 故障排查

### 常见问题及解决方案

#### 1. API 调用失败
- **症状**：前端控制台显示 "Failed to fetch" 或 CORS 错误
- **排查步骤**：
  1. 检查 BCC 服务器是否运行
  2. 检查 API 服务是否启动
  3. 检查防火墙规则是否允许端口访问
  4. 检查 CORS 配置是否正确

#### 2. 数据库连接失败
- **症状**：后端日志显示 "MongoDB connection failed"
- **排查步骤**：
  1. 检查数据库服务是否运行
  2. 检查数据库连接字符串是否正确
  3. 检查数据库用户权限是否正确

#### 3. 服务器崩溃
- **症状**：API 无响应，服务器 CPU 或内存使用率高
- **排查步骤**：
  1. 使用 `pm2 logs` 查看错误日志
  2. 检查服务器资源使用情况：`top` 或 `htop`
  3. 优化代码，修复内存泄漏
  4. 考虑升级服务器配置

#### 4. 部署失败
- **症状**：`scp` 或 `ssh` 命令失败
- **排查步骤**：
  1. 检查密钥文件权限：`chmod 600 .trae/sometab-k-hp6LQQ1N.txt`
  2. 检查服务器 IP 是否正确
  3. 检查网络连接是否正常
  4. 检查服务器防火墙是否允许 SSH 访问

## 监控与维护

### 服务器监控
- **系统监控**：使用 `htop`、`iotop` 监控系统资源
- **服务监控**：使用 `pm2 monit` 监控 Node.js 进程
- **日志监控**：使用 `pm2 logs` 实时查看日志

### 定期维护任务
- **每周**：检查服务器安全更新，运行 `apt update && apt upgrade`
- **每月**：备份数据库和配置文件
- **每季度**：检查服务器性能，优化配置

### 扩展建议
- **负载均衡**：当流量增加时，考虑使用负载均衡器
- **容器化**：使用 Docker 容器化部署，简化环境管理
- **CI/CD**：配置 GitHub Actions 自动部署代码

## 总结

本方案通过将前端托管在 GitHub Pages，后端部署在百度BCC服务器，实现了：

1. **无需备案**：前端使用 GitHub Pages，绕过了国内备案要求
2. **功能完整**：后端可实现复杂的业务逻辑和数据库操作
3. **成本优化**：静态内容使用免费的 GitHub Pages，节省服务器资源
4. **灵活扩展**：前后端分离，可独立开发和部署

此方案适合中小型网站，既满足了快速上线的需求，又为未来的功能扩展预留了空间。随着业务发展，可以在备案完成后，将整个网站迁移到国内服务器，获得更好的国内访问速度。