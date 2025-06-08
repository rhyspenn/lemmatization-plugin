#!/bin/bash

# lemmatization-plugin 发布脚本
# 项目: lemmatization-plugin
# 作者: Rhys
# 描述: 自动化发布流程，包括版本检查、构建、标签创建等

set -e  # 遇到错误时退出

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/src"

echo "🚀 开始发布流程..."

# 检查是否在 git 仓库中
if [ ! -d ".git" ]; then
    echo "❌ 错误: 不在 git 仓库中"
    exit 1
fi

# 检查工作区是否干净
if [ -n "$(git status --porcelain)" ]; then
    echo "❌ 错误: 工作区有未提交的更改"
    git status --short
    exit 1
fi

# 从 info.json 中提取版本信息
if [ -f "$SRC_DIR/info.json" ]; then
    PLUGIN_VERSION=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$SRC_DIR/info.json" | cut -d'"' -f4)
    PLUGIN_NAME=$(grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' "$SRC_DIR/info.json" | cut -d'"' -f4)
else
    echo "❌ 错误: 找不到 info.json 文件"
    exit 1
fi

echo "📦 插件名称: $PLUGIN_NAME"
echo "🔖 当前版本: $PLUGIN_VERSION"

# 检查版本号格式
if ! [[ $PLUGIN_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "❌ 错误: 版本号格式不正确 (应该是 x.y.z)"
    exit 1
fi

# 检查标签是否已存在
TAG_NAME="v$PLUGIN_VERSION"
if git rev-parse "$TAG_NAME" >/dev/null 2>&1; then
    echo "❌ 错误: 标签 $TAG_NAME 已存在"
    exit 1
fi

# 检查 package.json 版本是否一致
if [ -f "package.json" ]; then
    PACKAGE_VERSION=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' package.json | cut -d'"' -f4)
    if [ "$PACKAGE_VERSION" != "$PLUGIN_VERSION" ]; then
        echo "❌ 错误: package.json 版本 ($PACKAGE_VERSION) 与 info.json 版本 ($PLUGIN_VERSION) 不一致"
        exit 1
    fi
fi

# 确认发布
echo ""
echo "🤔 确认要发布版本 $PLUGIN_VERSION 吗? (y/N)"
read -r response
if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "❌ 发布已取消"
    exit 1
fi

# 运行构建
echo ""
echo "🔨 开始构建..."
if [ -f "build.sh" ]; then
    chmod +x build.sh
    ./build.sh
else
    echo "❌ 错误: 找不到 build.sh 文件"
    exit 1
fi

# 检查构建产物
PLUGIN_FILE="lemmatization-plugin-${PLUGIN_VERSION}.bobplugin"
if [ ! -f "$PLUGIN_FILE" ]; then
    echo "❌ 错误: 构建失败，找不到 $PLUGIN_FILE"
    exit 1
fi

# 计算文件哈希
FILE_HASH=$(shasum -a 256 "$PLUGIN_FILE" | cut -d' ' -f1)
echo "🔒 文件哈希: $FILE_HASH"

# 更新 appcast.json
if [ -f "appcast.json" ]; then
    echo "📝 更新 appcast.json..."
    # 这里可以添加更新 appcast.json 的逻辑
    # 暂时手动更新
    echo "⚠️  请手动更新 appcast.json 中的哈希值: $FILE_HASH"
fi

# 创建提交
echo ""
echo "📝 创建发布提交..."
git add .
git commit -m "chore: release v$PLUGIN_VERSION" || echo "没有新的更改需要提交"

# 创建标签
echo "🏷️  创建标签 $TAG_NAME..."
git tag -a "$TAG_NAME" -m "Release version $PLUGIN_VERSION

✨ 发布 $PLUGIN_NAME v$PLUGIN_VERSION

详细更新内容请查看 CHANGELOG.md
"

# 推送到远程仓库
echo "🚀 推送到远程仓库..."
git push origin main
git push origin "$TAG_NAME"

echo ""
echo "🎉 lemmatization-plugin 发布完成!"
echo "📍 标签: $TAG_NAME"
echo "📦 插件文件: $PLUGIN_FILE"
echo "🔒 SHA256: $FILE_HASH"
echo ""
echo "💡 下一步:"
echo "   1. GitHub Actions 将自动创建 Release"
echo "   2. 插件文件将自动上传到 Release"
echo "   3. 用户可以从 Release 页面下载安装"
echo ""
echo "🔗 Release 页面: https://github.com/rhyspenn/lemmatization-plugin/releases/tag/$TAG_NAME"
