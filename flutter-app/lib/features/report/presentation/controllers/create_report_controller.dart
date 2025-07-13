import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../data/report_repository.dart';
import '../../domain/models/report.dart';
import '../../domain/models/report_models.dart';
import '../../domain/models/report_state.dart';

part 'create_report_controller.g.dart';

@riverpod
class CreateReportController extends _$CreateReportController {
  @override
  CreateReportState build() {
    return const CreateReportState();
  }

  void updateTitle(String title) {
    state = state.copyWith(title: title, error: null);
    _clearFieldError('title');
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description, error: null);
    _clearFieldError('description');
  }

  void updateType(ReportType type) {
    state = state.copyWith(type: type, error: null);
    _clearFieldError('type');
  }

  void updatePriority(Priority priority) {
    state = state.copyWith(priority: priority);
  }

  Future<void> getCurrentLocation() async {
    state = state.copyWith(isLoading: true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final placemark = placemarks.isNotEmpty ? placemarks.first : null;
      final address = placemark != null
          ? '${placemark.street}, ${placemark.locality}, ${placemark.country}'
          : null;

      final location = ReportLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        city: placemark?.locality,
        district: placemark?.subLocality,
        postalCode: placemark?.postalCode,
      );

      state = state.copyWith(
        location: location,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> selectImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        final currentImages = List<XFile>.from(state.selectedImages);
        currentImages.addAll(images);
        
        // Limit to 5 images total
        if (currentImages.length > 5) {
          currentImages.removeRange(5, currentImages.length);
        }

        state = state.copyWith(selectedImages: currentImages);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to select images: $e');
    }
  }

  Future<void> takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        final currentImages = List<XFile>.from(state.selectedImages);
        
        if (currentImages.length < 5) {
          currentImages.add(image);
          state = state.copyWith(selectedImages: currentImages);
        } else {
          state = state.copyWith(error: 'Maximum 5 images allowed');
        }
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to take photo: $e');
    }
  }

  void removeImage(int index) {
    final currentImages = List<XFile>.from(state.selectedImages);
    if (index >= 0 && index < currentImages.length) {
      currentImages.removeAt(index);
      state = state.copyWith(selectedImages: currentImages);
    }
  }

  Future<void> uploadImages() async {
    if (state.selectedImages.isEmpty) return;

    state = state.copyWith(isUploadingImages: true, error: null);

    try {
      final repository = ref.read(reportRepositoryProvider);
      final uploadResponses = await repository.uploadImages(state.selectedImages);
      
      state = state.copyWith(
        uploadedImages: uploadResponses,
        isUploadingImages: false,
      );

      // Trigger AI analysis for the first image
      if (uploadResponses.isNotEmpty) {
        await analyzeFirstImage();
      }
    } catch (e) {
      state = state.copyWith(
        isUploadingImages: false,
        error: 'Failed to upload images: $e',
      );
    }
  }

  Future<void> analyzeFirstImage() async {
    if (state.uploadedImages.isEmpty) return;

    state = state.copyWith(isAnalyzing: true);

    try {
      final repository = ref.read(reportRepositoryProvider);
      final firstImageId = state.uploadedImages.first.imageId;
      
      final aiAnalysis = await repository.analyzeImage(
        firstImageId,
        expectedType: state.type,
      );

      state = state.copyWith(
        aiAnalysis: aiAnalysis,
        isAnalyzing: false,
      );

      // Auto-suggest type and priority based on AI analysis
      if (state.type == null) {
        state = state.copyWith(type: aiAnalysis.detectedType);
      }
      
      if (state.priority == Priority.medium) {
        state = state.copyWith(priority: aiAnalysis.suggestedPriority);
      }
    } catch (e) {
      state = state.copyWith(
        isAnalyzing: false,
        error: 'AI analysis failed: $e',
      );
    }
  }

  Future<void> createReport() async {
    if (!_validateForm()) return;

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      // Upload images first if not already uploaded
      if (state.selectedImages.isNotEmpty && state.uploadedImages.isEmpty) {
        await uploadImages();
      }

      final repository = ref.read(reportRepositoryProvider);
      final imageIds = state.uploadedImages.map((img) => img.imageId).toList();

      final request = CreateReportRequest(
        title: state.title!,
        description: state.description!,
        type: state.type!,
        location: state.location!,
        imageIds: imageIds,
        priority: state.priority,
      );

      final report = await repository.createReport(request);
      
      // Submit the report immediately
      await repository.submitReport(report.id);

      state = state.copyWith(isSubmitting: false);
      
      // Reset form
      state = const CreateReportState();
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Failed to create report: $e',
      );
    }
  }

  bool _validateForm() {
    bool isValid = true;
    Map<String, String> errors = {};

    if (state.title == null || state.title!.trim().isEmpty) {
      errors['title'] = 'Title is required';
      isValid = false;
    } else if (state.title!.trim().length < 5) {
      errors['title'] = 'Title must be at least 5 characters';
      isValid = false;
    }

    if (state.description == null || state.description!.trim().isEmpty) {
      errors['description'] = 'Description is required';
      isValid = false;
    } else if (state.description!.trim().length < 10) {
      errors['description'] = 'Description must be at least 10 characters';
      isValid = false;
    }

    if (state.type == null) {
      errors['type'] = 'Report type is required';
      isValid = false;
    }

    if (state.location == null) {
      errors['location'] = 'Location is required';
      isValid = false;
    }

    if (state.selectedImages.isEmpty && state.uploadedImages.isEmpty) {
      errors['images'] = 'At least one image is required';
      isValid = false;
    }

    if (!isValid) {
      state = state.copyWith(
        fieldErrors: errors,
        error: 'Please fix the errors above',
      );
    }

    return isValid;
  }

  void _setFieldError(String field, String error) {
    final errors = Map<String, String>.from(state.fieldErrors ?? {});
    errors[field] = error;
    state = state.copyWith(fieldErrors: errors);
  }

  void _clearFieldError(String field) {
    if (state.fieldErrors != null && state.fieldErrors!.containsKey(field)) {
      final errors = Map<String, String>.from(state.fieldErrors!);
      errors.remove(field);
      state = state.copyWith(fieldErrors: errors);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearForm() {
    state = const CreateReportState();
  }
}