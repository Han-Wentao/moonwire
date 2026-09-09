# MoonWire 竞赛查重报告

- 检查日期：2026-09-09
- 候选项目：MoonWire
- 参赛方向：2026 MoonBit 国产基础软件生态开源大赛 8 月黑客松（按本地活动说明执行）
- 项目仓库：https://github.com/Han-Wentao/moonwire
- 查重辅助：已检查并执行本地 `$osc2026-guide`（`C:\Users\42673\.codex\skills\osc2026-guide\SKILL.md`）的项目研究与查重要求。

## 1. 候选项目范围

MoonWire 是一个使用 MoonBit 实现的确定性二进制应用层帧编解码库。当前固定格式为：`MW` magic、版本、消息类型、三字节大端 payload 长度、一字节 additive checksum、payload。核心 API 负责构造、编码、解码和稳定错误标识。

明确不包含：传输层、流式重组、加密、认证、压缩、硬件控制、HTTP/API contract、benchmark、日志治理、账本、队列、分片同步和日历 recurrence。

## 2. 搜索方法与结果

### 2.1 MoonCakes

按 `$osc2026-guide` 要求尝试使用本地工具：

```text
moon search MoonWire --limit 20
moon search binary framing --limit 20
```

当前安装的 MoonBit 工具链没有 `moon search` 子命令，返回 `no such subcommand: search`；系统中也未发现可调用的 `moon-search` 可执行文件。因此本报告没有把本地搜索失败伪装成成功结果。

随后使用 MoonCakes 文档站点进行网页检索，搜索词包括：

- MoonWire
- binary framing
- binary frame
- length-prefixed binary
- checksum framing
- protocol framing
- embedded framing

结果：截至 2026-09-09，未发现名为 `MoonWire` 或 `Han-Wentao/moonwire` 的 MoonCakes 包页面，也未发现一个以同样的固定 `magic + version + kind + 3-byte length + additive checksum + payload` 格式为核心的成熟 MoonBit 包。网页搜索出现的 `lockwire` 等结果与本项目能力不重合，未作为同类项目处理。

### 2.2 GitHub / MoonBit 仓库

搜索词包括：

- `MoonWire MoonBit`
- `binary framing MoonBit`
- `length-prefixed frame MoonBit`
- `checksum protocol MoonBit`

检查了候选仓库名称、README/项目描述和与 MoonBit 生态相关的结果。未发现同名项目或核心工作流高度重合的成熟 MoonBit 仓库。

### 2.3 本地项目登记表

对照 `C:\Users\42673\.codex\skills\moonbit-hackathon-builder\references\project-registry.md` 中已有项目，发现以下相邻但不重复的项目：

| 项目 | 相邻能力 | 与 MoonWire 的区别 |
|---|---|---|
| MoonBench | 基准测试和回归分析 | 不负责协议帧编码/解码 |
| MoonContract | OpenAPI contract/mock | 面向 HTTP/API 合约，不是二进制帧 |
| MoonRecur | 日历 recurrence | 数据模型和工作流完全不同 |
| MoonShard | content-defined chunking | 分片同步/内容分块，不是有头帧协议 |
| MoonDispatch | 队列与调度 | 负责任务投递和调度，不解析帧 |
| MoonEDI | ANSI X12 envelope/997 | 面向 EDI 文本信封和确认，不是通用二进制帧 |
| MoonLedger | 双重记账和账本分析 | 面向财务日志与报表，不是协议编解码 |
| MoonQuotaKit | 配额、限流和公平调度 | 不处理二进制协议帧 |

## 3. 重叠分类

- 名称重叠：未发现。
- 核心数据重叠：未发现。MoonWire 的核心数据是帧元数据、三字节长度、checksum 和 byte payload。
- 主要工作流重叠：未发现高度重合项目。
- 通用技术重叠：字节数组读写、边界检查和错误处理属于通用基础能力，不构成项目级重复。
- 风险等级：低；但由于本地 `moon search` 命令不可用，MoonCakes 结果应在工具链升级后再次复核。

## 4. 差异化结论

MoonWire 的永久指纹是：**确定性长度前缀二进制帧的编码/解码，包含 magic、版本/类型元数据、三字节 payload 长度、checksum 和稳定诊断**。

该项目不是已有 registry 项目的改名、包装或简单拼接，也没有复用其核心实现。它提供一个小而明确、可嵌入、跨目标的 MoonBit 基础库边界；未来如果扩展到传输、分片、加密或 HTTP 合约，应视为新的范围并重新做查重。

## 5. `$osc2026-guide` 自查结论

辅助 Skill 已安装并读取。按其 8 月黑客松活动说明检查：

- MoonBit 为主要实现语言：通过。
- 公开 GitHub 仓库：通过。
- README、测试、CI、版本发布和可追踪提交：已有。
- 主题避免与成熟 MoonBit 项目高度重复：本次证据支持通过。
- AI 辅助内容：需要由参赛者对代码可解释性、测试、维护性、来源和许可证合规负责；本项目未引入来源不明的第三方代码。
- 参考规模：活动说明给出 4,000--10,000 行有效 MoonBit 代码作为参考，不是硬性行数门槛；当前项目规模明显低于该参考值，是竞争力和验收风险，不能用文档数量替代实现规模。
- MoonCakes 发布：尚未完成，不能宣称已经通过最终验收。原 `moonbit-hackathon-builder` 工作流明确不代为发布 MoonCakes；该步骤需参赛者按官方流程手动完成，或另行明确请求协助。

## 6. 决策

**查重决策：PROCEED（可以继续作为独立候选项目），附条件：**

1. 在 MoonBit 工具链提供 `moon search` 后重新执行关键词检索；
2. 发布到 MoonCakes 前将 `moon.mod` 的模块名和仓库地址改为真实值，并以发布结果复核；
3. 在提交或验收前补充至少一个真实可运行示例，并评估是否增加更多生产级能力和测试，以回应当前源码规模偏小的风险；
4. 不把“未发现同类”表述成 MoonCakes 已发布或官方认可。

本报告只证明截至 2026-09-09 的查重证据和差异化判断，不等同于官方初审或验收结果。
