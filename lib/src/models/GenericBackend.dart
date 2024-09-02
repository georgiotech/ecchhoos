abstract class GenericBackend {
  Map<String, dynamic> toJson();
  factory GenericBackend.fromJson(Map<String, dynamic> json) => throw UnimplementedError();
}
