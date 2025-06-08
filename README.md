# lemmatization-plugin

## 英文词形变化查询 Bob 插件

[![GitHub release](https://img.shields.io/github/v/release/rhyspenn/lemmatization-plugin?color=blue&style=flat-square)](https://github.com/rhyspenn/lemmatization-plugin/releases)
[![GitHub downloads](https://img.shields.io/github/downloads/rhyspenn/lemmatization-plugin/total?color=green&style=flat-square)](https://github.com/rhyspenn/lemmatization-plugin/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://github.com/rhyspenn/lemmatization-plugin/blob/main/LICENSE)
[![Bob Plugin](https://img.shields.io/badge/Bob-Plugin-orange.svg?style=flat-square)](https://bobtranslate.com/)
[![Version](https://img.shields.io/badge/version-0.2.0-brightgreen.svg?style=flat-square)](https://github.com/rhyspenn/lemmatization-plugin)
[![Language](https://img.shields.io/badge/language-JavaScript-yellow.svg?style=flat-square)](https://developer.mozilla.org/en-US/docs/Web/JavaScript)

> 🔍 `lemmatization-plugin` - 查询英文单词的各种词形变化，包括复数、过去式、现在分词等形式的专业 Bob 插件

## ✨ 功能特点

- 🔄 **全面的词形变化**: 支持名词复数、动词变位、形容词比较级等多种形式
- ⚡ **本地高速查询**: 基于本地词典，无需网络连接，响应迅速
- 🎯 **智能双向查询**: 支持原形→变化形式，也支持变化形式→原形的反向查询
- 📚 **丰富词汇库**: 包含常用英语词汇的各种变化形式
- 🛡️ **稳定可靠**: 完善的错误处理，支持各种边界情况
- 🎨 **原生集成**: 完美融入 Bob 生态，支持所有 Bob 功能

## 📖 支持的词形变化类型

| 类型 | 示例 | 说明 |
|------|------|------|
| 名词复数 | cat → cats | 规则和不规则复数形式 |
| 动词过去式 | run → ran | 过去式变化 |
| 动词现在分词 | run → running | -ing 形式 |
| 动词过去分词 | run → run | 过去分词形式 |
| 形容词比较级 | big → bigger | 比较级形式 |
| 形容词最高级 | big → biggest | 最高级形式 |
| 动词第三人称单数 | go → goes | 第三人称单数形式 |

## 🚀 自动化构建和发布

本项目使用 GitHub Actions 实现自动化构建和发布流程。

### 📦 开发版本构建

**触发条件**: 推送到 `main` 或 `master` 分支，或创建 Pull Request

**流程**:
1. 自动检查必需文件
2. 清理临时文件
3. 打包插件
4. 上传为 GitHub Artifact（保留 30 天）

**下载开发版本**:
1. 进入 GitHub 仓库的 Actions 页面
2. 选择最新的构建任务
3. 下载 Artifacts 中的插件文件

### 🎉 正式版本发布

**触发条件**: 推送版本标签（如 `v0.2.0`）

**操作步骤**:
```bash
# 1. 更新 src/info.json 中的版本号
# 2. 提交更改
git add src/info.json
git commit -m "bump version to 0.2.0"

# 3. 创建并推送版本标签
git tag v0.2.0
git push origin v0.2.0
```

**自动化流程**:
1. 自动检查必需文件
2. 清理临时文件
3. 打包插件
4. 创建 GitHub Release
5. 上传 `.bobplugin` 文件到 Release

## 📥 安装方法

### 🔥 一键安装（推荐）

1. 前往 [Releases 页面](../../releases) 下载最新版本
2. 下载 `lemmatization-plugin-x.x.x.bobplugin` 文件
3. 双击文件，Bob 会自动安装插件

### 📋 手动安装

1. 下载插件源码
2. 在 Bob 中选择 `偏好设置` → `服务` → `翻译`
3. 点击左下角 `+` 添加服务
4. 选择 `添加插件` → `从文件夹添加`
5. 选择插件的 `src` 目录

### 🛠️ 开发安装

适合开发者快速测试：
1. 将 `src` 目录重命名为 `src.bobplugin`
2. 双击 `src.bobplugin` 文件夹安装

## 🚀 使用方法

1. **选中文本**: 在任意应用中选中英文单词
2. **触发查询**: 使用 Bob 的快捷键（默认 `⌥ + D`）
3. **查看结果**: 插件会显示该单词的所有词形变化

### 🎯 查询示例

| 输入 | 输出结果 |
|------|----------|
| `cat` | cats（复数形式） |
| `run` | ran（过去式）, running（现在分词）, runs（第三人称单数） |
| `big` | bigger（比较级）, biggest（最高级） |
| `child` | children（不规则复数） |
| `cats` | cat（反向查询原形） |

## 📚 使用场景

- **英语学习**: 快速了解单词的各种变化形式
- **写作辅助**: 确认词汇的正确形式
- **语法检查**: 验证动词变位和名词复数
- **阅读理解**: 理解文本中的词形变化

## ⚙️ 插件配置

插件安装后即可使用，无需额外配置。支持 Bob 的所有翻译功能：

- ✅ 划词翻译
- ✅ 截图翻译  
- ✅ 输入翻译
- ✅ 快捷键翻译

## 🔧 本地构建

### 构建插件包

```bash
# 克隆项目
git clone https://github.com/rhyspenn/lemmatization-plugin.git
cd lemmatization-plugin

# 执行构建
chmod +x build.sh
./build.sh
```

### 发布新版本

```bash
# 1. 更新版本号
# 编辑 src/info.json 和 package.json 中的版本号

# 2. 执行发布脚本
chmod +x release.sh
./release.sh
```

## 🤝 贡献指南

欢迎贡献代码、报告问题或提出建议！

### 📋 开发文档
- [DEVELOPMENT.md](./DEVELOPMENT.md) - 开发指南和技术细节
- [TESTING.md](./TESTING.md) - 测试指南和测试用例  
- [CHANGELOG.md](./CHANGELOG.md) - 版本更新记录

### 🐛 问题反馈
- 使用 [GitHub Issues](../../issues) 报告问题
- 提供详细的问题描述和复现步骤
- 包含系统环境信息（macOS 版本、Bob 版本等）

### 💡 功能建议
- 在 [GitHub Issues](../../issues) 中提出新功能建议
- 详细描述功能需求和使用场景
- 欢迎提交 Pull Request

## 📊 项目统计

- **支持语言**: 英语词形变化查询
- **词汇量**: 包含常用英语词汇及其变化形式
- **更新频率**: 根据用户反馈持续优化
- **兼容性**: Bob 0.5.0+

## 🔗 相关链接

- **Bob 翻译**: [官方网站](https://bobtranslate.com/)
- **插件开发**: [Bob 插件开发文档](https://ripperhe.gitee.io/bob/#/plugin/quickstart)
- **问题报告**: [GitHub Issues](../../issues)
- **功能建议**: [GitHub Discussions](../../discussions)

## 📋 项目结构

```
lemmatization-plugin/
├── .github/
│   └── workflows/
│       └── release.yml      # 自动发布流程
├── src/
│   ├── info.json           # 插件信息配置
│   ├── main.js             # 主要逻辑实现
│   └── lemmatization-en.txt # 英文词形变化数据
├── appcast.json            # 插件更新配置
├── build.sh                # 本地构建脚本
├── release.sh              # 发布脚本
├── LICENSE                 # MIT 开源许可证
└── README.md              # 项目说明文档
```

## 📝 更新说明

### 最新版本 v0.2.0 (2025-06-08)
- ✨ 新增英文词形变化查询功能
- 📚 支持复数、过去式、现在分词等多种形式
- ⚡ 基于本地词典，响应速度快
- 🛡️ 完善的错误处理和边界情况支持
- 🔄 支持双向查询（原形↔变化形式）

完整更新记录请查看 [CHANGELOG.md](./CHANGELOG.md)

## 👤 作者

**Rhys**
- GitHub: [@rhyspenn](https://github.com/rhyspenn)
- Email: your-email@example.com

## 📄 许可证

本项目基于 [MIT License](./LICENSE) 开源协议。

## 💖 支持项目

如果这个插件对你有帮助，欢迎：

- ⭐ 给项目点个 Star
- 🐛 报告问题和建议
- 🔀 提交 Pull Request
- 📢 分享给更多人使用

---

<div align="center">

**🎉 感谢使用 lemmatization-plugin！**

Made with ❤️ for Bob users

[⬆️ 回到顶部](#lemmatization-plugin)

</div>
