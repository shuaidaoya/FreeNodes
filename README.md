# 🚀 FreeNodes

[![GitHub stars](https://img.shields.io/github/stars/shuaidaoya/FreeNodes?style=flat-square)](https://github.com/shuaidaoya/FreeNodes/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/shuaidaoya/FreeNodes?style=flat-square)](https://github.com/shuaidaoya/FreeNodes/network)
[![GitHub issues](https://img.shields.io/github/issues/shuaidaoya/FreeNodes?style=flat-square)](https://github.com/shuaidaoya/FreeNodes/issues)
[![License](https://img.shields.io/github/license/shuaidaoya/FreeNodes?style=flat-square)](LICENSE)
[![Last Update](https://img.shields.io/badge/Last%20Update-Daily-brightgreen?style=flat-square)](#)
---

- ~~时间是GitHub Actions服务器时间，和国内时间不同（后期会考虑转换为国内时间）~~ 
- 本项目用的是泉州广电的卡跑出来的节点-其他运营商有部分节点无法使用还请见谅

> ⚠️ **注意**: 本项目仅提供节点分享，不提供技术支持服务。
<!-- AUTO_STATS_START -->
## 📊 实时统计
节点速度最低1m/s,以GitHub为测试地址,建议先测一遍速，剔除不可用节点，再进行使用
| 项目 | 状态 |
|------|------|
| 🕐 **最后更新时间** | 2025-11-07 12:40:54 北京时间 |
| 📄 **YAML 节点** | 40 个 |
| 📝 **Base64 节点数** | 40 个 |
| 🔄 **同步状态** | 🔄 备用同步 |

## 🔧 触发器状态监控
| 触发器类型 | 状态 | 执行间隔 | 说明 |
|-----------|------|----------|------|
| 🎯 **主触发器** | 🟢 正常 | 每30分钟 | 主要同步触发器 |
| 🔄 **备用触发器** | 🟢 正常 | 每30分钟 | 备用同步触发器 |
| 🚨 **紧急恢复** | 🟢 正常 | 每30分钟 | 紧急恢复检查 |
<!-- AUTO_STATS_END -->

## 📖 项目简介

FreeNodes 是一个专门分享**免费、可用、高质量**代理节点的开源项目。所有节点都经过 **[SubsCheck-Win-GUI](https://github.com/sinspired/SubsCheck-Win-GUI)** 严格测试验证，确保连接稳定性和可用性。

> 🙏 **特别感谢**: 感谢 [sinspired/SubsCheck-Win-GUI](https://github.com/sinspired/SubsCheck-Win-GUI) 项目提供的优秀节点测试工具，为本项目的节点质量保证提供了强有力的技术支持。
> - 🙏各位大佬和其对应的开源项目开源项目在下方统一表示感谢

我们致力于为用户提供：
- 🔍 **经过验证的节点** - 每个节点都通过专业工具测试
- 🌍 **全球覆盖** - 覆盖多个国家和地区的高速节点  
- 📱 **多格式支持** - 支持各种主流代理客户端
- 🔄 **高频更新** -每30分钟自动拉取最新节点文件确保可用性

## ✨ 项目特性

### 🎯 核心特性
- ✅ **质量保证** - 所有节点经过 SubsCheck-Win-GUI 测试验证
- 🌐 **多地区覆盖** - 美国、日本、新加坡、香港等热门地区
- ⚡ **速度分级** - 按照网络速度进行分类标注
- 📦 **多格式订阅** - 支持 YAML、Base64、Mihomo 等格式

### 🔧 技术特性  
- 🔄 **每30分钟自动更新** - 自动化测试和更新流程
- 📡 **Gist 订阅** - 基于 GitHub Gist 的稳定订阅服务
- 🛡️ **安全可靠** - 开源透明，无隐私收集
- 📱 **跨平台支持** - 支持 Windows、macOS、Linux、Android、iOS

### 📊 数据格式
- `all.yaml` - 完整的 YAML 格式配置文件
- `base64.txt` - Base64 编码的节点列表  
- `history.yaml` - 历史节点记录文件
- `mihomo.yaml` - Mihomo 客户端专用配置

## 🚀 快速开始

1. **选择订阅格式** - 根据您的客户端选择合适的订阅链接
2. **复制订阅链接** - 从下方订阅链接部分复制对应格式的链接
3. **导入客户端** - 将链接导入到您的代理客户端中
4. **开始使用** - 选择合适的节点开始使用

> 💡 **提示**: 建议优先测试一遍节点延迟-选择延迟较低切速度不错的的节点以获得更好的使用体验。

## 📡 订阅链接

### 🔗 Gist 订阅地址

| 格式类型 | 适用客户端 | 订阅链接 | 适用客户端 |
|---------|------|----------|-----------|
| 📄 **all.yaml** | Clash Party、V2Ray、Clash、Shadowrocket | `https://gist.githubusercontent.com/shuaidaoya/9e5cf2749c0ce79932dd9229d9b4162b/raw/all.yaml` | Clash Party、V2Ray、Clash、Shadowrocket |
| 📝 **base64.txt** | 通用订阅，不知道选什么协议 优先选这个 | `https://gist.githubusercontent.com/shuaidaoya/9e5cf2749c0ce79932dd9229d9b4162b/raw/base64.txt` | 通用客户端 |
| 📚 **history.yaml** | 历史节点记录 | `https://gist.githubusercontent.com/shuaidaoya/9e5cf2749c0ce79932dd9229d9b4162b/raw/mihomo.yaml` | 备用节点 |
| ⚡ **mihomo.yaml** | Mihomo 专用配置 | `https://gist.githubusercontent.com/shuaidaoya/9e5cf2749c0ce79932dd9229d9b4162b/raw/mihomo.yaml` | Mihomo |

> 🎯 **一键复制**: 点击上方链接可直接复制到剪贴板，然后粘贴到您的代理客户端中

## 📋 更新日志

| 时间 -仅保留最新10条 | 节点数量 | 节点详情 |
|------|------|----------|
| 2025-11-07 12:40:54 | YAML:40个, Base64:40个 | 🔄 备用触发器更新 - YAML:40个, Base64:40个 |
| 2025-11-07 12:26:50 | YAML:40个, Base64:40个 | 🚨 紧急恢复更新 - YAML:40个, Base64:40个 |
| 2025-11-07 12:16:09 | YAML:40个, Base64:40个 | 📊 自动更新 - YAML:40个, Base64:40个 |
| 2025-11-07 12:12:17 | YAML:40个, Base64:40个 | 🔄 备用触发器更新 - YAML:40个, Base64:40个 |
| 2025-11-07 11:54:57 | YAML:41个, Base64:40个 | 🚨 紧急恢复更新 - YAML:41个, Base64:40个 |
| 2025-11-07 11:53:52 | YAML:41个, Base64:40个 | 🔄 备用触发器更新 - YAML:41个, Base64:40个 |
| 2025-11-07 11:40:40 | YAML:41个, Base64:40个 | 📊 自动更新 - YAML:41个, Base64:40个 |
| 2025-11-07 11:29:23 | YAML:41个, Base64:40个 | 🔄 备用触发器更新 - YAML:41个, Base64:40个 |
| 2025-11-07 11:12:59 | YAML:41个, Base64:40个 | 🚨 紧急恢复更新 - YAML:41个, Base64:40个 |
| 2025-11-07 10:52:10 | YAML:72个, Base64:72个 | 📊 自动更新 - YAML:72个, Base64:72个 |
| 2025-11-07 10:24:01 | YAML:72个, Base64:72个 | 🔄 备用触发器更新 - YAML:72个, Base64:72个 |
 

### 📋 使用方法

1. **复制链接**: 根据您的客户端类型，复制对应格式的订阅链接
2. **导入订阅**: 在客户端中添加订阅，粘贴复制的链接
3. **更新订阅**: 客户端会自动获取最新的节点列表
4. **选择节点**: 从节点列表中选择合适的节点连接

#### 🔰 新手推荐客户端
- **Windows**: Clash Party 或 V2RayN 或 Clash for Windows
- **macOS**: ClashX 或 V2RayU  
- **Android**: NekoBox 或 V2RayNG 或 Clash for Android
- **iOS**: Shadowrocket 或 Quantumult X

### 📊 节点命名规则

节点按照以下格式命名，方便用户识别和选择：

- **TW²_1|1.9MB/s**
- **JP¹-US⁰_1|3.1MB/s**
- **JP²_1|1.0MB/s**
- **US¹⁺_1|1.6MB/s**

## ⚠️ 免责声明

### 🚨 重要提示

**请在使用本项目前仔细阅读以下免责声明。使用本项目即表示您同意并接受以下条款：**

#### 📋 服务性质
1. **免费服务**: 本项目提供的所有节点均为免费分享，不涉及任何商业交易
2. **测试用途**: 节点仅供网络连通性测试和学习研究使用
3. **无保证服务**: 不保证节点的持续可用性、稳定性或安全性
4. **第三方资源**: 节点来源于互联网公开资源，非本项目自建

#### ⚖️ 法律责任
1. **合规使用**: 用户应遵守所在国家/地区的相关法律法规
2. **自担风险**: 使用节点产生的任何法律后果由用户自行承担
3. **禁止滥用**: 严禁将节点用于违法犯罪活动
4. **内容责任**: 用户通过节点访问的内容与本项目无关

#### 🔒 隐私安全
1. **数据安全**: 不保证通过节点传输的数据安全性
2. **隐私保护**: 建议用户不要传输敏感个人信息
3. **日志记录**: 节点提供方可能记录用户访问日志
4. **第三方风险**: 节点可能存在被监控或记录的风险

### 📜 最终条款

**使用本项目即表示您已充分理解并同意承担所有相关风险。如不同意以上条款，请立即停止使用本项目。**

---

## 📄 许可证

本项目采用 [MIT License](LICENSE) 开源许可证。

### 📋 许可证要点

- ✅ **自由使用**: 可以自由使用、复制、修改和分发
- ✅ **商业友好**: 允许商业使用 (仅限代码，不包括节点)
- ✅ **无担保**: 软件按"原样"提供，不提供任何担保
- ⚠️ **保留版权**: 必须保留原始版权声明

### 🔗 完整许可证

详细许可证条款请查看 [LICENSE](LICENSE) 文件。

---

### 感谢以下大佬和其对应的开源项目

-  [sinspired](https://github.com/sinspired/SubsCheck-Win-GUI)
-  [cmliu-CM大佬](https://github.com/cmliu/SubsCheck-Win-GUI)
-  [beck-8](https://github.com/beck-8/subs-check)
-  [bestruirui](https://github.com/bestruirui/BestSub)

> **感谢以上大佬的开源项目**: 正是有以上大佬的开源项目才有本项目。
---

<div align="center">
  <p>如果这个项目对您有帮助，请给它一个 ⭐️</p>
  <p>Made with ❤️ by FreeNodes Team</p>
</div>
