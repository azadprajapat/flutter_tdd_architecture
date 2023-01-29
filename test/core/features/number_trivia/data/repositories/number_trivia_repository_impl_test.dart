import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_architecture/core/errors/exceptions.dart';
import 'package:tdd_architecture/core/errors/failures.dart';
import 'package:tdd_architecture/core/platform/network_info.dart';
import 'package:tdd_architecture/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:tdd_architecture/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:tdd_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:tdd_architecture/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:tdd_architecture/features/number_trivia/domain/entities/number_trivia.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

Future<void> main() async {
  NumberTriviaRepositoryImpl? repository;
  MockRemoteDataSource? mockRemoteDataSource;
  MockLocalDataSource? mockLocalDataSource;
  MockNetworkInfo? mockNetworkInfo;

  setUpAll(() {});

  group('getConcreteNumberTrivia ', () {
    mockLocalDataSource = MockLocalDataSource();
    mockRemoteDataSource = MockRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();

    repository = NumberTriviaRepositoryImpl(
        remoteDataSource: mockRemoteDataSource!,
        localDataSource: mockLocalDataSource!,
        networkInfo: mockNetworkInfo!);
    const tNumber = 1;
    const tNumberTriviaModel =
        NumberTriviaModel(text: 'test trivia', number: tNumber);
    const tNumberTrivia = NumberTrivia(text: 'test trivia', number: tNumber);

    test('Should Check if the device is online', () async {
      //arrange
      when(mockNetworkInfo!.isConnected)
          .thenAnswer((realInvocation) async => true);

      //act
      repository!.getConcreteNumberTrivia(tNumber);

      // assert
      verify(mockNetworkInfo!.isConnected);
    });
    group('device is online', () {
      when(mockNetworkInfo!.isConnected)
          .thenAnswer((realInvocation) async => true);
      test(
          'should return remote data when the call to remote data source is successful',
          () async {
        //arrange
        when(mockRemoteDataSource!.getConcreteNumberTrivia(tNumber))
            .thenAnswer((_) async => tNumberTriviaModel);
        //act
        final result = await repository!.getConcreteNumberTrivia(tNumber);

        //assert
        verify(mockRemoteDataSource!.getConcreteNumberTrivia(tNumber));
        expect(result, equals(const Right(tNumberTrivia)));
      });

      test(
          'should cache the data locally when the call to remote data source is successful',
          () async {
        //arrange
        when(mockRemoteDataSource!.getConcreteNumberTrivia(tNumber))
            .thenAnswer((_) async => tNumberTriviaModel);
        //act
        await repository!.getConcreteNumberTrivia(tNumber);

        //assert
        verify(mockRemoteDataSource!.getConcreteNumberTrivia(tNumber));
        verify(mockLocalDataSource!.cacheNumberTrivia(tNumberTriviaModel));
      });

      test(
          'should return server failure when the call to remote data source is unsuccessful',
          () async {
        //arrange
        when(mockRemoteDataSource!.getConcreteNumberTrivia(tNumber))
            .thenThrow(ServerException());
        //act
        final result = await repository!.getConcreteNumberTrivia(tNumber);
        //assert

        verify(mockRemoteDataSource!.getConcreteNumberTrivia(tNumber));
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, equals(Left(ServerFailure())));
      });
    });
    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo!.isConnected)
            .thenAnswer((realInvocation) async => false);
      });
      test('should return last locally cached data when the cache is present',
          () async {
        when(mockLocalDataSource!.getLastNumberTrivia())
            .thenAnswer((realInvocation) async => tNumberTriviaModel);
        final result = await repository!.getConcreteNumberTrivia(tNumber);
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource!.getLastNumberTrivia());
        expect(result, equals(const Right(tNumberTrivia)));
      });

      test('should return cache failure where there is no cache data present',
          () async {
        when(mockLocalDataSource!.getLastNumberTrivia())
            .thenThrow(CacheException());
        //act
        final result = await repository!.getConcreteNumberTrivia(tNumber);
        //assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource!.getLastNumberTrivia());
        expect(result, equals(Left(CacheFailure())));
      });
    });
  });
}
