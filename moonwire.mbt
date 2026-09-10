///|
const MAGIC_FIRST : Byte = 0x4d

///|
const MAGIC_SECOND : Byte = 0x57

///|
const HEADER_SIZE : Int = 8

///|
const MAX_PAYLOAD : Int = 16777215

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
  } else if payload.length() > MAX_PAYLOAD {
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
  out.write_byte(MAGIC_FIRST)
  out.write_byte(MAGIC_SECOND)
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
  if data.length() < HEADER_SIZE {
    return Err("frame.truncated.header")
  }
  if data[0] != MAGIC_FIRST || data[1] != MAGIC_SECOND {
    return Err("frame.magic")
  }
  let n = data[4].to_int() * 65536 + data[5].to_int() * 256 + data[6].to_int()
  if data.length() != HEADER_SIZE + n {
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
    Ok(HEADER_SIZE + payload_length)
  }
}

///|
/// Return the payload length encoded in a valid frame header.
pub fn payload_length(data : Bytes) -> Result[Int, String] {
  if data.length() < HEADER_SIZE {
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
  } else if payload.length() > MAX_PAYLOAD {
    Err("frame.invalid")
  } else {
    Ok(checksum(version, kind, payload))
  }
}

///|
/// Return the version from a valid header.
pub fn header_version(data : Bytes) -> Result[Int, String] {
  if data.length() < HEADER_SIZE {
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
  if data.length() < HEADER_SIZE {
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
  HEADER_SIZE + self.payload.length()
}

///|
/// Metadata read from a frame header.
pub struct Header {
  version : Int
  kind : Int
  payload_length : Int
  checksum : Int
}

///|
/// Parse and validate the fixed-size header without decoding the payload.
pub fn parse_header(data : Bytes) -> Result[Header, String] {
  if data.length() < HEADER_SIZE {
    Err("frame.truncated.header")
  } else if data[0] != MAGIC_FIRST || data[1] != MAGIC_SECOND {
    Err("frame.magic")
  } else {
    Ok({
      version: data[2].to_int(),
      kind: data[3].to_int(),
      payload_length: data[4].to_int() * 65536 +
      data[5].to_int() * 256 +
      data[6].to_int(),
      checksum: data[7].to_int(),
    })
  }
}

///|
/// Get the version from parsed header metadata.
pub fn Header::version(self : Header) -> Int {
  self.version
}

///|
/// Get the kind from parsed header metadata.
pub fn Header::kind(self : Header) -> Int {
  self.kind
}

///|
/// Get the payload length from parsed header metadata.
pub fn Header::payload_length(self : Header) -> Int {
  self.payload_length
}

///|
/// Get the stored checksum from parsed header metadata.
pub fn Header::checksum(self : Header) -> Int {
  self.checksum
}

///|
/// Decode the first frame in data and return trailing bytes separately.
pub fn decode_prefix(data : Bytes) -> Result[(Frame, Bytes), String] {
  match parse_header(data) {
    Err(error) => Err(error)
    Ok(header) => {
      let total = HEADER_SIZE + header.payload_length()
      if data.length() < total {
        Err("frame.truncated.payload")
      } else {
        match decode(data[:total].to_owned()) {
          Err(error) => Err(error)
          Ok(frame) => Ok((frame, data[total:].to_owned()))
        }
      }
    }
  }
}

///|
/// Validate a frame without allocating a decoded payload for callers.
pub fn validate(data : Bytes) -> Result[Unit, String] {
  match decode(data) {
    Err(error) => Err(error)
    Ok(_) => Ok(())
  }
}

///|
/// Return the maximum payload size representable by the wire format.
pub fn max_payload_length() -> Int {
  MAX_PAYLOAD
}

///|
/// Return the fixed header size in bytes.
pub fn header_size() -> Int {
  HEADER_SIZE
}

///|
/// Compare two frames by all wire-visible fields.
pub fn Frame::same(self : Frame, other : Frame) -> Bool {
  self.version == other.version &&
  self.kind == other.kind &&
  self.payload == other.payload
}

///|
/// Encode a frame from primitive fields after applying constructor checks.
pub fn encode_checked(
  version : Int,
  kind : Int,
  payload : Bytes,
) -> Result[Bytes, String] {
  match Frame::new(version, kind, payload) {
    Err(error) => Err(error)
    Ok(frame) => Ok(encode(frame))
  }
}

///|
/// Check the stored checksum in a complete frame without returning its payload.
pub fn checksum_matches(data : Bytes) -> Result[Bool, String] {
  match parse_header(data) {
    Err(error) => Err(error)
    Ok(header) => {
      let total = HEADER_SIZE + header.payload_length()
      if data.length() != total {
        Err("frame.truncated.payload")
      } else {
        let payload = data[HEADER_SIZE:].to_owned()
        Ok(
          header.checksum() ==
          checksum(header.version(), header.kind(), payload),
        )
      }
    }
  }
}

///|
/// Return the total number of bytes required by a parsed header.
pub fn Header::total_size(self : Header) -> Int {
  HEADER_SIZE + self.payload_length
}
