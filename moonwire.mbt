///|
/// A decoded application frame.
pub struct Frame {
  version : Int
  kind : Int
  payload : Bytes
}

///|
pub fn Frame::new(
  version : Int,
  kind : Int,
  payload : Bytes,
) -> Result[Frame, String] {
  if version < 0 || version > 255 {
    Err("frame.version.range")
  } else if kind < 0 || kind > 255 {
    Err("frame.kind.range")
  } else if payload.length() > 16777215 {
    Err("frame.payload.too_large")
  } else {
    Ok({ version, kind, payload })
  }
}

///|
pub fn Frame::version(self : Frame) -> Int {
  self.version
}

///|
pub fn Frame::kind(self : Frame) -> Int {
  self.kind
}

///|
pub fn Frame::payload(self : Frame) -> Bytes {
  self.payload
}

///|
/// Encode as magic(2), version(1), kind(1), length(3), payload.
pub fn encode(frame : Frame) -> Bytes {
  let n = frame.payload.length()
  let out = Buffer()
  out.write_byte((77 : Int).to_byte())
  out.write_byte((87 : Int).to_byte())
  out.write_byte(frame.version.to_byte())
  out.write_byte(frame.kind.to_byte())
  out.write_byte((n / 65536).to_byte())
  out.write_byte((n / 256 % 256).to_byte())
  out.write_byte((n % 256).to_byte())
  out.write_byte(checksum(frame.version, frame.kind, frame.payload).to_byte())
  out.write_bytes(frame.payload)
  out.to_bytes()
}

///|
fn checksum(version : Int, kind : Int, payload : Bytes) -> Int {
  let mut x = version ^ kind
  for b in payload {
    x = (x + b.to_int()) % 256
  }
  x
}

///|
pub fn decode(data : Bytes) -> Result[Frame, String] {
  if data.length() < 8 {
    return Err("frame.truncated.header")
  }
  if data[0] != 0x4d || data[1] != 0x57 {
    return Err("frame.magic")
  }
  let n = data[4].to_int() * 65536 + data[5].to_int() * 256 + data[6].to_int()
  if data.length() != 8 + n {
    return Err("frame.truncated.payload")
  }
  let payload = data[8:].to_owned()
  let version = data[2].to_int()
  let kind = data[3].to_int()
  if data[7].to_int() != checksum(version, kind, payload) {
    return Err("frame.checksum")
  }
  Ok({ version, kind, payload })
}

///|
/// Return a stable human-readable error category.
pub fn explain(error : String) -> String {
  match error {
    "frame.magic" => "invalid MoonWire magic"
    "frame.checksum" => "payload checksum mismatch"
    "frame.truncated.header" => "frame header is incomplete"
    "frame.truncated.payload" =>
      "frame payload is incomplete or has trailing bytes"
    _ => "invalid frame"
  }
}

///|
/// Return the encoded frame size for a payload.
pub fn encoded_size(payload_length : Int) -> Result[Int, String] {
  if payload_length < 0 || payload_length > 16777215 {
    Err("frame.payload.range")
  } else {
    Ok(8 + payload_length)
  }
}

///|
/// Return the payload length encoded in a valid frame header.
pub fn payload_length(data : Bytes) -> Result[Int, String] {
  if data.length() < 8 {
    Err("frame.truncated.header")
  } else if data[0] != 0x4d || data[1] != 0x57 {
    Err("frame.magic")
  } else {
    Ok(data[4].to_int() * 65536 + data[5].to_int() * 256 + data[6].to_int())
  }
}

///|
/// Check whether bytes contain exactly one valid frame.
pub fn is_valid(data : Bytes) -> Bool {
  decode(data) is Ok(_)
}

///|
/// Compute the checksum used by the frame format.
pub fn frame_checksum(
  version : Int,
  kind : Int,
  payload : Bytes,
) -> Result[Int, String] {
  if version < 0 || version > 255 || kind < 0 || kind > 255 {
    Err("frame.invalid")
  } else if payload.length() > 16777215 {
    Err("frame.invalid")
  } else {
    Ok(checksum(version, kind, payload))
  }
}

///|
/// Return the version from a valid header.
pub fn header_version(data : Bytes) -> Result[Int, String] {
  if data.length() < 8 {
    Err("frame.truncated.header")
  } else if data[0] != 0x4d || data[1] != 0x57 {
    Err("frame.magic")
  } else {
    Ok(data[2].to_int())
  }
}

///|
/// Return the kind from a valid header.
pub fn header_kind(data : Bytes) -> Result[Int, String] {
  if data.length() < 8 {
    Err("frame.truncated.header")
  } else if data[0] != 0x4d || data[1] != 0x57 {
    Err("frame.magic")
  } else {
    Ok(data[3].to_int())
  }
}

///|
/// Return the encoded size of this frame.
pub fn Frame::encoded_size(self : Frame) -> Int {
  8 + self.payload.length()
}
