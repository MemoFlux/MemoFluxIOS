# MemoFluxIOS

## 项目概述

MemoFluxIOS是一个iOS应用，旨在AI驱动，来管理和分析笔记Memo和日程安排。应用使用SwiftUI和SwiftData构建，支持图片识别、文本分析和智能日程管理功能。

## 环境要求

- macOS 14.0或更高版本（支持Xcode的最新版本）
- Xcode 15.0或更高版本
- iOS 17.0或更高版本（应用目标平台）
- Swift 5.9或更高版本

## 本地部署流程

### 1. 克隆项目

```bash
git clone https://github.com/yourusername/MemoFluxIOS.git
cd MemoFluxIOS
```

### 2. 打开项目

使用Xcode打开项目：

```bash
open MemoFlux/MemoFlux.xcodeproj
```

或者直接双击`MemoFlux.xcodeproj`文件在Xcode中打开项目。

### 3. 配置开发团队

1. 在Xcode中，选择项目导航器中的`MemoFlux`项目
2. 选择`MemoFlux`目标
3. 在`Signing & Capabilities`选项卡中：
   - 勾选`Automatically manage signing`
   - 从下拉菜单中选择您的开发团队
4. 对`ScreenshotIntent`目标重复上述步骤

### 4. 配置App Group（如需使用快捷指令功能）

如果您需要使用快捷指令功能来添加截图：

1. 在`Signing & Capabilities`选项卡中点击`+`按钮
2. 添加`App Groups`功能
3. 添加一个新的App Group标识符（例如：`group.com.yourname.memoflux`）
4. 在`ScreenshotIntent`目标中也添加相同的App Group

### 5. 构建和运行

1. 在Xcode顶部的工具栏中选择目标设备（模拟器或实际设备）
2. 点击运行按钮（▶️）或使用快捷键`Cmd+R`构建并运行应用

### 6. 调试信息

- 应用使用SwiftData进行本地数据存储
- 网络请求允许HTTP连接（已在Info.plist中配置）
- 应用包含主页、分类和添加备忘录等主要功能

## 基本使用

1. **主页**：显示所有备忘录，按创建时间排序
2. **分类**：按类别查看备忘录
3. **添加备忘录**：点击右上角的加号按钮添加新备忘录
4. **AI分析**：应用可以分析备忘录内容，提供知识点、信息和日程安排的智能解析

## 注意事项

- DEBUG模式下运行应用时会显示引导动画页面
- 应用支持从快捷指令导入截图
- 如需使用网络功能，请确保在真机测试时连接到互联网

## 项目结构

- `MemoFlux/`：主应用目录
  - `Models/`：数据模型（MemoItemModel、APIResponseModels等）
  - `Views/`：UI视图组件
  - `ViewModels/`：视图模型
  - `Network/`：网络请求处理
  - `Utils/`：工具类和辅助函数
- `ScreenshotIntent/`：快捷指令扩展
  