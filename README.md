# MoonWire

MoonWire 是一个使用 MoonBit 编写的轻量、确定性的二进制帧编解码库，适合 MoonBit 应用、嵌入式通信原型和测试夹具。

## 功能

MoonWire 编解码一种固定格式的应用层帧：

```text
MW magic | version | kind | 3 字节大端 payload 长度 | checksum | payload
```

提供以下能力：

- 创建带版本和类型的帧；
- 将帧编码为字节序列；
- 从字节序列解码一个完整帧；
- 检查 magic、长度和 checksum；
- 返回稳定的错误标识，方便测试和上层处理；
- 使用纯 MoonBit API，支持多个 MoonBit 编译目标。

## 使用示例

```moonbit
let frame = @moonwire.Frame::new(1, 7, b"hello").unwrap()
let wire = @moonwire.encode(frame)
let same = @moonwire.decode(wire).unwrap()
```

## 功能边界

MoonWire 只负责应用层二进制帧的编码和解码，不负责：

- TCP、UDP 或其他传输层通信；
- 流式数据重组；
- 加密、认证或压缩；
- 硬件控制；
- HTTP、JSON-RPC 或数据库协议；
- 多种协议格式之间的自动协商。

## 验证

在项目根目录执行：

```text
moon fmt --check
moon check --target wasm-gc --deny-warn
moon check --target wasm --deny-warn
moon check --target js --deny-warn
moon check --target native --deny-warn
moon test --target wasm-gc
```

## 项目结构

- `moonwire.mbt`：核心帧类型、编码器和解码器；
- `moonwire_test.mbt`：正常路径和错误输入测试；
- `moon.mod`、`moon.pkg`：MoonBit 项目配置；
- `.github/workflows/ci.yml`：持续集成配置；
- `LICENSE`：MIT 许可证。

## 许可证

本项目采用 MIT 许可证，详见 `LICENSE`。
## 格式说明

固定头部占 8 字节：2 字节 magic、1 字节版本、1 字节类型、3 字节大端长度和 1 字节校验和。长度字段只描述 payload，不包含头部。解码器要求输入恰好是一帧，额外字节也会被拒绝。
## 错误处理

错误标识是稳定字符串：`frame.truncated.header`、`frame.magic`、`frame.truncated.payload`、`frame.checksum`。调用方可以用 `explain` 把标识转换为适合日志展示的说明。

`decode` 要求输入恰好包含一帧；当输入来自 TCP、串口或管道等可能连续到达多帧的来源时，使用 `decode_prefix`。它先读取 8 字节固定头，再依据三字节大端长度截取第一帧，并把剩余字节原样返回。`parse_header` 和 `checksum_matches` 适合在不需要构造 `Frame` 时做元数据检查或校验。

长度字段的范围是 0 到 `max_payload_length()`（16,777,215），版本和类型字段的范围都是 0 到 255。`encode_checked` 用于调用方尚未把字段保存为已校验值的场景；如果已经有 `Frame`，直接调用 `encode`。

## API 快速参考

- `Frame::new(version, kind, payload)`：创建并校验帧；
- `encode(frame)` / `decode(bytes)`：完整帧编解码；
- `decode_prefix(bytes)`：解码第一帧并保留尾部字节；
- `parse_header(bytes)`：只读取固定头部元数据；
- `validate(bytes)` / `is_valid(bytes)`：检查完整帧；
- `encode_checked(...)`：从基础字段安全编码；
- `checksum_matches(bytes)`：检查完整帧校验和。
