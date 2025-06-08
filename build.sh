#!/bin/bash

# lemmatization-plugin 构建脚本
# 项目: lemmatization-plugin
# 作者: Rhys
# 描述: 将 src 目录下的所有文件打包成 .bobplugin 插件包

set -e  # 遇到错误时退出

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/src"
BUILD_DIR="$SCRIPT_DIR"

# 从 info.json 中提取插件信息
if [ -f "$SRC_DIR/info.json" ]; then
    PLUGIN_NAME=$(grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' "$SRC_DIR/info.json" | cut -d'"' -f4)
    PLUGIN_VERSION=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$SRC_DIR/info.json" | cut -d'"' -f4)
    PLUGIN_IDENTIFIER=$(grep -o '"identifier"[[:space:]]*:[[:space:]]*"[^"]*"' "$SRC_DIR/info.json" | cut -d'"' -f4)
else
    echo "❌ 错误: 找不到 info.json 文件"
    exit 1
fi

# 创建输出文件名
if [ -n "$PLUGIN_IDENTIFIER" ]; then
    # 使用标识符作为文件名（更规范）
    OUTPUT_NAME="${PLUGIN_IDENTIFIER}-${PLUGIN_VERSION}"
else
    # 使用插件名称作为文件名
    OUTPUT_NAME="${PLUGIN_NAME// /-}-${PLUGIN_VERSION}"
fi

echo "🚀 开始打包 Bob 插件..."
echo "📦 插件名称: $PLUGIN_NAME"
echo "🔖 插件版本: $PLUGIN_VERSION"
echo "🆔 插件标识: $PLUGIN_IDENTIFIER"

# 检查源文件夹是否存在
if [ ! -d "$SRC_DIR" ]; then
    echo "❌ 错误: src 目录不存在"
    exit 1
fi

# 检查必需的文件
echo "🔍 检查必需文件..."
required_files=("info.json" "main.js")
for file in "${required_files[@]}"; do
    if [ ! -f "$SRC_DIR/$file" ]; then
        echo "❌ 错误: 缺少必需文件 $file"
        exit 1
    fi
done

# 创建构建目录（现在是根目录，不需要创建）
# mkdir -p "$BUILD_DIR"

# 进入源目录进行打包
cd "$SRC_DIR"

# 清理可能存在的临时文件
echo "🧹 清理临时文件..."
find . -name ".DS_Store" -delete 2>/dev/null || true
find . -name "*.tmp" -delete 2>/dev/null || true
find . -name "Thumbs.db" -delete 2>/dev/null || true

# 列出将要打包的文件
echo "📋 将要打包的文件:"
ls -la

# 创建 zip 文件
ZIP_FILE="$BUILD_DIR/${OUTPUT_NAME}.zip"
echo "📦 创建 zip 文件: $ZIP_FILE"

# 压缩所有文件（不包含文件夹本身）
zip -r "$ZIP_FILE" . -x "*.DS_Store" "*.tmp" "Thumbs.db"

# 将 .zip 改名为 .bobplugin
PLUGIN_FILE="$BUILD_DIR/${OUTPUT_NAME}.bobplugin"
mv "$ZIP_FILE" "$PLUGIN_FILE"

echo "✅ 打包完成!"
echo "📍 输出文件: $PLUGIN_FILE"
echo "📊 文件大小: $(du -h "$PLUGIN_FILE" | cut -f1)"

# 验证打包结果
echo "🔍 验证打包内容..."
unzip -l "$PLUGIN_FILE"

echo ""
echo "🎉 lemmatization-plugin 插件打包成功!"
echo "💡 提示:"
echo "   - 可以双击 $PLUGIN_FILE 安装到 Bob"
echo "   - 调试时可以将 src 文件夹重命名为 src.bobplugin 直接安装"
echo "   - 发布时请使用 $PLUGIN_FILE 文件"
