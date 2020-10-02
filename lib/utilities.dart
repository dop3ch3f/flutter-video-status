import 'dart:async';
import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_ffmpeg/media_information.dart';
import 'package:path_provider/path_provider.dart';

class UtilityMethods {
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
  final FlutterFFmpegConfig _flutterFFmpegConfig = FlutterFFmpegConfig();
  final FlutterFFprobe _flutterFFprobe = new FlutterFFprobe();

  // to get all the needed information from a video file
  Future<Map<String, dynamic>> getVideoInformation(File video) async {
    MediaInformation info =
        await _flutterFFprobe.getMediaInformation(video.path);

    // we need path, duration from output
    Map<String, dynamic> result = Map();

    result.addAll({
      "path": video.path,
      "duration": info.getMediaProperties()['duration']
    });
    return result;
  }

  Future<String> generateSnapShotFromVideo(String seconds, String path) async {
    Directory appDocumentDir = await getApplicationDocumentsDirectory();

    List newArray = List.from(path.split("/"));

    newArray.removeLast();

    String outputPath =
        [appDocumentDir.path, "/", "image-${seconds}asd.jpg"].join("");

    // ffmpeg -ss 01:23:45 -i input -vframes 1 -q:v 2 output.jpg

    print(outputPath);
    var code = await _flutterFFmpeg.execute(
        " -ss $seconds -i $path -vframes 1 -q:v 2 ${File(outputPath).path}");
    print("execution code: $code");

    return outputPath;
  }

  Future<List<String>> generateVideoSnapshots(File video) async {
    // get video information
    Map videoInfo = await getVideoInformation(video);
    // process and get the imageTimes
    List<String> imageTimes = await computeImageTimesForVideo(video);
    // with the image times dispatch a concurrent request to generate snapshot image from video
    List<String> videoFrames =
        await Future.wait(List.generate(5, (index) async {
      return await generateSnapShotFromVideo(
          imageTimes[index], videoInfo['path']);
    }));
    return videoFrames;
  }

  Future<List<String>> computeImageTimesForVideo(File video) async {
    // get video information
    Map videoInfo = await getVideoInformation(video);
    print(videoInfo);
    // get video duration from video information
    double videoDurationInSeconds = double.tryParse(videoInfo['duration']);
    // get the divisorConstant to get at least 14 frames of the video
    double divisorValue = (videoDurationInSeconds / 5).toDouble();
    // to get at least 14 picture frames by computing their image times and adding to generated array;
    return List.generate(5, (index) {
      return "${index * divisorValue}";
    });
  }
}
