import 'dart:convert';
import 'package:ecchhoos/src/models/MinioBackend.dart';
import 'package:ecchhoos/src/repository/remotes.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('RemotesRepository', () {
    setUp(() {
      // Use the mock shared preferences for testing
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
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

    test('saveToSecureStorage and loadFromSecureStorage should work correctly', () async {
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

      // Save to secure storage
      await remotesRepo.saveToSecureStorage();

      // Load from secure storage
      final loadedRepo = await RemotesRepository.loadFromSecureStorage();
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

    test('loadFromSecureStorage should migrate from SharedPreferences', () async {
      final minioRepo = MinioBackend(
        endpoint: 'https://old-example.com',
        port: 9000,
        useSSL: false,
        accessKey: 'oldKey',
        secretKey: 'oldSecret',
        bucketName: 'oldBucket',
        pathPrefix: 'oldPrefix',
      );
      final remotesRepo = RemotesRepository(registeredRemotes: [minioRepo]);
      final jsonString = jsonEncode(remotesRepo.toJson());

      // Populate SharedPreferences
      SharedPreferences.setMockInitialValues({'remotes': jsonString});
      // Ensure SecureStorage is empty
      FlutterSecureStorage.setMockInitialValues({});

      // Load (should trigger migration)
      final loadedRepo = await RemotesRepository.loadFromSecureStorage();

      expect(loadedRepo?.registeredRemotes.length, 1);
      final repo = loadedRepo?.registeredRemotes[0] as MinioBackend;
      expect(repo.endpoint, 'https://old-example.com');

      // Verify SharedPreferences is empty
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('remotes'), false);

      // Verify SecureStorage has data
      const storage = FlutterSecureStorage();
      final storedJson = await storage.read(key: 'remotes');
      expect(storedJson, isNotNull);
      expect(storedJson, jsonString);
    });

    test('createNewRemote appends a new backend to the list', () {
      final remotesRepo = RemotesRepository.empty();
      expect(remotesRepo.registeredRemotes.length, 0);
      final newRemote = remotesRepo.createNewRemote();
      expect(remotesRepo.registeredRemotes.length, 1);
      expect(remotesRepo.registeredRemotes[0].uuid, newRemote.uuid);
    });

    test('updateRemote updates an existing backend in the list', () {
      final remotesRepo = RemotesRepository.empty();
      final remoteToReplace = remotesRepo.createNewRemote();
      expect(remotesRepo.registeredRemotes.length, 1);

      final updatedRemote = MinioBackend(
        uuid: remoteToReplace.uuid,
        endpoint: 'https://updated-example.com',
        port: 9331,
        useSSL: false,
        accessKey: 'updatedAccessKey',
        secretKey: 'updatedSecretKey',
        bucketName: 'updatedBucket',
        pathPrefix: 'updatedPrefix/',
      );
      remotesRepo.updateRemote(updatedRemote);
      expect(remotesRepo.registeredRemotes.length, 1);
      expect(remotesRepo.registeredRemotes[0].uuid, remoteToReplace.uuid);
      final postUpdateRepo = remotesRepo.registeredRemotes[0] as MinioBackend;
      expect(postUpdateRepo.endpoint, updatedRemote.endpoint);
      expect(postUpdateRepo.port, updatedRemote.port);
    });

    test('updateRemote inserts a non-existent backend to the list', () {
      final remotesRepo = RemotesRepository.empty();
      expect(remotesRepo.registeredRemotes.length, 0);

      final newRemote = MinioBackend(
        endpoint: 'https://updated-example.com',
        port: 9331,
        useSSL: false,
        accessKey: 'updatedAccessKey',
        secretKey: 'updatedSecretKey',
        bucketName: 'updatedBucket',
        pathPrefix: 'updatedPrefix/',
      );
      remotesRepo.updateRemote(newRemote);
      expect(remotesRepo.registeredRemotes.length, 1);
      expect(remotesRepo.registeredRemotes[0].uuid, newRemote.uuid);
    });

    test('removeRemote deletes an existing backend from the list', () {
      final remotesRepo = RemotesRepository.empty();
      final remoteToDelete = remotesRepo.createNewRemote();
      expect(remotesRepo.registeredRemotes.length, 1);

      remotesRepo.removeRemote(remoteToDelete.uuid);
      expect(remotesRepo.registeredRemotes.length, 0);
    });

    test('removeRemote does nothing if the backend does not exist', () {
      final remotesRepo = RemotesRepository.empty();
      remotesRepo.createNewRemote();
      expect(remotesRepo.registeredRemotes.length, 1);

      remotesRepo.removeRemote('unmatching-uuid');
      expect(remotesRepo.registeredRemotes.length, 1);
    });
  });
}
