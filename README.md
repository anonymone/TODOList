# iOS TODO List App

一个功能完整的iOS待办事项应用，采用最新的SwiftUI和SwiftData技术。

## 功能特性

### ✅ 核心功能
- **任务管理**: 添加、编辑、删除、完成任务
- **分类系统**: 自定义分类，支持颜色和图标
- **优先级**: 三级优先级（高/中/低）
- **截止日期**: 设置任务到期时间
- **本地通知**: 任务到期提醒（支持提前通知）
- **搜索功能**: 按标题和备注搜索任务
- **筛选功能**: 按完成状态筛选任务

### 🎨 用户界面
- **Tab导航**: 任务列表和分类管理
- **滑动操作**: 左滑删除，右滑完成/取消完成
- **视觉提示**:
  - 过期任务红色标识
  - 即将到期任务橙色提示
  - 已完成任务划线显示
- **空状态**: 友好的空状态提示

### 🔔 通知功能
- 任务到期时气泡弹窗提醒
- 提前1小时预警通知
- 完成任务自动取消通知
- 删除任务自动清理通知

## 技术栈

- **语言**: Swift
- **UI框架**: SwiftUI
- **数据持久化**: SwiftData
- **通知服务**: UserNotifications
- **最低支持版本**: iOS 17.0

## 项目结构

```
TODOList/
├── TodoList.xcodeproj/            # Xcode项目文件（双击打开）
├── TodoList/                      # 源代码目录
│   ├── TodoListApp.swift         # App入口，配置SwiftData和通知
│   ├── ContentView.swift         # 主视图，Tab导航
│   ├── Info.plist                # 应用配置文件
│   ├── Assets.xcassets/          # 资源文件
│   ├── Models/                   # 数据模型层
│   │   ├── TodoItem.swift       # 任务模型
│   │   ├── Category.swift       # 分类模型
│   │   └── PreviewContainer.swift # 预览数据容器
│   ├── Views/                    # 视图层
│   │   ├── TodoListView.swift   # 任务列表
│   │   ├── TodoRowView.swift    # 任务行组件
│   │   ├── AddTodoView.swift    # 添加/编辑任务
│   │   ├── CategoryListView.swift # 分类列表
│   │   ├── AddCategoryView.swift # 添加分类
│   │   └── CategoryDetailView.swift # 分类详情
│   └── Services/                 # 服务层
│       └── NotificationManager.swift # 通知管理服务
├── Logs/                          # 项目文档和日志
│   ├── HOW_TO_OPEN.md            # 打开和运行说明
│   ├── SETUP_GUIDE.md            # 安装配置指南
│   ├── PROJECT_SUMMARY.md        # 技术实现总结
│   ├── INFO_PLIST_GUIDE.md      # Info.plist配置说明
│   ├── BUG_FIXES.md              # Bug修复记录
│   └── 项目配置完成说明.md       # 项目完成说明
├── Scripts/                       # 辅助脚本
│   ├── open_project.sh           # 一键打开项目
│   ├── quick_setup.sh            # 快速设置向导
│   └── fix_build_errors.sh       # 编译错误修复提示
├── .gitignore                     # Git忽略文件配置
└── README.md                      # 本文件
```

## 快速开始

**最简单方式**: 双击 `TodoList.xcodeproj` 打开项目，然后按 ⌘R 运行！

详细步骤请查看 `Logs/HOW_TO_OPEN.md`

### 1. 打开项目

```bash
# 方式1: 双击打开
open TodoList.xcodeproj

# 方式2: 使用脚本
./Scripts/open_project.sh
```

### 2. 配置Info.plist（已完成）

项目已包含完整的Info.plist配置，包括通知权限说明。
详细说明请查看 `Logs/INFO_PLIST_GUIDE.md`

### 3. 运行项目

1. 选择目标设备（iPhone 15 Pro 模拟器或真机）
2. 按 ⌘R 运行项目
3. 首次启动时会请求通知权限

## 使用说明

### 添加任务
1. 在任务列表页面点击右上角 "+" 按钮
2. 填写任务标题（必填）
3. 可选：添加备注、设置优先级、选择分类、设置截止日期
4. 点击"添加"保存

### 管理任务
- **完成任务**: 左滑任务，点击绿色勾选按钮
- **删除任务**: 右滑任务，点击红色删除按钮
- **编辑任务**: 点击任务进入详情页编辑

### 分类管理
1. 切换到"分类"标签页
2. 点击 "+" 创建新分类
3. 选择颜色和图标
4. 点击分类查看该分类下的所有任务

### 搜索和筛选
- 使用顶部搜索栏搜索任务
- 使用分段控件筛选：全部/未完成/已完成

## 开发进度

- [x] 项目基础配置
- [x] 数据模型设计（TodoItem、Category）
- [x] SwiftData持久化配置
- [x] 主界面UI（Tab导航）
- [x] 任务列表视图
- [x] 添加/编辑任务表单
- [x] 分类管理功能
- [x] 优先级和截止日期
- [x] 本地通知权限配置
- [x] 通知调度功能
- [x] 通知管理（更新、取消）
- [x] 搜索和筛选功能
- [x] UI细节优化

## 注意事项

1. **SwiftData要求**: 必须使用iOS 17.0或更高版本
2. **通知测试**: 通知功能建议在真机上测试
3. **数据持久化**: 应用数据自动保存到本地
4. **首次启动**: 会自动创建4个默认分类（工作、个人、购物、学习）

## 扩展功能建议

未来可以添加的功能：
- [ ] iCloud同步
- [ ] 子任务功能
- [ ] 重复任务
- [ ] 任务标签系统
- [ ] 统计和报表
- [ ] 小组件支持
- [ ] Apple Watch应用
- [ ] 深色模式优化

## 许可证

本项目仅供学习参考使用。

## 联系方式

如有问题或建议，欢迎提交Issue。
