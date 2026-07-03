import 'package:fpdart/fpdart.dart';
import '../error/failure.dart';

export 'package:fpdart/fpdart.dart'
    show Either, Left, Right, Unit, left, right, unit;

/// Shorthand untuk return type yang bisa gagal atau berhasil.
///
/// Dibaca sebagai: "Future yang hasilnya Either Failure atau T"
typedef FutureEither<T> = Future<Either<Failure, T>>;

/// Untuk operasi yang tidak mengembalikan nilai saat sukses
typedef FutureEitherVoid = Future<Either<Failure, Unit>>;
