#!/bin/bash

# 快速打开TodoList Xcode项目

PROJECT_PATH="/Users/severuspeng/Documents/Project/TODOList/TodoList.xcodeproj"

echo "=========================================="
echo "  正在打开 TodoList Xcode 项目..."
echo "=========================================="
echo ""

# 检查项目文件是否存在
if [ ! -d "$PROJECT_PATH" ]; then
    echo "❌ 错误: 找不到项目文件"
    echo "   路径: $PROJECT_PATH"
    exit 1
fi

# 检查Xcode是否已安装
if ! command -v xcodebuild &> /dev/null; then
    echo "⚠️  警告: 未检测到完整的Xcode安装"
    echo ""
    echo "正在尝试打开项目..."
fi

# 打开项目
open "$PROJECT_PATH"

echo "✅ 项目已在Xcode中打开"
echo ""
echo "📝 下一步:"
echo "  1. 选择模拟器（iPhone 15 Pro）"
echo "  2. 点击 ▶️  按钮或按 ⌘R 运行"
echo "  3. 允许通知权限"
echo ""
echo "💡 提示:"
echo "  - 详细说明请查看: HOW_TO_OPEN.md"
echo "  - 功能说明请查看: README.md"
echo ""
echo "=========================================="
