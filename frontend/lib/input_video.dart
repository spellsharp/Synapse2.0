import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

    _video = File(pickedFile!.path);

    _controller = VideoPlayerController.file(_video!)
      ..initialize().then((_) {
        setState(() {});
        _controller?.play();
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
            if (_video != null)
              _controller!.value.isInitialized
                  ? Center(
                    child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: VideoPlayer(_controller!),
                        ),
                      ),
                  )
                  : Container(),
            if (_video == null)
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height * 0.18,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(25)),
                  child: ElevatedButton(
                    onPressed: () {
                      _pickVideo();
                    },
                    child: const Text('Click me'),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
