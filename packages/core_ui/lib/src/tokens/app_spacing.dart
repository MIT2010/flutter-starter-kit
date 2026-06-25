/// Design tokens untuk spacing dan ukuran.
/// Semua margin, padding, dan ukuran harus merujuk ke sini.
abstract class AppSpacing {
  AppSpacing._();

  // ── Spacing scale ─────────────────────────────────────────
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  // ── Border radius ─────────────────────────────────────────
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 100;

  // ── Icon size ─────────────────────────────────────────────
  static const double iconSm = 16;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 48;

  // ── Button height ─────────────────────────────────────────
  static const double buttonHeightSm = 36;
  static const double buttonHeightMd = 48;
  static const double buttonHeightLg = 56;

  // ── Input height ──────────────────────────────────────────
  static const double inputHeight = 52;

  // ── App bar height ────────────────────────────────────────
  static const double appBarHeight = 56;

  // ── Bottom nav height ─────────────────────────────────────
  static const double bottomNavHeight = 64;

  // ── Card ──────────────────────────────────────────────────
  static const double cardPadding = 16;
  static const double cardRadius = 16;

  // ── Screen padding ────────────────────────────────────────
  static const double screenPadding = 16;
  static const double screenPaddingLg = 24;
}
