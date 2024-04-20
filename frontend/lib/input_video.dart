import 'dart:io';
import 'package:autonomous_navigation/network/api.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class InputVideoFeed extends StatefulWidget {
  const InputVideoFeed({super.key});

  @override
  State<InputVideoFeed> createState() => _InputVideoFeedState();
}

class _InputVideoFeedState extends State<InputVideoFeed> {
  VideoPlayerController? _controller;
  File? _video;
  ImagePicker picker = ImagePicker();

  _pickVideo() async {
    XFile? pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _video = File(pickedFile.path);
      });

      String key = 'video';
      String filePath = _video!.path;

      try {
        var request = http.MultipartRequest('POST', Uri.parse(AppUrl.url));
        request.files.add(await http.MultipartFile.fromPath(key, filePath));
        var response = await request.send();

        if (response.statusCode == 200) {
          var responseBody = await response.stream.toBytes();
          Directory tempDir = await getTemporaryDirectory();
          final File videoFile = File('${tempDir.path}/modified_video.mp4');
          await videoFile.writeAsBytes(responseBody);

          setState(() {
            _controller = VideoPlayerController.file(videoFile)
              ..initialize().then((_) {
                setState(() {});
                _controller?.play();
              });
          });
        } else {
          print('Error occurred during multipart request');
        }
      } catch (e) {
        print(e);
      }
    }
  }

  _resetApp() {
    setState(() {
      _video = null;
      _controller?.dispose();
      _controller = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Input'),
        centerTitle: true,
      ),
      body: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_video != null || _controller != null)
              _controller != null && _controller!.value.isInitialized
                  ? Center(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: VideoPlayer(_controller!),
                        ),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()),
            if (_video == null && _controller == null)
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height * 0.18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      _pickVideo();
                    },
                    child: const Text('Select Video'),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.18,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        _resetApp();
                      },
                      child: const Text('Close'),
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
