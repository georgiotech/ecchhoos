import 'package:ecchhoos/src/models/GenericBackend.dart';
import 'package:ecchhoos/src/models/S3CompatibleFile.dart';
import 'package:minio/minio.dart';

import 'dart:convert';
import 'package:ecchhoos/src/models/items.dart';

class MinioBackend implements GenericBackend {
  final String endpoint;
  final int port;
  final bool useSSL;
  final String accessKey;
  final String secretKey;
  final String bucketName;
  final String pathPrefix;
  final String uuid;

  MinioBackend({
    required this.endpoint,
    this.port = 9330,
    this.useSSL = true,
    required this.accessKey,
    required this.secretKey,
    required this.bucketName,
    required this.pathPrefix,
    String? uuid,
  }) : uuid = uuid ?? GenericBackend.generateUuid();

  Minio get client => Minio(
        endPoint: endpoint,
        port: port,
        useSSL: useSSL,
        accessKey: accessKey,
        secretKey: secretKey,
      );

  Future<List<S3CompatibleFile>> enumerateAllItems() async {
    final items = <S3CompatibleFile>[];

    try {
      final stream = client.listObjects(bucketName, prefix: pathPrefix);

      await for (final object in stream) {
        object.objects.forEach((element) async {
          if (element.key?.endsWith('.json') ?? false) {
            items.add(S3CompatibleFile(bucketName: bucketName, path: element.key!, hash: element.eTag!));
          }
        });
      }
    } catch (e) {
      print('Error fetching objects: $e');
      // Handle the error appropriately
    }

    return items;
  }

  Future<List<TranscribedMediaItem>> getAllItems() async {
    final items = <TranscribedMediaItem>[];

    try {
      final stream = client.listObjects(bucketName, prefix: pathPrefix);

      await for (final object in stream) {
        for (final element in object.objects) {
          if (element.key?.endsWith('.json') ?? false) {
            final stream = await client.getObject(bucketName, element.key!);
            final bytes = await stream.toList();
            final jsonString = utf8.decode(bytes.expand((x) => x).toList());
            final Map<String, dynamic> data = json.decode(jsonString);

            items.add(TranscribedMediaItem(
              name: data['name'],
              description: data['description'],
              mediaPath: data['mediaPath'],
              rawTranscription: data['transcription'],
              transcription: parseTranscript(data['transcription']),
            ));
          } else {
            print('skipping ${element.key}');
          }
        }
      }
    } catch (e) {
      // Handle the error appropriately
    }

    return items;
  }

  Future<TranscribedMediaItem?> getItem(S3CompatibleFile resource) async {
    try {
      final stream = await client.getObject(bucketName, resource.path);
      final bytes = await stream.toList();
      final jsonString = utf8.decode(bytes.expand((x) => x).toList());
      final Map<String, dynamic> data = json.decode(jsonString);

      return TranscribedMediaItem(
        name: data['name'],
        description: data['description'],
        mediaPath: data['mediaPath'],
        rawTranscription: data['transcription'],
        transcription: parseTranscript(data['transcription']),
      );
    } catch (e) {
      print('Error fetching objects: $e');
      // Handle the error appropriately
    }

    return null;
  }

  // Serialize to JSON
  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'type': 'minio',
        'endpoint': endpoint,
        'port': port,
        'useSSL': useSSL,
        'accessKey': accessKey,
        'secretKey': secretKey,
        'bucketName': bucketName,
        'pathPrefix': pathPrefix,
      };

  // Deserialize from JSON
  factory MinioBackend.fromJson(Map<String, dynamic> json) => MinioBackend(
        uuid: json['uuid'],
        endpoint: json['endpoint'],
        port: json['port'],
        useSSL: json['useSSL'],
        accessKey: json['accessKey'],
        secretKey: json['secretKey'],
        bucketName: json['bucketName'],
        pathPrefix: json['pathPrefix'],
      );
}
