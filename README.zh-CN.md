# MikuFans

基于 Flutter 开发的跨平台动漫播放器应用。

## 功能特性

- **多平台支持**：Windows、macOS、Linux、Android 和 iOS
- **媒体播放**：高质量视频播放，支持硬件加速
- **主题支持**：浅色、深色和跟随系统主题模式
- **系统托盘集成**：可最小化到系统托盘，方便访问
- **硬件加速**：优化的视频解码，提供更好的性能
- **搜索功能**：轻松搜索和发现动漫内容
- **历史记录**：跟踪您的观看历史
- **订阅管理**：订阅您喜爱的动漫

## 支持的平台

- ✅ Windows x86
- ✅ Windows ARM
- ✅ macOS（Intel 和 Apple Silicon）
- ✅ Linux（基于 Debian 和 Red Hat 的发行版）
## 安装

### 从 GitHub Releases 安装

1. 访问 [GitHub Releases](https://github.com/qiqd/flutter_mikufans/releases) 页面
2. 下载适合您平台的安装包
3. 按照平台说明进行安装

### 从源代码构建

```bash
# 克隆仓库
git clone https://github.com/qiqd/flutter_mikufans.git
cd flutter_mikufans

# 安装依赖
flutter pub get

# 构建您的平台版本
flutter build <platform> --release
```

将 `<platform>` 替换为 `windows`、`macos`、`linux`、`android` 或 `ios`。

## 使用说明

1. 启动应用程序
2. 使用左侧导航栏访问不同功能：
   - **搜索**：搜索动漫内容
   - **订阅**：管理您的订阅
   - **历史**：查看您的观看历史
   - **设置**：配置应用程序设置
3. 点击任何动漫查看详情并开始观看
4. 使用播放器控件播放/暂停、调整音量和导航剧集

## 设置

### 播放设置

- **自动播放下一集**：当前剧集结束时自动播放下一集
- **硬件加速**：使用硬件加速解码视频（推荐）

### 系统设置

- **最小化到托盘**：将应用程序最小化到系统托盘而不是关闭（需要重新启动应用才能生效）

### 界面设置

- **主题模式**：可选择浅色、深色或跟随系统主题

### 其他

- **关于**：查看应用信息、版本和许可证详情
- **检查更新**：检查是否有新版本可用

## 使用的技术

- **框架**：Flutter 3.38.4
- **路由**：go_router ^17.0.1
- **网络请求**：dio ^5.9.0
- **媒体播放**：media_kit ^1.2.6
- **本地存储**：shared_preferences ^2.5.4
- **窗口管理**：window_manager ^0.5.1
- **系统托盘**：tray_manager ^0.5.2
- **HTML解析**：html ^0.15.6
- **加密**：encrypt ^5.0.3

## 许可证

本项目采用 AGPL-3.0 许可证。详情请查看 [LICENSE](LICENSE) 文件。

## 使用条款

1. 本应用仅供学习和交流使用
2. 所有资源均来自互联网
3. 本应用不存储任何个人信息
4. 禁止商业用途
5. 使用本应用即表示您同意所有条款和条件
6. 如对内容有异议，请立即停止使用

---

© 2025 MikuFans