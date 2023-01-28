import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  List<Object> properties;
  Failure([this.properties = const <Object>[]]);

  @override
  List<Object> get props => properties;

  @override
  bool get stringify => false;
}

//general Failures

class ServerFailure extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

class CacheFailure extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}
