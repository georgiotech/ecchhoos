import 'package:ecchhoos/src/models/MinioBackend.dart';
import 'package:ecchhoos/src/repository/remotes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('RemotesRepository', () {
    setUp(() {
      // Use the mock shared preferences for testing
      SharedPreferences.setMockInitialValues({});
    });

    test('MinioBackend should generate UUID if none is provided', () {
      // Create a MinioBackend without providing a UUID
      final minioBackend = MinioBackend(
        endpoint: 'https://example.com',
        port: 9330,
        useSSL: true,
        accessKey: 'accessKey123',
        secretKey: 'secretKey123',
        bucketName: 'transcriptions',
        pathPrefix: 'podcasts/',
      );

      // Check that a UUID was automatically generated
      expect(minioBackend.uuid, isA<String>());
      expect(minioBackend.uuid, matches(RegExp(r'^[a-f0-9-]{36}$')));

      // Create another MinioBackend to ensure UUIDs are unique
      final anotherMinioBackend = MinioBackend(
        endpoint: 'https://another-example.com',
        port: 9331,
        useSSL: false,
        accessKey: 'anotherAccessKey',
        secretKey: 'anotherSecretKey',
        bucketName: 'another-bucket',
        pathPrefix: 'another-prefix/',
      );

      // Check that the UUIDs are different
      expect(minioBackend.uuid, isNot(equals(anotherMinioBackend.uuid)));
    });

    test('toJson and fromJson should work correctly', () {
      // Create a sample MinioBackend
      final minioRepo = MinioBackend(
        endpoint: 'https://example.com',
        port: 9330,
        useSSL: true,
        accessKey: 'accessKey123',
        secretKey: 'secretKey123',
        bucketName: 'transcriptions',
        pathPrefix: 'podcasts/',
      );

      // Create a RemotesRepository with the sample MinioRepository
      final remotesRepo = RemotesRepository(registeredRemotes: [minioRepo]);

      // Serialize to JSON
      final json = remotesRepo.toJson();
      expect(json['registeredRemotes'][0]['type'], 'minio');

      // Deserialize from JSON
      final deserializedRepo = RemotesRepository.fromJson(json);

      // Check that the deserialized object matches the original
      expect(deserializedRepo.registeredRemotes.length, remotesRepo.registeredRemotes.length);
      var repoRecreated = deserializedRepo.registeredRemotes[0] as MinioBackend;

      expect(repoRecreated.endpoint, minioRepo.endpoint);
      expect(repoRecreated.port, minioRepo.port);
      expect(repoRecreated.useSSL, minioRepo.useSSL);
      expect(repoRecreated.accessKey, minioRepo.accessKey);
      expect(repoRecreated.secretKey, minioRepo.secretKey);
      expect(repoRecreated.uuid, minioRepo.uuid);
    });

    test('saveToPreferences and loadFromPreferences should work correctly', () async {
      // Create a sample MinioBackend
      final minioRepo = MinioBackend(
        endpoint: 'https://example.com',
        port: 9330,
        useSSL: true,
        accessKey: 'accessKey123',
        secretKey: 'secretKey123',
        bucketName: 'transcriptions',
        pathPrefix: 'podcasts/',
      );

      // Create a RemotesRepository with the sample MinioRepository
      final remotesRepo = RemotesRepository(registeredRemotes: [minioRepo]);

      // Save to shared preferences
      await remotesRepo.saveToPreferences();

      // Load from shared preferences
      final loadedRepo = await RemotesRepository.loadFromPreferences();
      var repo = loadedRepo?.registeredRemotes[0] as MinioBackend;

      // Check that the loaded object matches the original
      expect(loadedRepo?.registeredRemotes.length, remotesRepo.registeredRemotes.length);
      expect(repo.endpoint, minioRepo.endpoint);
      expect(repo.port, minioRepo.port);
      expect(repo.useSSL, minioRepo.useSSL);
      expect(repo.accessKey, minioRepo.accessKey);
      expect(repo.secretKey, minioRepo.secretKey);
      expect(repo.uuid, minioRepo.uuid);
    });
  });
}
