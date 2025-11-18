# Info.plist 配置说明

在 Xcode 项目中，您需要在 Info.plist 文件中添加以下配置：

## 方法1: 通过 Xcode UI 配置

1. 在 Xcode 中打开项目
2. 选择项目的 Target
3. 进入 "Info" 选项卡
4. 点击 "+" 按钮添加新的键值对
5. 添加以下内容：

### 通知权限说明
- **Key**: `NSUserNotificationsUsageDescription` 或 `Privacy - User Notifications Usage Description`
- **Type**: String
- **Value**: `需要通知权限以便在任务到期时提醒您`

## 方法2: 直接编辑 Info.plist 文件

在 Info.plist 文件中添加以下 XML 内容：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- 其他配置项 -->

    <!-- 通知权限说明 -->
    <key>NSUserNotificationsUsageDescription</key>
    <string>需要通知权限以便在任务到期时提醒您</string>

    <!-- 应用名称 -->
    <key>CFBundleDisplayName</key>
    <string>待办清单</string>

</dict>
</plist>
```

## 重要提示

1. **iOS 17+**: 本应用使用 SwiftData，需要 iOS 17.0 或更高版本
2. **通知权限**: 应用首次启动时会自动请求通知权限
3. **真机测试**: 通知功能需要在真机上测试，模拟器可能不支持所有通知特性

## 其他可选配置

### 支持的设备方向
可以在 Target → General → Deployment Info 中配置：
- Portrait (竖屏)
- Landscape Left (横屏左)
- Landscape Right (横屏右)

### 启动屏幕
建议创建 Launch Screen，提供更好的用户体验。

### App Icon
在 Assets.xcassets 中添加 AppIcon，支持各种尺寸的图标。
