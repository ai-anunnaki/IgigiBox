# LuciBox 构建说明

## 在macOS上构建

由于当前环境是Linux，无法直接构建macOS应用。请在Mac上执行以下步骤：

### 1. 安装Xcode
确保已安装Xcode 15.0或更高版本

### 2. 创建Xcode项目

```bash
# 进入项目目录
cd LuciBox

# 使用Xcode创建新项目
# File > New > Project > macOS > App
# 项目名称: LuciBox
# Bundle Identifier: com.anunnaki.lucibox
# Interface: SwiftUI
# Language: Swift
```

### 3. 添加源文件

将以下文件添加到Xcode项目：
- LuciBoxApp.swift
- ContentView.swift
- ProcessManager.swift
- Info.plist

### 4. 配置权限

在项目设置中添加以下权限：
- Signing & Capabilities > App Sandbox > 取消勾选（或配置具体权限）
- 或添加以下权限：
  - Network (Incoming/Outgoing)
  - File Access (Read/Write)

### 5. 构建运行

```bash
# 命令行构建
xcodebuild -scheme LuciBox -configuration Release

# 或在Xcode中按 Cmd+R 运行
```

## 功能说明

### 进程管理
- 查看所有系统进程
- 显示PID、进程名称、监听端口
- 搜索过滤进程
- 一键杀掉进程
- 实时刷新列表

## 注意事项

1. 杀掉系统关键进程可能导致系统不稳定
2. 某些进程需要管理员权限才能杀掉
3. 端口信息获取需要一定时间，首次加载可能较慢
