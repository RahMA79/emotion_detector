import 'package:camera/camera.dart';
import 'package:emotion_detector/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tensorflow_lite_flutter/tensorflow_lite_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CameraController? cameraController;
  String output = '';
  double percentage = 0;
  loadCamera() {
    cameraController = CameraController(cameras![0], ResolutionPreset.max);
    cameraController!.initialize().then((value) {
      if (!mounted) {
        return;
      } else {
        //capture frame
        setState(() {
          cameraController!.startImageStream((image) {
            runModel(image);
          });
        });
      }
    });
  }

  runModel(CameraImage? image) async {
    if (image != null) {
      dynamic recognitions = await Tflite.runModelOnFrame(
          bytesList: image.planes.map((plane) {
            return plane.bytes;
          }).toList(), // required
          imageHeight: image.height,
          imageWidth: image.width,
          imageMean: 127.5, // defaults to 127.5
          imageStd: 127.5, // defaults to 127.5
          rotation: 90, // defaults to 90, Android only
          numResults: 2, // defaults to 5
          threshold: 0.1, // defaults to 0.1
          asynch: true // defaults to true
          );
      // ignore: avoid_function_literals_in_foreach_calls
      for (var element in recognitions) {
        setState(() {
          output = element['label'];
          percentage = element['confidence'];
          percentage *= 100;
        });
      }
    }
  }

  loadModel() async {
    // await Tflite.close();
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  @override
  void initState() {
    super.initState();
    loadCamera();
    loadModel();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Emotion Detector',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //here the camera
              SizedBox(
                  height: MediaQuery.of(context).size.height * 0.60,
                  width: MediaQuery.of(context).size.width,
                  child: !cameraController!.value.isInitialized
                      ? Container()
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CameraPreview(cameraController!),
                        )),

              const SizedBox(
                height: 20,
              ),
              Text(
                '$output %${(percentage).toInt()}',
                style: const TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text('Don\'t forget to contact me on social media',style: TextStyle(fontWeight: FontWeight.w300)),
              const SizedBox(
                height: 20,
              ),
              const  Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ImageIcon(AssetImage('assets/pngtree-whatsapp-mobile-software-icon-png-image_6315991.png'),color: Colors.green,),
                  ImageIcon(AssetImage('assets/instagram-icon-logo-free-png.webp'),color: Colors.red,),
                  ImageIcon(AssetImage('assets/174857.png'),color: Colors.blue,)
                ],
              )
            ],
          ),
        ));
  }
}
