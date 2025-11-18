#!/bin/bash

# TodoList iOS App 快速编译脚本
# 使用方法: bash quick_setup.sh

echo "=========================================="
echo "  iOS TODO List 项目快速设置"
echo "=========================================="
echo ""

PROJECT_DIR="/Users/severuspeng/Documents/Project/TODOList"
NEW_PROJECT_NAME="TodoListApp"
NEW_PROJECT_DIR="/Users/severuspeng/Documents/Project/${NEW_PROJECT_NAME}"

echo "📋 步骤说明："
echo ""
echo "由于Xcode项目文件较为复杂，建议通过Xcode GUI创建项目。"
echo "请按照以下步骤操作："
echo ""
echo "1️⃣  打开Xcode"
echo "   → File → New → Project (⇧⌘N)"
echo ""
echo "2️⃣  选择模板"
echo "   → iOS → App → Next"
echo ""
echo "3️⃣  配置项目信息"
echo "   Product Name: TodoList"
echo "   Interface: SwiftUI"
echo "   Language: Swift"
echo "   Storage: None"
echo "   → Next"
echo ""
echo "4️⃣  选择保存位置"
echo "   → 选择任意位置（建议: ~/Desktop/）"
echo "   → Create"
echo ""
echo "5️⃣  在Xcode中删除默认文件"
echo "   → 右键删除 TodoListApp.swift (Move to Trash)"
echo "   → 右键删除 ContentView.swift (Move to Trash)"
echo ""
echo "6️⃣  添加项目文件"
echo "   → 右键项目名 → Add Files to \"TodoList\"..."
echo "   → 导航到: ${PROJECT_DIR}"
echo "   → ⌘A 全选所有.swift文件"
echo "   → 确保勾选 ✅ Copy items if needed"
echo "   → Add"
echo ""
echo "7️⃣  配置最低版本"
echo "   → 点击项目蓝色图标 → TARGETS → General"
echo "   → Minimum Deployments: iOS 17.0"
echo ""
echo "8️⃣  配置Info.plist"
echo "   → 点击Info.plist → 点击 +"
echo "   → 选择 'Privacy - User Notifications Usage Description'"
echo "   → 值填写: 需要通知权限以便在任务到期时提醒您"
echo ""
echo "9️⃣  选择模拟器并运行"
echo "   → 选择 iPhone 15 Pro"
echo "   → 点击 ▶️ 或按 ⌘R"
echo ""
echo "=========================================="
echo ""
echo "📁 当前项目文件位置: ${PROJECT_DIR}"
echo ""
echo "📄 可用的Swift文件 (共12个):"
find "${PROJECT_DIR}" -name "*.swift" -type f | while read file; do
    echo "   ✓ $(basename "$file")"
done
echo ""
echo "📖 详细指南请查看: ${PROJECT_DIR}/SETUP_GUIDE.md"
echo ""
echo "=========================================="
echo ""
echo "是否要在Finder中打开项目文件夹? (y/n)"
read -r response

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    open "${PROJECT_DIR}"
    echo "✅ 已在Finder中打开项目文件夹"
fi

echo ""
echo "是否要打开Xcode? (y/n)"
read -r response

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    open -a Xcode
    echo "✅ 已启动Xcode"
fi

echo ""
echo "祝编译顺利! 🚀"
