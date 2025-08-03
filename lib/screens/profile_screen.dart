

  import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'home_screen.dart';

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

  // States
  bool _isLoading = false;
  String _verificationStatus = '';

  // Completion states
  bool _faceVerified = false;
  bool _documentVerified = false;

  // Face Verification
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  XFile? _capturedImage;
  bool _isCameraInitialized = false;

  // Document Upload
  File? _selectedDocument;
  String _selectedDocType = 'Aadhaar';
  final List<String> _docTypes = ['Aadhaar', 'PAN', 'Passport'];


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFaceVerificationTab(),
                  _buildDocumentUploadTab(),
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


  Widget _buildTabBar() {
    return Container(
      color: Colors.black,
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF007AFF),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Face Verify'),
                if (_faceVerified) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                ],
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('ID Check'),
                if (_documentVerified) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                ],
              ],
            ),
          ),
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
    return Container(
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
            Icons.credit_card,
            size: 80,
            color: Colors.white.withOpacity(0.6),
          ),
          const SizedBox(height: 20),
          Text(
            'Capture your $_selectedDocType',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 30),
          
          // Camera button only
          GestureDetector(
            onTap: _captureDocument,
            child: Container(
              width: 200,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Text('Capture Document', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 15),
          Text(
            'Live capture ensures authenticity',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
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


  

  // Camera Functions
  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      // Fallback to gallery picker if camera not available (emulator)
      await _pickImageFromGallery();
      return;
    }
    
    try {
      final XFile image = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = image;
      });
    } catch (e) {
      _showSnackBar('Camera not available. Using gallery picker...');
      await _pickImageFromGallery();
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
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
  Future<void> _captureDocument() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear, // Use back camera
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90, // Higher quality for documents
      );
      
      if (image != null) {
        setState(() {
          _selectedDocument = File(image.path);
        });
      }
    } catch (e) {
      // Fallback to gallery if camera fails (emulator)
      _showSnackBar('Camera not available. Using gallery picker...');
      await _pickDocument();
    }
  }

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
    });

    try {
      // Simulate API call to face verification service
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: Implement actual face verification API
      
      setState(() {
        _verificationStatus = 'Face verification successful! ✓';
        _faceVerified = true;
        _isLoading = false;
      });
      
      // Auto-move to next tab after a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        _tabController.animateTo(1);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Face verification failed. Please try again.');
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
        _documentVerified = true;
        _isLoading = false;
      });
      
      // Document verification complete - ready for final submission
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
      
      // Navigate to next screen (home screen for now)
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      _showSnackBar('Submission failed. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  bool _canProceed() {
    return _faceVerified && 
           _documentVerified;
  }

  String _getButtonText() {
    int currentTab = _tabController.index;
    
    if (currentTab == 0) {
      // Face verification tab
      return _faceVerified ? 'Go to Next Step' : (_capturedImage != null ? 'Complete Face Verification' : 'Take Photo First');
    } else {
      // Document verification tab (now tab 1, final step)
      return _documentVerified ? 'Complete Verification' : (_selectedDocument != null ? 'Complete ID Verification' : 'Verify ID');
    }
  }

  VoidCallback? _getButtonAction() {
    int currentTab = _tabController.index;
    
    if (currentTab == 0) {
      // Face verification tab
      if (_faceVerified) {
        return _goToNextStep;
      } else if (_capturedImage != null) {
        return _verifyFace; // This will verify and auto-move to next step
      } else {
        return null; // Disabled until photo is taken
      }
    } else {
      // Document verification tab (now final step)
      if (_documentVerified) {
        return _submitVerification; // Complete verification and go to home
      } else if (_selectedDocument != null) {
        return _verifyDocument; // This will verify and enable completion
      } else {
        return null; // Disabled until document is uploaded
      }
    }
  }

  void _goToNextStep() {
    int currentTab = _tabController.index;
    if (currentTab < 1) {
      _tabController.animateTo(currentTab + 1);
    }
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
              onPressed: _getButtonAction(),
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
                  : Text(
                      _getButtonText(),
                      style: const TextStyle(
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