import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Vizentec Classificador'),
    );
  }
}

class MyImagerPicker extends StatefulWidget{
  @override
  MyImagerPickerState createState() => MyImagerPickerState();
}

class MyImagerPickerState extends State<MyImagerPicker>{

  File _image;
  final picker = ImagePicker();
  String result = 'Nenhuma Imagem selecionada.';

  Future getImageFromCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        result = 'Nenhuma Imagem selecionada.';
      }
    });
  }

  Future getImageFromGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        result = 'Nenhuma Imagem selecionada.';
      }
    });
  }

  Future classifyImage() async {
    await Tflite.loadModel(model: "assets/model.tflite",labels: "assets/labels.txt");
    var output = await Tflite.detectObjectOnImage(path: _image.path, imageMean: 127.5,     
      imageStd: 127.5,      
      threshold: 0.6, numResultsPerClass: 10);
    setState(() {
      result = output.toString();
    });
  }

  Future prettyPrintJson(String input) async{
      const JsonDecoder decoder = JsonDecoder();
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      final dynamic object = decoder.convert(input);
      final dynamic prettyString = encoder.convert(object);
      prettyString.split('\n').forEach((dynamic element) => print(element));
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null ? Text(result) : Image.file(_image, width: 300, height: 200, fit: BoxFit.cover),
            Container(
              margin: EdgeInsets.fromLTRB(0, 30, 0, 20),
              child: ElevatedButton(
                onPressed: () => getImageFromCamera(),
                child: Text('Abrir Camera'),      
              )
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: ElevatedButton(
                onPressed: () => getImageFromGallery(),
                child: Text('Abrir Galeria'),      
              )
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 30, 0, 20),
              child: ElevatedButton(
                onPressed: () => classifyImage(),
                child: Text('Classificar'),      
              )
            ),

            result == null ? Text('Deu ruim') : Text(result)
          ]
        ,)
      ,)
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
      ),
      body: Center(child: MyImagerPicker(),)
    );
  }
}
