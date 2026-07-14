# AGENTS.md

## Project Overview
This is a Flutter application for viewing MP4 videos, with features for tagging, searching, and managing video collections.

## Key Commands
- `flutter run` - Run the app
- `flutter test` - Run tests
- `flutter analyze` - Run static analysis
- `flutter pub get` - Get dependencies

## Architecture
- Entry point: `lib/main.dart`
- Main UI components in `lib/widget/`
- Core data structures in `lib/` (e.g., `dir_item.dart`, `global.dart`)

## Key Features
- Video grid view with Masonry layout
- Video tagging and rating system (good/normal/bad)
- Video search and duplicate management
- Image preview and video playback
- Multi-platform support (Android, iOS, Linux, macOS, Windows)

## API Integration
- Uses REST API at `http://192.168.2.12:8082`
- API endpoints include:
  - `/mount-config` - Get mount configuration
  - `/query-videos-by-tag/{id}` - Get videos by tag
  - `/designation-search/{word}` - Search videos by word
  - `/video-info/{path}` - Get video info for directory
  - `/image-stream-by-id/{id}` - Get image stream
  - `/video-stream-by-id/{id}/stream.mp4` - Get video stream
  - `/video-exist/{baseIndex}{dirPath}/{title}` - Check video existence
  - `/video-rate/{id}/{rate}` - Set video rating
  - `/video/{id}` - Delete video

## Testing
- Unit tests in `test/widget_test.dart`
- Run with `flutter test`

## Environment
- Uses Flutter SDK 3.10.1
- Depends on packages: `cupertino_icons`, `blur`, `http`, `js`, `flutter_staggered_grid_view`