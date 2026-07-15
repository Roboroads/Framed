import 'package:characters/characters.dart';
import 'package:unorm_dart/unorm_dart.dart' as unorm;

/// Cap on a player's stored/displayed name (#79) -- the 2048-char ceiling
/// on `name_ciphertext` server-side (13-lobby.sql) is a ciphertext-size
/// sanity check, not a "this is a reasonable name" cap. Counts
/// user-perceived characters (grapheme clusters, #103), not UTF-16 code
/// units -- a `String.substring` cut can land inside a surrogate pair
/// (most emoji) or split a base character from its combining mark.
const maxDisplayNameLength = 40;

/// Unicode code points with no legitimate use in a display name, only
/// spoofing potential: bidi direction overrides/isolates (can visually
/// reverse or reorder the string -- e.g. hide a swapped character by
/// making the string render right-to-left) and zero-width joiners/spaces
/// (can split or fake-merge characters invisibly). Listed as decimal code
/// points and built via String.fromCharCode rather than embedding the
/// characters themselves (invisible by definition) in this source file,
/// so the set actually being matched stays reviewable.
const _spoofingCodePoints = [
  0x200B, 0x200C, 0x200D, 0x200E, 0x200F, // zero-width space/ZWNJ/ZWJ/LRM/RLM
  0x202A, 0x202B, 0x202C, 0x202D, 0x202E, // LRE/RLE/PDF/LRO/RLO
  0x2066, 0x2067, 0x2068, 0x2069, // LRI/RLI/FSI/PDI
  0xFEFF, // zero-width no-break space / BOM
];

final _spoofingChars = RegExp(
  '[${_spoofingCodePoints.map(String.fromCharCode).join()}]',
);

/// Strips spoofing-only characters, applies Unicode NFKC normalization
/// (unifies compatibility-equivalent forms -- full-width vs normal width,
/// ligatures, etc.), and caps length. Does NOT catch cross-script
/// homoglyphs (a Cyrillic look-alike of a Latin letter) -- that needs a
/// full confusables-skeleton table (Unicode TR39), scoped out of #79's
/// fix.
///
/// Called once at the point a name is first captured (pre-join/host
/// setup), so the stored/displayed value and the dedup hash
/// ([GameCrypto.nameHmac], which also calls this) work from the same
/// clean string.
String sanitizeDisplayName(String raw) {
  var name = raw.trim().replaceAll(_spoofingChars, '');
  name = unorm.nfkc(name);
  name = name.trim();
  if (name.characters.length > maxDisplayNameLength) {
    name = name.characters.take(maxDisplayNameLength).toString().trim();
  }
  return name;
}
