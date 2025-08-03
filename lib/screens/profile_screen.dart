

  import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Controllers
  final TextEditingController _bioController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // States
  int _currentStep = 0;
  bool _isLoading = false;
  String _verificationStatus = '';

  // Face Verification
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  XFile? _capturedImage;
  bool _isCameraInitialized = false;

  // Document Upload
  File? _selectedDocument;
  String _selectedDocType = 'Aadhaar';
  final List<String> _docTypes = ['Aadhaar', 'PAN', 'Passport'];

  // Bio
  String _bioText = '';
  final int _maxBioLength = 500;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
            orElse: () => _cameras!.first,
          ),
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _bioController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildProgressIndicator(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFaceVerificationTab(),
                  _buildDocumentUploadTab(),
                  _buildBioTab(),
                ],
              ),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Profile Verification',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: index <= _tabController.index
                    ? const Color(0xFF007AFF)
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.black,
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF007AFF),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Face Verify'),
          Tab(text: 'ID Check'),
          Tab(text: 'Bio'),
        ],
      ),
    );
  }

  Widget _buildFaceVerificationTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Face Verification',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Position your face in the frame and take a clear selfie',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Expanded(
            child: _capturedImage != null
                ? _buildCapturedImageView()
                : _buildCameraView(),
          ),
          const SizedBox(height: 20),
          if (_capturedImage == null) _buildCameraControls(),
          if (_capturedImage != null) _buildImageActions(),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        height: 400,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF007AFF)),
        ),
      );
    }

    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CameraPreview(_cameraController!),
          ),
          // Face guide overlay
          Center(
            child: Container(
              width: 250,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(150),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapturedImageView() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.hardEdge,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(
          File(_capturedImage!.path),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildCameraControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        
        GestureDetector(
          onTap: _takePicture,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 30),
          ),
        ),
        
      ],
    );
  }

  Widget _buildImageActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              _capturedImage = null;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
          child: const Text('Retake', style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          onPressed: _verifyFace,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007AFF),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text('Verify Face', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildDocumentUploadTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Government ID Verification',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Upload a clear photo of your government ID',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 30),
          
          // Document type selector
          Text(
            'Select Document Type',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDocType,
                isExpanded: true,
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                items: _docTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDocType = newValue!;
                  });
                },
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Document upload area
          Expanded(
            child: _selectedDocument != null
                ? _buildDocumentPreview()
                : _buildDocumentUploadArea(),
          ),
          
          const SizedBox(height: 20),
          if (_selectedDocument != null) _buildDocumentActions(),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadArea() {
    return GestureDetector(
      onTap: _pickDocument,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 80,
              color: Colors.white.withOpacity(0.6),
            ),
            const SizedBox(height: 20),
            Text(
              'Tap to upload $_selectedDocType',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Supported formats: JPG, PNG, PDF',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentPreview() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(
          _selectedDocument!,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildDocumentActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              _selectedDocument = null;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
          child: const Text('Remove', style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          onPressed: _verifyDocument,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007AFF),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text('Verify Document', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildBioTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Tell us about yourself',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Write a brief bio to help others get to know you better',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 30),
          
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: TextField(
                controller: _bioController,
                maxLines: null,
                maxLength: _maxBioLength,
                expands: true,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Share your interests, hobbies, what you\'re looking for...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                  counterStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                ),
                onChanged: (text) {
                  setState(() {
                    _bioText = text;
                  });
                },
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Character count and tips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_bioText.length}/$_maxBioLength characters',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              Text(
                'Be authentic!',
                style: TextStyle(
                  color: Color(0xFF007AFF),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (_verificationStatus.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: _verificationStatus.contains('Success')
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _verificationStatus,
                style: TextStyle(
                  color: _verificationStatus.contains('Success')
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canProceed() ? _submitVerification : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                disabledBackgroundColor: Colors.grey[800],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Complete Verification',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Camera Functions
  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    
    try {
      final XFile image = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = image;
      });
    } catch (e) {
      _showSnackBar('Error taking picture: $e');
    }
  }

  

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _capturedImage = image;
        });
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e');
    }
  }

  // Document Functions
  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedDocument = File(result.files.single.path!);
        });
      }
    } catch (e) {
      _showSnackBar('Error picking document: $e');
    }
  }

  // Verification Functions
  Future<void> _verifyFace() async {
    if (_capturedImage == null) return;
    
    setState(() {
      _isLoading = true;
      _verificationStatus = '';
    });

    try {
      // Simulate API call to face verification service
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: Implement actual face verification API
      // Example: HyperVerge, AWS Rekognition, or similar service
      /*
      final response = await http.post(
        Uri.parse('https://api.hyperverge.co/v2.0/verifyFace'),
        headers: {
          'appId': 'YOUR_APP_ID',
          'appKey': 'YOUR_APP_KEY',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'image': base64Encode(await _capturedImage!.readAsBytes()),
        }),
      );
      */
      
      setState(() {
        _verificationStatus = 'Face verification successful! ✓';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _verificationStatus = 'Face verification failed. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyDocument() async {
    if (_selectedDocument == null) return;
    
    setState(() {
      _isLoading = true;
      _verificationStatus = '';
    });

    try {
      // Simulate API call to document verification service
      await Future.delayed(const Duration(seconds: 3));
      
      // TODO: Implement actual document verification API
      // Example: IDfy, HyperVerge KYC, or similar service
      /*
      final response = await http.post(
        Uri.parse('https://api.idfy.com/v2/verifications'),
        headers: {
          'Authorization': 'Bearer YOUR_API_TOKEN',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'document_type': _selectedDocType.toLowerCase(),
          'document_image': base64Encode(await _selectedDocument!.readAsBytes()),
        }),
      );
      */
      
      setState(() {
        _verificationStatus = '$_selectedDocType verification successful! ✓';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _verificationStatus = 'Document verification failed. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _submitVerification() async {
    if (!_canProceed()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Submit all verification data to your backend
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: Implement backend submission
      /*
      final response = await http.post(
        Uri.parse('https://your-api.com/submit-verification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'face_image': base64Encode(await _capturedImage!.readAsBytes()),
          'document_type': _selectedDocType,
          'document_image': base64Encode(await _selectedDocument!.readAsBytes()),
          'bio': _bioText,
        }),
      );
      */
      
      _showSnackBar('Verification submitted successfully!');
      Navigator.pop(context, true); // Return success
    } catch (e) {
      _showSnackBar('Submission failed. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _canProceed() {
    return _capturedImage != null && 
           _selectedDocument != null && 
           _bioText.trim().isNotEmpty &&
           _bioText.trim().length >= 50; // Minimum bio length
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF007AFF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}