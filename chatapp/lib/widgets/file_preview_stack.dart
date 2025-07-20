import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FilePreviewStack extends StatelessWidget {
  final List<PlatformFile> files;

  const FilePreviewStack({super.key, required this.files});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 200 + (files.length - 1) * 20, // Width grows with files
      child: Stack(
        children: files.asMap().entries.map((entry) {
          final index = entry.key;
          final file = entry.value;

          return Positioned(
            left: index * 20,
            child: _buildFilePreview(file),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilePreview(PlatformFile file) {
    IconData iconData;
    Color color;

    if (file.extension == null) {
      iconData = Icons.insert_drive_file;
      color = Colors.grey;
    } else if (file.extension == 'pdf') {
      iconData = Icons.picture_as_pdf;
      color = Colors.red;
    } else if (file.extension == 'doc' || file.extension == 'docx') {
      iconData = Icons.description;
      color = Colors.blue;
    } else if (file.extension == 'mp3' || file.extension == 'wav') {
      iconData = Icons.audiotrack;
      color = Colors.green;
    } else if (file.extension == 'jpg' || file.extension == 'png') {
      iconData = Icons.image;
      color = Colors.orange;
    } else {
      iconData = Icons.insert_drive_file;
      color = Colors.grey;
    }

    return Container(
      height: 60,
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 2),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Icon(iconData, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              file.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
