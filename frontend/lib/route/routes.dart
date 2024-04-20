import 'package:autonomous_navigation/input_video.dart';
import 'package:autonomous_navigation/route/route_names.dart';
import 'package:flutter/material.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.inputVideo:
        return MaterialPageRoute(builder: (_) => const InputVideoFeed());

      default:
        return MaterialPageRoute(builder: (_) {
          return const Scaffold(
            body: Center(child: Text("No Route Defined")),
          );
        });
    }
  }
}
