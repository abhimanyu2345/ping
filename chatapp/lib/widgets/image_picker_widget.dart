import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({
    super.key,
    this.image,
    this.onImagePicked,
  });
  
  final Uint8List? image;
  final void Function(Uint8List imageBytes)? onImagePicked;
  

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  Uint8List? _pickedImageBytes;
Future<void> _pickImage() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
  );

  if (result != null && result.files.single.path != null) {
    final path = result.files.single.path!;
    final imageBytes = await File(path).readAsBytes();

    setState(() {
      _pickedImageBytes = imageBytes;
    });
    widget.onImagePicked?.call(imageBytes);
  }
}


  @override
  Widget build(BuildContext context) {
    final imageBytes = _pickedImageBytes ?? widget.image;
    
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage:
                imageBytes != null ? MemoryImage(imageBytes) : null,
            child: imageBytes == null
                ? const Icon(Icons.person, size: 60)
                : null,
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: InkWell(
              onTap: ()async{
                await _pickImage();
                
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.edit, size: 20, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
