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
