# 项目编译指南

## 快速开始（推荐方法）

### 步骤1: 打开Xcode创建项目

1. 打开 **Xcode**（如未安装，请从Mac App Store下载）

2. 创建新项目：
   - 点击 **File** → **New** → **Project**（或按 ⇧⌘N）
   - 选择 **iOS** → **App**
   - 点击 **Next**

3. 配置项目：
   - **Product Name**: `TodoList`
   - **Team**: 选择你的开发团队（个人开发可选择个人账号）
   - **Organization Identifier**: `com.yourname`（替换为你的标识符）
   - **Interface**: 选择 **SwiftUI**
   - **Language**: 选择 **Swift**
   - **Storage**: 选择 **None**
   - **Include Tests**: 可以不勾选

4. 保存位置：
   - 点击 **Next**
   - 选择 `/Users/severuspeng/Documents/Project/` 作为保存位置
   - **重要**: 项目名称使用 `TodoListXcode`（避免与现有文件夹冲突）

### 步骤2: 删除默认文件

在Xcode左侧导航器中：
1. 右键点击 `TodoListApp.swift` → **Delete** → 选择 **Move to Trash**
2. 右键点击 `ContentView.swift` → **Delete** → 选择 **Move to Trash**

### 步骤3: 导入项目文件

#### 方式A - 拖拽导入（最简单）

1. 在Finder中打开 `/Users/severuspeng/Documents/Project/TODOList/`

2. 创建文件夹结构：
   - 在Xcode中右键项目名称 → **New Group** → 命名为 `Models`
   - 同样创建 `Views` 和 `Services` 文件夹

3. 拖拽文件到Xcode：
   - 从Finder拖拽 `TodoListApp.swift` 到项目根目录
   - 从Finder拖拽 `ContentView.swift` 到项目根目录
   - 从Finder拖拽 `Models/` 文件夹中的所有 `.swift` 文件到 Xcode 的 `Models` 文件夹
   - 从Finder拖拽 `Views/` 文件夹中的所有 `.swift` 文件到 Xcode 的 `Views` 文件夹
   - 从Finder拖拽 `Services/` 文件夹中的所有 `.swift` 文件到 Xcode 的 `Services` 文件夹

4. 在弹出的对话框中确保勾选：
   - ✅ **Copy items if needed**
   - ✅ **Create groups**
   - ✅ 选择你的 Target（TodoList）

#### 方式B - 使用 Add Files（推荐）

1. 在Xcode中，右键点击项目名称 → **Add Files to "TodoList"...**

2. 导航到 `/Users/severuspeng/Documents/Project/TODOList/`

3. 按住 ⌘ 键，选择以下文件：
   - `TodoListApp.swift`
   - `ContentView.swift`

4. 点击 **Options** 按钮，确保：
   - ✅ **Copy items if needed**
   - ✅ **Create groups**
   - ✅ 选中你的 Target

5. 点击 **Add**

6. 重复上述步骤，分别添加：
   - `Models/` 文件夹中的所有文件
   - `Views/` 文件夹中的所有文件
   - `Services/` 文件夹中的所有文件

### 步骤4: 配置项目设置

1. **设置最低iOS版本**：
   - 点击项目导航器中的项目名称（蓝色图标）
   - 选择 **TARGETS** → **TodoList**
   - 在 **General** 选项卡中
   - 找到 **Minimum Deployments**
   - 设置为 **iOS 17.0**

2. **配置Info.plist**：
   - 在项目导航器中找到 `Info.plist` 文件
   - 右键点击 → **Open As** → **Source Code**
   - 在 `<dict>` 标签内添加以下内容：

```xml
<key>NSUserNotificationsUsageDescription</key>
<string>需要通知权限以便在任务到期时提醒您</string>
```

或者使用Property List编辑器：
   - 点击 `Info.plist` 文件
   - 点击 `+` 按钮
   - 选择 **Privacy - User Notifications Usage Description**
   - 在 **Value** 列填写：`需要通知权限以便在任务到期时提醒您`

### 步骤5: 配置签名

1. 在 **Signing & Capabilities** 选项卡中
2. 勾选 **Automatically manage signing**
3. 选择你的 **Team**（如果没有，点击 Add Account 添加Apple ID）

### 步骤6: 编译运行

1. 选择模拟器：
   - 点击Xcode顶部的设备选择器
   - 选择 **iPhone 15 Pro** 或其他iOS 17+模拟器

2. 点击 **Run** 按钮（▶️）或按 **⌘R**

3. 等待编译完成，应用会自动在模拟器中启动

## 常见问题

### 问题1: 编译错误 "Cannot find type 'TodoItem'"
**解决方案**: 确保所有文件都正确添加到项目中，检查Target Membership

### 问题2: 编译错误 "Module compiled with Swift X cannot be imported"
**解决方案**:
- Build Settings → Swift Compiler - Language
- 确保 Swift Language Version 设置为 Swift 5

### 问题3: 模拟器无法运行
**解决方案**: 确保选择的模拟器是iOS 17.0或更高版本

### 问题4: 通知不工作
**解决方案**:
- 通知功能在模拟器上可能受限，建议在真机上测试
- 确保在应用首次启动时允许了通知权限

## 在真机上测试

1. 用数据线连接iPhone到Mac
2. 在Xcode设备选择器中选择你的iPhone
3. 确保iPhone系统版本 ≥ iOS 17.0
4. 点击Run运行
5. 首次运行需要在iPhone上信任开发者证书：
   - 设置 → 通用 → VPN与设备管理 → 选择你的证书 → 信任

## 验证安装

运行后应该看到：
- ✅ 应用启动显示Tab界面
- ✅ 底部有"任务"和"分类"两个标签
- ✅ 首次启动弹出通知权限请求
- ✅ 自动创建4个默认分类（工作、个人、购物、学习）
- ✅ 可以点击"+"按钮添加任务

## 下一步

- 查看 `README.md` 了解应用功能
- 查看 `PROJECT_SUMMARY.md` 了解项目结构
- 开始使用或修改代码
