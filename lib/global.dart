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
  final int? rate;

  const VideoInfo({
    required this.id,
    required this.coverFileName,
    required this.videoFileName,
    required this.rate,
  });

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    return VideoInfo(
      id: json["id"],
      coverFileName: json["coverFileName"],
      videoFileName: json["videoFileName"],
      rate: json["rate"],
    );
  }
}

class Tag {
  final int id;
  final String tag;
  bool checked = false;
  Tag({required this.id, required this.tag});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(id: json["id"], tag: json["tag"]);
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
