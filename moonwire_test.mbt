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

///|
test "length and checksum rejection" {
  let wrong_length = Buffer()
  wrong_length.write_bytes(b"MW")
  wrong_length.write_byte((1 : Int).to_byte())
  wrong_length.write_byte((2 : Int).to_byte())
  wrong_length.write_byte((0 : Int).to_byte())
  wrong_length.write_byte((0 : Int).to_byte())
  wrong_length.write_byte((4 : Int).to_byte())
  wrong_length.write_byte((0 : Int).to_byte())
  wrong_length.write_byte((97 : Int).to_byte())
  wrong_length.write_byte((98 : Int).to_byte())
  wrong_length.write_byte((99 : Int).to_byte())
  assert_true(decode(wrong_length.to_bytes()) is Err("frame.truncated.payload"))
  let wrong_checksum = Buffer()
  wrong_checksum.write_bytes(encode(Frame::new(1, 2, b"abc").unwrap())[:7])
  wrong_checksum.write_byte((0 : Int).to_byte())
  wrong_checksum.write_bytes(b"abc")
  assert_true(decode(wrong_checksum.to_bytes()) is Err("frame.checksum"))
}

///|
test "header metadata" {
  let bytes = encode(Frame::new(12, 34, b"x").unwrap())
  assert_eq(header_version(bytes).unwrap(), 12)
  assert_eq(header_kind(bytes).unwrap(), 34)
}

///|
test "frame size" {
  let frame = Frame::new(1, 1, b"moon").unwrap()
  assert_eq(frame.encoded_size(), encode(frame).length())
}
