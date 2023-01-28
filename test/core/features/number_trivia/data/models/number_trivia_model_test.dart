import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tdd_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:tdd_architecture/features/number_trivia/domain/entities/number_trivia.dart';

import '../../../../fixtures/fixture_reader.dart';

Future<void> main() async {
  const tNumberTriviaModel = NumberTriviaModel(number: 1, text: 'Test Text');
  test('should be a subclass of NumberTrivia entity', () async {
    expect(tNumberTriviaModel, isA<NumberTrivia>());
  });
  group('fromJson', () {
    test('should return a valid model when the JSON number is an integer', () {
      // arrange
      final Map<String, dynamic> jsonMap = json.decode(fixture('trivia.json'));

      // act
      final result = NumberTriviaModel.fromJson(jsonMap);

      //assert
      expect(result, equals(tNumberTriviaModel));
    });

    test('should return a valid model when the JSON number is an double', () {
      // arrange
      final Map<String, dynamic> jsonMap =
          json.decode(fixture('trivia_double.json'));

      // act
      final result = NumberTriviaModel.fromJson(jsonMap);

      //assert
      expect(result, equals(tNumberTriviaModel));
    });
  });

  group('toJson', () {
    test('should return a valid json Map containing the proper data', () async {
      //arrange

      //act
      final result = tNumberTriviaModel.toJson();

      //assert
      final expectedMap = {"text": "Test Text", "number": 1};

      expect(result, expectedMap);
    });
  });
}
