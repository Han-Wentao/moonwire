///|
test "round trip" {
  let payload = b"hello"
  let frame = Frame::new(1, 7, payload).unwrap()
  let decoded = decode(encode(frame)).unwrap()
  assert_eq(decoded.version(), 1)
  assert_eq(decoded.kind(), 7)
  assert_eq(decoded.payload(), payload)
}

///|
test "diagnostics" {
  assert_true(decode(b"MW") is Err(_))
  assert_eq(explain("frame.magic"), "invalid MoonWire magic")
  let frame = Frame::new(1, 2, b"x").unwrap()
  let bytes = encode(frame)
  assert_eq(decode(b"XX").unwrap_err(), "frame.truncated.header")
  assert_eq(decode(bytes).unwrap().kind(), 2)
}

///|
test "checksum" {
  let frame = Frame::new(3, 4, b"abc").unwrap()
  let bytes = encode(frame)
  let altered = encode(Frame::new(3, 4, b"abd").unwrap())
  assert_true(bytes != altered)
}

///|
test "constructor boundaries" {
  assert_true(Frame::new(-1, 0, b"") is Err("frame.version.range"))
  assert_true(Frame::new(0, 256, b"") is Err("frame.kind.range"))
  assert_eq(encoded_size(0).unwrap(), 8)
  assert_eq(encoded_size(16777215).unwrap(), 16777223)
  assert_true(encoded_size(-1) is Err("frame.payload.range"))
}

///|
test "header inspection" {
  let bytes = encode(Frame::new(9, 4, b"data").unwrap())
  assert_eq(payload_length(bytes).unwrap(), 4)
  assert_true(payload_length(b"bad") is Err("frame.truncated.header"))
  assert_true(payload_length(b"XX000000") is Err("frame.magic"))
  assert_true(is_valid(bytes))
}
