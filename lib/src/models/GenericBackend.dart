import 'package:uuid/uuid.dart';

abstract class GenericBackend {
  final String uuid;

  GenericBackend({required this.uuid});

  static String generateUuid() {
    return Uuid().v4();
  }

  Map<String, dynamic> toJson();
  factory GenericBackend.fromJson(Map<String, dynamic> json) => throw UnimplementedError();
}
