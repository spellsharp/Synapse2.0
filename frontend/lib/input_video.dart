import 'dart:io';
import 'dart:convert';
import 'package:autonomous_navigation/network/api.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

class InputVideoFeed extends StatefulWidget {
  const InputVideoFeed({Key? key}) : super(key: key);

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
        var responseData = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          var jsonResponse = json.decode(responseData);
          String videoUrl = jsonResponse['video_url'];

          setState(() {
            // ignore: deprecated_member_use
            _controller = VideoPlayerController.network(videoUrl)
              ..initialize().then((_) {
                setState(() {});
                _controller?.play();
              });
          });
        } else {
          // Handle error
          print('Error occurred during multipart request');
        }
      } catch (e) {
        // Handle error
        print(e);
      }
    }
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
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: VideoPlayer(_controller!),
                        ),
                      ),
                    )
                  : Center(child: CircularProgressIndicator()),
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
          ],
        ),
      ),
    );
  }
}
