import 'package:camera/camera.dart';
import 'package:emotion_detector/SplashScreen.dart';
import 'package:flutter/material.dart';

List<CameraDescription>? cameras;
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //open conection between dart layer and flutter engine
  cameras = await availableCameras();
  runApp(const EmotionDetector());
}

class EmotionDetector extends StatelessWidget {
  const EmotionDetector({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
