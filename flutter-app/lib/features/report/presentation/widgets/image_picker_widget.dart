import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/models/report_models.dart';

class ImagePickerWidget extends StatelessWidget {
  final List<XFile> selectedImages;
  final List<ImageUploadResponse> uploadedImages;
  final bool isUploading;
  final VoidCallback onSelectImages;
  final VoidCallback onTakePhoto;
  final void Function(int index) onRemoveImage;
  final VoidCallback? onUploadImages;

  const ImagePickerWidget({
    super.key,
    required this.selectedImages,
    required this.uploadedImages,
    required this.isUploading,
    required this.onSelectImages,
    required this.onTakePhoto,
    required this.onRemoveImage,
    this.onUploadImages,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.photo_camera),
                const SizedBox(width: 8),
                const Text(
                  'Photos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${selectedImages.length + uploadedImages.length}/5',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Add photos to help identify the issue',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: selectedImages.length + uploadedImages.length < 5
                        ? onTakePhoto
                        : null,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: selectedImages.length + uploadedImages.length < 5
                        ? onSelectImages
                        : null,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
            
            if (selectedImages.isNotEmpty || uploadedImages.isNotEmpty) ...[
              const SizedBox(height: 16),
              
              // Upload progress
              if (selectedImages.isNotEmpty && uploadedImages.isEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.cloud_upload,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ready to upload ${selectedImages.length} image${selectedImages.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    if (onUploadImages != null)
                      TextButton(
                        onPressed: isUploading ? null : onUploadImages,
                        child: isUploading 
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Upload'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              
              // Image grid
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedImages.length + uploadedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _buildImageTile(context, index),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageTile(BuildContext context, int index) {
    final isUploaded = index >= selectedImages.length;
    
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: isUploaded
                ? _buildUploadedImage(index - selectedImages.length)
                : _buildSelectedImage(index),
          ),
        ),
        
        // Remove button
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => onRemoveImage(index),
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
        
        // Upload status indicator
        if (!isUploaded) ...[
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isUploading ? Icons.cloud_upload : Icons.cloud_off,
                    color: Colors.white,
                    size: 12,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    isUploading ? 'Uploading...' : 'Local',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_done,
                    color: Colors.white,
                    size: 12,
                  ),
                  SizedBox(width: 2),
                  Text(
                    'Uploaded',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectedImage(int index) {
    return Image.file(
      File(selectedImages[index].path),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          child: const Icon(Icons.error),
        );
      },
    );
  }

  Widget _buildUploadedImage(int index) {
    final uploadResponse = uploadedImages[index];
    return Image.network(
      uploadResponse.thumbnailUrl ?? uploadResponse.imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          child: const Icon(Icons.error),
        );
      },
    );
  }
}