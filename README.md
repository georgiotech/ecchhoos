# ecchhoos
Playback transcribed media

## Building tips

On macOS you might need to do the following:
1. `brew install cocoapods`

On linux, you might need some additionaly libraries:
1. Dependencies as per https://github.com/bluefireteam/audioplayers/blob/main/packages/audioplayers_linux/README.md#dev-dependencies

## Testing locally

You'll need to bring your own Minio backend for now. For convenience one is provided in dev-infra and can be spun up with `docker compose up`. If you're using this one you'll need to configure a bucket and upload some example files (one is provided alongside the compose.yml file). Then revise the values in the minio.dart file to ensure you can connect to your instance.
