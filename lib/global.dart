class MountConfig {
  final int id;
  final String baseDir;
  final String urlPrefix;
  final int apiVersion;

  const MountConfig({
    required this.id,
    required this.baseDir,
    required this.urlPrefix,
    required this.apiVersion,
  });

  factory MountConfig.fromJson(Map<String, dynamic> json) {
    return MountConfig(
        id: json["id"],
        baseDir: json["baseDir"],
        urlPrefix: json["urlPrefix"],
        apiVersion: json["apiVersion"]);
  }
}

class VideoInfo {
  final int id;
  final String coverFileName;
  final String videoFileName;

  const VideoInfo({
    required this.id,
    required this.coverFileName,
    required this.videoFileName,
  });

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    return VideoInfo(
        id: json["id"],
        coverFileName: json["coverFileName"],
        videoFileName: json["videoFileName"]);
  }
}

late List<MountConfig> gMountConfigList;

int? selectedMountConfig;

List<String> parent = [];

String getSubDir() {
  String dir = "";
  for (var value in parent) {
    dir += "$value/";
  }
  return dir;
}
