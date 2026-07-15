/// Lowercase hex encoding, shared by [generateUuidV4] and
/// `GameCrypto.nameHmac` (#102) rather than each hand-rolling the same
/// `toRadixString(16).padLeft(2, '0')` map.
String hex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
