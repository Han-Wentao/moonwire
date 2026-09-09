# MoonWire example

```moonbit
let frame = @moonwire.Frame::new(1, 7, b"hello").unwrap()
let wire = @moonwire.encode(frame)
let decoded = @moonwire.decode(wire).unwrap()
assert_eq(decoded.payload(), b"hello")
```
