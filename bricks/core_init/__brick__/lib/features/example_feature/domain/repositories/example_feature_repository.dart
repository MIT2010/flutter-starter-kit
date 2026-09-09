import '../../../../core/failure.dart';
import '../../../../core/result.dart';
import '../../data/models/example_item_model.dart';

/// What the presentation layer depends on — never the concrete
/// implementation. Lets the cubit be unit-tested against a mock without
/// touching Dio/Hive at all.
abstract class ExampleFeatureRepository {
  Future<Result<Failure, ExampleItem>> getExampleItem();
}
