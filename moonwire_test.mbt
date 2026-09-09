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
