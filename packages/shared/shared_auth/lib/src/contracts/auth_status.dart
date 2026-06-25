/// Status autentikasi user.
enum AuthStatus {
  /// Sedang mengecek status — belum tahu authenticated atau tidak
  checking,

  /// User sudah login
  authenticated,

  /// User belum login
  unauthenticated,
}
