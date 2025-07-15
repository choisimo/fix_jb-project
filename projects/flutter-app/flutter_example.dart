import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

// A simple Flutter widget to demonstrate calling the backend router.

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Analysis Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AnalysisScreen(),
    );
  }
}

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({Key? key}) : super(key: key);

  @override
  _AnalysisScreenState createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  // IMPORTANT: Replace with your actual backend server IP address and port.
  // If running the Flutter app on an emulator, use 10.0.2.2 for the Android emulator to connect to localhost.
  // If running on a physical device, use the local IP address of your computer (e.g., 192.168.1.10).
  final String backendUrl = 'http://127.0.0.1:8000/api/v1/detect';

  File? _image;
  String _status = 'Please select an image to analyze.';
  String _result = '';
  bool _isLoading = false;

  Future<void> _pickAndAnalyzeImage() async {
    setState(() {
      _isLoading = true;
      _status = 'Picking image...';
      _result = '';
    });

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      setState(() {
        _isLoading = false;
        _status = 'No image selected.';
      });
      return;
    }

    setState(() {
      _image = File(pickedFile.path);
      _status = 'Image selected. Analyzing...';
    });

    try {
      var request = http.MultipartRequest('POST', Uri.parse(backendUrl));

      // Attach the image file
      request.files.add(await http.MultipartFile.fromPath('file', _image!.path));

      // Attach the category. Change this to 'license_plate' to test the router.
      request.fields['category'] = 'trash';

      final response = await request.send();

      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        setState(() {
          _status = 'Analysis successful!';
          // Pretty print the JSON response
          final jsonMap = json.decode(responseBody);
          _result = const JsonEncoder.withIndent('  ').convert(jsonMap);
        });
      } else {
        setState(() {
          _status = 'Error: ${response.statusCode}';
          _result = responseBody;
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Exception occurred!';
        _result = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Roboflow Backend Router Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_image != null)
                Image.file(_image!, height: 250, fit: BoxFit.cover),
              const SizedBox(height: 20),
              Text(_status, style: Theme.of(context).textTheme.headline6),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _pickAndAnalyzeImage,
                  child: const Text('Pick and Analyze Image'),
                ),
              if (_result.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.grey[200],
                    child: SelectableText(_result),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
