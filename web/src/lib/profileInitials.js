/** Two-letter initials for avatar fallback (Latin script). */
export function getDisplayInitials(name) {
  const bits = String(name || "")
    .trim()
    .split(/\s+/)
    .filter(Boolean);
  if (!bits.length) {
    return "?";
  }
  if (bits.length === 1) {
    return bits[0].slice(0, 2).toUpperCase();
  }
  const a = bits[0].charAt(0);
  const b = bits[bits.length - 1].charAt(0);
  return `${a}${b}`.toUpperCase();
}
