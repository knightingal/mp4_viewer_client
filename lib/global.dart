class MountConfig {
  final int id;
  final String baseDir;
  final String urlPrefix;

  const MountConfig({
    required this.id,
    required this.baseDir,
    required this.urlPrefix,
  });

  factory MountConfig.fromJson(Map<String, dynamic> json) {
    return MountConfig(
        id: json["id"], baseDir: json["baseDir"], urlPrefix: json["urlPrefix"]);
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
