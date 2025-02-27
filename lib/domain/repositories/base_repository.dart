import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

abstract class BaseRepository<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}