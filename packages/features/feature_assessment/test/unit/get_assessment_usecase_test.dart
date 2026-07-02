import 'package:core/core.dart';
import 'package:feature_assessment/feature_assessment.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_assessment/shared_assessment.dart';

import 'get_assessment_usecase_test.mocks.dart';

@GenerateMocks([AssessmentRepository])
void main() {
  late GetAssessmentUseCase useCase;
  late MockAssessmentRepository mockRepository;

  const tAssessment = AssessmentEntity(
    id: 'assessment-1',
    title: 'Tes Kepribadian',
    chapters: [],
  );

  setUp(() {
    mockRepository = MockAssessmentRepository();
    useCase = GetAssessmentUseCase(mockRepository);

    provideDummy<Either<Failure, AssessmentEntity>>(Either.right(tAssessment));
  });

  test('harus mengembalikan AssessmentEntity saat berhasil', () async {
    when(
      mockRepository.getAssessment('assessment-1'),
    ).thenAnswer((_) async => Either.right(tAssessment));

    final result = await useCase('assessment-1');

    expect(result, Either.right(tAssessment));
    verify(mockRepository.getAssessment('assessment-1'));
    verifyNoMoreInteractions(mockRepository);
  });

  test(
    'harus mengembalikan ValidationFailure saat assessmentId kosong',
    () async {
      final result = await useCase('');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Seharusnya gagal'),
      );
      verifyNever(mockRepository.getAssessment(any));
    },
  );

  test('harus meneruskan Failure dari repository apa adanya', () async {
    when(
      mockRepository.getAssessment('assessment-1'),
    ).thenAnswer((_) async => Either.left(const NetworkFailure()));

    final result = await useCase('assessment-1');

    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure, isA<NetworkFailure>()),
      (_) => fail('Seharusnya gagal'),
    );
  });
}
