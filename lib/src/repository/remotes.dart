import 'dart:convert';
import 'package:ecchhoos/src/models/GenericBackend.dart';
import 'package:ecchhoos/src/models/MinioBackend.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RemotesRepository {
  List<GenericBackend> registeredRemotes;

  // Serialize RemotesRepository to JSON
  Map<String, dynamic> toJson() {
    return {
      'registeredRemotes': registeredRemotes.map((remote) => remote.toJson()).toList(),
    };
  }

  RemotesRepository({required this.registeredRemotes});

  factory RemotesRepository.empty() {
    return RemotesRepository(registeredRemotes: []);
  }

  // Assuming you have a fromJson factory constructor
  factory RemotesRepository.fromJson(Map<String, dynamic> json) {
    var list = (json['registeredRemotes'] as List<dynamic>);
    return RemotesRepository(
      registeredRemotes: list.map((e) {
        if (e['type'] == 'minio') {
          return MinioBackend.fromJson(e);
        }
        return GenericBackend.fromJson(e);
      }).toList(),
    );
  }

  // TODO: Save to secure storage instead?
  // Save MinioRepository to shared preferences
  Future<void> saveToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(toJson());
      await prefs.setString('remotes', jsonString);
    } catch (e) {
      // Handle any errors here
      print('Failed to save remotes: $e');
    }
  }

  // Load MinioRepository from shared preferences
  static Future<RemotesRepository?> loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('remotes');
      if (jsonString == null) return null;
      final jsonMap = jsonDecode(jsonString);
      return RemotesRepository.fromJson(jsonMap);
    } catch (e) {
      // Handle any errors here
      print('Failed to load remotes: $e');
      return null;
    }
  }

  void updateRemote(GenericBackend remote) {
    registeredRemotes.removeWhere((element) => element.uuid == remote.uuid);
    registeredRemotes.add(remote);
  }

  void removeRemote(String uuid) {
    registeredRemotes.removeWhere((element) => element.uuid == uuid);
  }

  // temporary solution to create a first remote since there's no UI for it yet
  // FIXME: don't assume MinioBackend
  MinioBackend createNewRemote() {
    final newRemote = MinioBackend(
      uuid: GenericBackend.generateUuid(),
      endpoint: 'localhost',
      port: 9330,
      accessKey: '<secret>',
      secretKey: '<secret>',
      bucketName: '',
      pathPrefix: '',
    );
    registeredRemotes.add(newRemote);
    return newRemote;
  }
}
