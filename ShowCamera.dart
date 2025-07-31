

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class Showcamera extends StatefulWidget {
  const Showcamera({super.key});

  @override
  State<Showcamera> createState() => _ShowcameraState();
}

class _ShowcameraState extends State<Showcamera> {
   CameraController? controller;
   String vin="";
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body:  controller==null?Center(child:CircularProgressIndicator())
          :Column(

        children: [
          CameraPreview(controller!),
          Card(child: Text(vin,style: TextStyle(fontSize: 30),)),
          ElevatedButton(onPressed: ()async{
            await controller!.stopImageStream();
            Navigator.pop(context,vin);
          }, child: Text("Done"))
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    availableCameras().then((_cameras){
    controller = CameraController(_cameras[0], ResolutionPreset.max,enableAudio: false);
    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      if (!mounted) {
        setState(() {});
      }
      controller!.startImageStream((strem){
        printStr(strem);
      });
    });
    });
  }

   printStr(CameraImage image)async{
     final WriteBuffer allBytes = WriteBuffer();
     for (Plane plane in image.planes) {
       allBytes.putUint8List(plane.bytes);
     }
     final bytes = allBytes.done().buffer.asUint8List();
     // Ensure the correct format and byte buffer are used
     final inputImage = InputImage.fromBytes(
       bytes: bytes,
       metadata: InputImageMetadata(
         size: Size(image.width.toDouble(), image.height.toDouble()),
         rotation: InputImageRotation.rotation0deg, // Adjust based on camera orientation
         format:  InputImageFormat.yv12,
         bytesPerRow: image.planes[0].bytesPerRow,
       ),
     );
     final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
     final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

     String text = recognizedText.text;
     for (TextBlock block in recognizedText.blocks) {
       for (TextLine line in block.lines) {
         for (TextElement element in line.elements) {
           if(element.text.length==17)
             setState(() {
             vin=element.text;
           });
         }
       }
     }
   }
}
