# Ciyue(词悦)

开源的 **Android 平台 MDict 词典应用**,用 **Flutter** 开发,MIT 许可证,已上架 F-Droid。
注意:项目已移除 Windows/Linux 桌面支持,现在仅支持 Android(commit f198891)。

## 主要功能

- **MDX/MDD 词典支持**:通过 `dict_reader` 库解析 MDict 格式词典文件(MDX 词条数据、MDD 资源文件如发音/图片/CSS),用 WebView(`flutter_inappwebview`)渲染词条
- **多词典**:支持同时加载多本词典进行搜索和分组展示
- **AI 翻译**:支持 OpenAI、Gemini、DeepSeek 等多种提供商(用户自填 API Key),返回内容用 `gpt_markdown` 渲染
- **生词本 + 间隔重复**:可收藏单词,内置基于 FSRS 算法的闪卡复习功能
- **朗读**:通过 `flutter_tts` 实现 TTS 发音
- **Material You**:支持动态取色主题(`dynamic_color`)

定位:本地 MDict 词典为主,AI 翻译作为在线增强功能。

## 技术栈

| 方面 | 技术 |
|---|---|
| 框架 | Flutter(仅 Android) |
| 状态管理 | Riverpod + Provider,配合 Freezed 生成不可变模型 |
| 数据库 | Drift(SQLite ORM,schema 迁移记录在 `drift_schemas/`) |
| 路由 | go_router |
| 网络 | dio,配合 Talker 做日志 |
| 国际化 | Flutter 官方 l10n(.arb)+ Weblate 社区翻译 |

## 代码结构(`lib/`)

MVVM 分层架构:

- `core/` — 核心逻辑
- `database/` — Drift 数据库
- `models/` — 数据模型
- `repositories/` — 数据仓库层
- `services/` — 服务层
- `viewModels/` — 视图模型
- `ui/` — 界面
- `l10n/` — 国际化

## 开发命令

- 代码生成(Drift/Freezed 改动后必须运行):`just build_runner`
- 数据库迁移:`just make-migrations`
- 常规:`flutter analyze`、`flutter test`、`dart format .`(CI 强制格式化)

更多构建细节见 `AGENTS.md` 和 `justfile`。
