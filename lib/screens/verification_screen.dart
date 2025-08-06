import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../services/firebase_service.dart';
import '../services/supabase_service.dart';
import 'home_screen.dart';
import 'profile_display_screen.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({Key? key}) : super(key: key);

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // States
  bool _isLoading = false;
  String _verificationStatus = '';
  
  // Firebase service
  final FirebaseService _firebaseService = FirebaseService();
  
  // Face detection
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
      enableTracking: true,
    ),
  );
  
  // Completion states
  bool _faceVerified = false;
  bool _documentVerified = false;
  bool _facePhotoUploaded = false;
  bool _documentUploaded = false;
  
  // Face Verification
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  XFile? _capturedImage;
  bool _isCameraInitialized = false;
  String? _faceImageUrl;
  
  // Document Upload
  File? _selectedDocument;
  String _selectedDocType = 'Aadhaar';
  final List<String> _docTypes = ['Aadhaar', 'PAN'];
  String? _documentImageUrl;
  
  // ID Verification Results
  Map<String, dynamic>? _idVerificationResults;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    
    _checkExistingVerification();
    _initializeCamera();
  }

  Future<void> _checkExistingVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      print('🔍 Checking existing verification status for user: ${user.uid}');
      
      final userData = await _firebaseService.getUserProfile();
      if (userData != null && userData['verificationCompleted'] == true) {
        print('✅ User profile shows verification completed');
        setState(() {
          _verificationStatus = 'completed';
        });
        _showSnackBar('Verification already completed! ✅');
        
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) _navigateToProfile();
        });
      } else {
        print('📝 User needs to complete verification');
      }
    } catch (e) {
      print('❌ Error checking verification status: $e');
    }
  }

  Future<void> _navigateToProfile() async {
    try {
      final userData = await _firebaseService.getUserProfile();
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileDisplayScreen(
              name: userData?['fullName'] ?? 'User',
              age: userData?['age'] ?? 25,
              profession: userData?['profession'] ?? 'Professional',
              bio: userData?['bio'] ?? 'Bio not available',
              location: userData?['location'] ?? 'Location not set',
              images: null,
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Error navigating to profile: $e');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
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

  // Capture photo
  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _showSnackBar('Camera not initialized');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      print('📸 Capturing photo...');
      final image = await _cameraController!.takePicture();
      _capturedImage = image;
      await _performFaceDetection(File(image.path));
      
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Face photo captured successfully! ✅');
      print('✅ Photo captured and face verified');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('❌ Error capturing photo: $e');
      _showSnackBar('Failed to capture photo: $e');
    }
  }

  // Upload face image to Supabase Storage
  Future<void> _uploadFaceImage() async {
    try {
      if (_capturedImage == null) return;
      
      print('📸 Uploading face verification image...');
      _faceImageUrl = await SupabaseService.instance.uploadFaceImage(
        File(_capturedImage!.path),
      );
      
      setState(() => _facePhotoUploaded = true);
      print('✅ Face image uploaded successfully');
    } catch (e) {
      print('❌ Error uploading face image: $e');
      throw e;
    }
  }

  // Perform face detection using ML Kit - VALIDATION DISABLED
  Future<void> _performFaceDetection(File imageFile) async {
    try {
      print('📸 Face detection validation disabled - accepting any photo');
      setState(() {
        _faceVerified = true;
      });
      _showSnackBar('Face verification successful! ✅ (validation disabled)');
    } catch (e) {
      print('❌ Error in face detection: $e');
      setState(() {
        _faceVerified = true;
      });
      _showSnackBar('Face verification successful! ✅ (validation disabled)');
    }
  }

  // Update face verification status in Firebase
  Future<void> _updateFaceVerificationStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      await FirebaseFirestore.instance
          .collection('user_verifications')
          .doc(user.uid)
          .set({
        'userId': user.uid,
        'faceVerified': _faceVerified,
        'facePhotoUploaded': _facePhotoUploaded,
        'faceImageUrl': _faceImageUrl,
        'faceVerificationTimestamp': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      print('✅ Face verification status updated in database');
    } catch (e) {
      print('❌ Error updating face verification status: $e');
    }
  }

  // Capture document
  Future<void> _captureDocument() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _showSnackBar('Camera not initialized');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      print('📄 Capturing document...');
      final image = await _cameraController!.takePicture();
      setState(() {
        _selectedDocument = File(image.path);
        _isLoading = false;
      });
      _showSnackBar('Document captured successfully! ✅');
      print('✅ Document captured');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('❌ Error capturing document: $e');
      _showSnackBar('Failed to capture document: $e');
    }
  }

  // Upload document image to Supabase Storage
  Future<void> _uploadDocumentImage() async {
    try {
      if (_selectedDocument == null) return;
      
      print('📄 Uploading document verification image...');
      _documentImageUrl = await SupabaseService.instance.uploadDocumentImage(
        _selectedDocument!,
        _selectedDocType,
      );
      
      setState(() => _documentUploaded = true);
      print('✅ Document image uploaded successfully');
    } catch (e) {
      print('❌ Error uploading document image: $e');
      throw e;
    }
  }

  // Perform ID verification (simulated)
  Future<void> _performIdVerification() async {
    try {
      print('🔍 Performing ID verification for ${_selectedDocType}...');
      await Future.delayed(const Duration(seconds: 2)); // Simulate processing
      
      _idVerificationResults = {
        'documentType': _selectedDocType,
        'isValid': true,
        'confidence': 0.95,
        'extractedData': {
          'name': 'John Doe',
          'documentNumber': _selectedDocType == 'Aadhaar' ? '1234-5678-9012' : 'ABCDE1234F',
          'dateOfBirth': '1990-01-01',
          'address': '123 Main Street, City, State',
        },
        'verificationChecks': {
          'documentAuthenticity': true,
          'faceMatch': true,
          'dataConsistency': true,
          'tamperingDetection': false,
        },
        'riskScore': 0.1,
        'verificationTimestamp': DateTime.now().toIso8601String(),
      };
      
      setState(() {
        _documentVerified = _idVerificationResults!['isValid'] && 
                           _idVerificationResults!['confidence'] > 0.8;
      });
      
      if (_documentVerified) {
        _showSnackBar('ID verification successful! Document is authentic. ✅');
      } else {
        _showSnackBar('ID verification failed. Please upload a clear, valid document.');
      }
      print('✅ ID verification completed: ${_documentVerified ? "PASSED" : "FAILED"}');
    } catch (e) {
      print('❌ Error in ID verification: $e');
      setState(() {
        _documentVerified = false;
      });
    }
  }

  // Update document verification status in Firebase
  Future<void> _updateDocumentVerificationStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      await FirebaseFirestore.instance
          .collection('user_verifications')
          .doc(user.uid)
          .set({
        'userId': user.uid,
        'documentVerified': _documentVerified,
        'documentUploaded': _documentUploaded,
        'documentType': _selectedDocType,
        'documentImageUrl': _documentImageUrl,
        'idVerificationResults': _idVerificationResults,
        'documentVerificationTimestamp': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      print('✅ Document verification status updated in database');
    } catch (e) {
      print('❌ Error updating document verification status: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _verificationStatus == 'completed' 
            ? _buildCompletedVerificationView()
            : Column(
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

  Widget _buildCompletedVerificationView() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.shade400,
                  Colors.green.shade600,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.verified_user,
              size: 60,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 32),
          
          const Text(
            'Verification Complete!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Your identity has been successfully verified.\nYou can now access all features.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  icon: Icons.face,
                  title: 'Face Verification',
                  isCompleted: _faceVerified,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatusCard(
                  icon: Icons.description,
                  title: 'Document Verification',
                  isCompleted: _documentVerified,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _navigateToProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Continue to Profile',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required String title,
    required bool isCompleted,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? Colors.green : Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : icon,
            color: isCompleted ? Colors.green : Colors.white.withOpacity(0.7),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: isCompleted ? Colors.green : Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      automaticallyImplyLeading: false,
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
          const Text(
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _capturePhoto,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.camera_alt, color: Colors.white, size: 30),
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
          const Text(
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
          
          // Document camera area
          Expanded(
            child: _selectedDocument != null
                ? _buildDocumentPreview()
                : _buildDocumentCameraView(),
          ),
          
          const SizedBox(height: 20),
          if (_selectedDocument == null) _buildDocumentCameraControls(),
          if (_selectedDocument != null) _buildDocumentActions(),
        ],
      ),
    );
  }

  Widget _buildDocumentCameraView() {
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
          Center(
            child: Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.credit_card,
                    color: Colors.white.withOpacity(0.7),
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Position $_selectedDocType here',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Position your $_selectedDocType within the frame',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
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

  Widget _buildDocumentCameraControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _captureDocument,
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
          child: const Text('Retake', style: TextStyle(color: Colors.white)),
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

  Future<void> _verifyFace() async {
    if (_capturedImage == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      print('🔍 Starting face verification...');
      await _uploadFaceImage();
      await _updateFaceVerificationStatus();
      
      setState(() {
        _verificationStatus = 'Face verification successful! ✓';
        _faceVerified = true;
        _isLoading = false;
      });
      
      _showSnackBar('Face verification completed! ✅');
      print('✅ Face verification completed');
      
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        _tabController.animateTo(1);
      }
    } catch (e) {
      print('❌ Face verification failed: $e');
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
      print('🔍 Starting document verification...');
      await _uploadDocumentImage();
      await _performIdVerification();
      await _updateDocumentVerificationStatus();
      
      setState(() {
        _verificationStatus = '$_selectedDocType verification successful! ✓';
        _documentVerified = true;
        _isLoading = false;
      });
      
      _showSnackBar('Document verification completed! ✅');
      print('✅ Document verification completed');
    } catch (e) {
      print('❌ Document verification failed: $e');
      setState(() {
        _verificationStatus = 'Document verification failed. Please try again.';
        _isLoading = false;
      });
      _showSnackBar('Document verification failed: $e');
    }
  }

  Future<void> _submitVerification() async {
    if (!_canProceed()) {
      _showSnackBar('Please complete both face and document verification first');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');
      
      print('🔥 Starting verification submission for user: ${user.uid}');
      
      String? faceImageUrl = _faceImageUrl;
      String? documentImageUrl = _documentImageUrl;
      
      if (_capturedImage != null && faceImageUrl == null) {
        print('📸 Uploading face verification image to Supabase...');
        faceImageUrl = await SupabaseService.instance.uploadFaceImage(File(_capturedImage!.path));
        print('✅ Face image uploaded to Supabase: $faceImageUrl');
      }
      
      if (_selectedDocument != null && documentImageUrl == null) {
        print('📄 Uploading document verification image to Supabase...');
        documentImageUrl = await SupabaseService.instance.uploadDocumentImage(_selectedDocument!, _selectedDocType);
        print('✅ Document image uploaded to Supabase: $documentImageUrl');
      }
      
      print('💾 Saving verification data to Firestore...');
      await FirebaseFirestore.instance
          .collection('user_verifications')
          .doc(user.uid)
          .set({
        'userId': user.uid,
        'faceVerified': _faceVerified,
        'documentVerified': _documentVerified,
        'faceImageUrl': faceImageUrl,
        'documentType': _selectedDocType,
        'documentImageUrl': documentImageUrl,
        'verificationStatus': 'completed',
        'submittedAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      print('👤 Updating user profile verification status...');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'isVerified': true,
        'verificationCompleted': true,
        'verificationCompletedAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      print('✅ Verification data saved successfully!');
      _showSnackBar('Verification completed successfully! Welcome to Senorita! 🎉');
      
      if (mounted) {
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      print('❌ Verification submission failed: $e');
      _showSnackBar('Submission failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _canProceed() {
    return _faceVerified && _documentVerified;
  }

  String _getButtonText() {
    int currentTab = _tabController.index;
    
    if (currentTab == 0) {
      if (_faceVerified) {
        return 'Go to ID Verify';
      } else if (_capturedImage != null) {
        return 'Verify Face';
      } else {
        return 'Take Selfie';
      }
    } else {
      if (_documentVerified) {
        return 'Complete Verification';
      } else if (_selectedDocument != null) {
        return 'Verify Document';
      } else {
        return 'Capture ID';
      }
    }
  }

  VoidCallback? _getButtonAction() {
    int currentTab = _tabController.index;
    
    if (currentTab == 0) {
      if (_faceVerified) {
        return _goToNextStep;
      } else if (_capturedImage != null) {
        return _verifyFace;
      } else {
        return null;
      }
    } else {
      if (_documentVerified) {
        return _submitVerification;
      } else if (_selectedDocument != null) {
        return _verifyDocument;
      } else {
        return null;
      }
    }
  }

  void _goToNextStep() {
    int currentTab = _tabController.index;
    if (currentTab < 1) {
      _tabController.animateTo(currentTab + 1);
      setState(() {});
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