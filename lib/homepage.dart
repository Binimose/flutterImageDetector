import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Uint8List? image;
  late ImagePicker imagePicker;
  late ImageLabeler labeler;
  String labelText = "No labels detected"; // Display the detected labels
  bool isLabeling = false; // To show a loading indicator when labeling

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    final ImageLabelerOptions options = ImageLabelerOptions(confidenceThreshold: 0.7);
    labeler = ImageLabeler(options: options);
  }

  // Function to pick image from the gallery
  Future<void> pickImageFromGallery() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      Uint8List bytes = await pickedFile.readAsBytes();
      setState(() {
        image = bytes;
        isLabeling = true;
      });
      await imageLabeling(pickedFile.path); // Pass the file path for labeling
    }
  }

  // Function to pick image from the camera
  Future<void> pickImageFromCamera() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    
    if (pickedFile != null) {
      Uint8List bytes = await pickedFile.readAsBytes();
      setState(() {
        image = bytes;
        isLabeling = true;
      });
      await imageLabeling(pickedFile.path); // Pass the file path for labeling
    }
  }

  // Function to label the image
  Future<void> imageLabeling(String imagePath) async {
    try {
      // Create InputImage from file path
      final InputImage inputImage = InputImage.fromFilePath(imagePath);

      // Start processing the image
      final List<ImageLabel> labels = await labeler.processImage(inputImage);

      if (labels.isNotEmpty) {
        setState(() {
          labelText = labels.map((label) => '${label.label} (${label.confidence.toStringAsFixed(2)})').join(', ');
          isLabeling = false;
        });
      } else {
        setState(() {
          labelText = "No labels detected.";
          isLabeling = false;
        });
      }
    } catch (e) {
      setState(() {
        labelText = "Error during image labeling: $e";
        isLabeling = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:Colors.blue,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height:MediaQuery.of(context).size.height/2,
              color: Colors.grey,
               child:image == null
                ? const Icon(Icons.image_outlined, size: 150)
                : Image.memory(image!, width: 500, height: 200), // Display picked image
             
            ),
            const SizedBox(height: 15),

            Container(
              color: Colors.blue,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height/10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed:pickImageFromGallery ,
                   icon:const Icon(Icons.image_outlined)
                  ),
                  IconButton(
                    onPressed: pickImageFromCamera, 
                    icon:Icon(Icons.camera_enhance_outlined)
                    )
                ],
              ),
            ),
             
             
             
            const SizedBox(height: 20),
            isLabeling
                ? const CircularProgressIndicator() // Show a progress indicator while labeling
                :  Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height/5,
                  color: Colors.black,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                    labelText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16,color:Colors.white),
                  ),
                    ],
                  ),
                ) // Show detected labels or error messages
          ],
        ),
      ),
    );
  }
}
