import 'package:flutter/material.dart';

class PhotoUploadStepScreen extends StatefulWidget {
  final VoidCallback onNext;
  final Function(List<String>) onPhotosSelected;
  final List<String>? selectedPhotos;

  const PhotoUploadStepScreen({
    Key? key,
    required this.onNext,
    required this.onPhotosSelected,
    this.selectedPhotos,
  }) : super(key: key);

  @override
  State<PhotoUploadStepScreen> createState() => _PhotoUploadStepScreenState();
}

class _PhotoUploadStepScreenState extends State<PhotoUploadStepScreen> {
  List<String> _uploadedPhotos = [];
  final int _minPhotos = 3;
  final int _maxPhotos = 6;

  @override
  void initState() {
    super.initState();
    _uploadedPhotos = widget.selectedPhotos ?? [];
  }

  void _addPhoto() {
    if (_uploadedPhotos.length < _maxPhotos) {
      // Simulate photo selection/upload
      setState(() {
        _uploadedPhotos.add('photo_${_uploadedPhotos.length + 1}.jpg');
      });
      widget.onPhotosSelected(_uploadedPhotos);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photo ${_uploadedPhotos.length} added successfully!'),
          backgroundColor: const Color(0xFF34C759),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _uploadedPhotos.removeAt(index);
    });
    widget.onPhotosSelected(_uploadedPhotos);
  }

  bool get _canContinue => _uploadedPhotos.length >= _minPhotos;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            'Add your photos',
            style: TextStyle(
              color: Color(0xFF1C1C1E),
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload at least $_minPhotos photos to showcase yourself',
            style: const TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 40),
          
          // Photo Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: _maxPhotos,
              itemBuilder: (context, index) {
                if (index < _uploadedPhotos.length) {
                  return _buildPhotoCard(index, true);
                } else {
                  return _buildPhotoCard(index, false);
                }
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E5EA)),
            ),
            child: Row(
              children: [
                Icon(
                  _canContinue ? Icons.check_circle : Icons.info_outline,
                  color: _canContinue ? const Color(0xFF34C759) : const Color(0xFF8E8E93),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _canContinue 
                        ? 'Great! You have ${_uploadedPhotos.length} photos uploaded'
                        : 'Upload ${_minPhotos - _uploadedPhotos.length} more photo${_minPhotos - _uploadedPhotos.length > 1 ? 's' : ''} to continue',
                    style: TextStyle(
                      color: _canContinue ? const Color(0xFF34C759) : const Color(0xFF8E8E93),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _canContinue ? widget.onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
                disabledBackgroundColor: const Color(0xFFE5E5EA),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(int index, bool hasPhoto) {
    return GestureDetector(
      onTap: hasPhoto ? null : _addPhoto,
      child: Container(
        decoration: BoxDecoration(
          color: hasPhoto ? const Color(0xFF007AFF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasPhoto ? const Color(0xFF007AFF) : const Color(0xFFE5E5EA),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: hasPhoto ? _buildUploadedPhoto(index) : _buildAddPhotoPlaceholder(),
      ),
    );
  }

  Widget _buildUploadedPhoto(int index) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF007AFF).withOpacity(0.8),
                const Color(0xFF5856D6).withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.photo,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                'Photo ${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => _removePhoto(index),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF007AFF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.add_a_photo,
            color: Color(0xFF007AFF),
            size: 24,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Add Photo',
          style: TextStyle(
            color: Color(0xFF007AFF),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}