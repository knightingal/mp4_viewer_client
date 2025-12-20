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
      apiVersion: json["apiVersion"],
    );
  }
}

class VideoInfo {
  final int id;
  final String coverFileName;
  final String videoFileName;
  final Rate? rate;
  final int baseIndex;
  final String dirPath;

  final int? videoSize;
  final int? coverSize;
  final int? height;
  final int? width;
  final int? frameRate;
  final int? duration;
  final int? videoFrameCount;
  final String? designationChar;
  final String? designationNum;

  const VideoInfo({
    required this.id,
    required this.coverFileName,
    required this.videoFileName,
    required this.rate,
    required this.baseIndex,
    required this.dirPath,

    required this.videoSize,
    required this.coverSize,
    required this.height,
    required this.width,
    required this.frameRate,
    required this.duration,
    required this.videoFrameCount,
    required this.designationChar,
    required this.designationNum,
  });

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    return VideoInfo(
      id: json["id"],
      coverFileName: json["coverFileName"],
      videoFileName: json["videoFileName"],
      rate: Rate.values[json["rate"] ?? 0],
      baseIndex: json["baseIndex"],
      dirPath: json["dirPath"],

      videoSize: json["videoSize"],
      coverSize: json["coverSize"],
      height: json["height"],
      width: json["width"],
      frameRate: json["frameRate"],
      duration: json["duration"],
      videoFrameCount: json["videoFrameCount"],
      designationChar: json["designationChar"],
      designationNum: json["designationNum"],
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

class DuplicateVideo {
  final int count;
  final String designationChar;
  final String designationNum;
  final List<VideoInfo> videoInfo;
  const DuplicateVideo({
    required this.count,
    required this.designationChar,
    required this.designationNum,
    required this.videoInfo,
  });

  factory DuplicateVideo.fromJson(Map<String, dynamic> json) {
    List<dynamic> jsonArray = json["videoInfo"];
    List<VideoInfo> dataList = jsonArray
        .map((e) => VideoInfo.fromJson(e))
        .toList();
    return DuplicateVideo(
      count: json["count"],
      designationChar: json["designationChar"],
      designationNum: json["designationNum"],
      videoInfo: dataList,
    );
  }
}

enum Rate { none, good, normal, bad, deleted }
