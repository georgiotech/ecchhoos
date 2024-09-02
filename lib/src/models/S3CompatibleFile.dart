class S3CompatibleFile {
  final String bucketName;
  final String path;
  final String hash;

  S3CompatibleFile({required this.bucketName, required this.path, required this.hash});
}
