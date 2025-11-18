# 项目脚本说明

本文件夹包含TodoList项目的辅助脚本。

## 📜 脚本列表

### open_project.sh
**功能**: 一键打开Xcode项目

**使用方法**:
```bash
./Scripts/open_project.sh
```

**说明**:
- 自动检测项目文件是否存在
- 打开TodoList.xcodeproj
- 显示下一步操作提示

---

### quick_setup.sh
**功能**: 显示项目快速设置向导

**使用方法**:
```bash
./Scripts/quick_setup.sh
```

**说明**:
- 显示详细的项目设置步骤
- 列出所有Swift源文件
- 可选打开Finder和Xcode
- 适合首次使用项目的开发者

---

### fix_build_errors.sh
**功能**: 验证项目配置并提供编译错误修复提示

**使用方法**:
```bash
./Scripts/fix_build_errors.sh
```

**说明**:
- 验证项目文件结构
- 检查关键配置文件
- 提供编译问题的解决建议

---

## 🚀 快速开始

最简单的方式：
```bash
cd /Users/severuspeng/Documents/Project/TODOList
./Scripts/open_project.sh
```

## 📝 权限说明

所有脚本都已设置执行权限。如需重新设置：
```bash
chmod +x Scripts/*.sh
```

## 🔧 自定义脚本

如需添加新的辅助脚本：
1. 在Scripts文件夹创建.sh文件
2. 添加shebang: `#!/bin/bash`
3. 设置执行权限: `chmod +x Scripts/your_script.sh`
4. 更新本README文档

---

返回主文档: [../README.md](../README.md)
