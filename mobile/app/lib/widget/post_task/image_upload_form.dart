import 'dart:io';
import 'package:flutter/material.dart';

class ImagesUploadForm extends StatelessWidget {
  final List<Map<String, dynamic>> imagesWithCaptions;
  final void Function() onPickImages;
  final void Function(int oldIndex, int newIndex) onReorderImages;
  final void Function(int index) onRemoveImage;

  const ImagesUploadForm({
    required this.imagesWithCaptions,
    required this.onPickImages,
    required this.onReorderImages,
    required this.onRemoveImage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ElevatedButton.icon(
            icon: Icon(Icons.photo_library),
            label: Text('Upload Images'),
            onPressed: onPickImages,
          ),
          SizedBox(height: 10),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: imagesWithCaptions.length,
              onReorder: onReorderImages,
              itemBuilder: (context, index) {
                final image = imagesWithCaptions[index];
                return ListTile(
                  key: ValueKey(index),
                  leading: Image.file(
                    image['file'] as File,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => onRemoveImage(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
