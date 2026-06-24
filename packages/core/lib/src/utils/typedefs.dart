import 'package:fpdart/fpdart.dart';
import '../error/failure.dart';

/// Shorthand untuk return type yang bisa gagal atau berhasil.
///
/// Contoh penggunaan di use case:
///   FutureEither<UserEntity> login(String email, String password)
///
/// Dibaca sebagai: "Future yang hasilnya Either Failure atau T"
typedef FutureEither<T> = Future<Either<Failure, T>>;

/// Untuk operasi yang tidak mengembalikan nilai saat sukses
typedef FutureEitherVoid = Future<Either<Failure, Unit>>;
