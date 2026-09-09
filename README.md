# MoonWire

MoonWire is a small, deterministic length-prefixed binary framing library for MoonBit applications, embedded links, and test fixtures. It is an original project for the September 2026 MoonBit Hackathon.

## Scope

The library encodes exactly one application frame: a two-byte `MW` magic, version, kind, three-byte payload length, checksum, and payload. It does not implement transport, encryption, compression, streaming reassembly, or a competing serialization format.

## Example

```moonbit
let frame = @moonwire.Frame::new(1, 7, b"hello").unwrap()
let wire = @moonwire.encode(frame)
let same = @moonwire.decode(wire).unwrap()
```

Malformed magic, truncation, length mismatch, and checksum errors return stable string diagnostics. Run `moon test --target wasm-gc` to verify the examples and negative cases.

## Verification

```text
moon fmt --check
moon check --target wasm-gc --deny-warn
moon check --target wasm --deny-warn
moon check --target js --deny-warn
moon check --target native --deny-warn
moon test --target wasm-gc
```

## License

MIT. See `LICENSE`. AI assistance is disclosed in `AI_USAGE.md`.
