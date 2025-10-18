import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:senorita/services/firebase_service.dart';
import 'package:senorita/services/supabase_service.dart';
import 'package:senorita/models/user_profile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'welcome_screen.dart';

class ProfileDisplayScreen extends StatefulWidget {
  final String name;
  final int age;
  final String profession;
  final String bio;
  final String location;
  final List<File>? images;

  const ProfileDisplayScreen({
    Key? key,
    required this.name,
    required this.age,
    required this.profession,
    required this.bio,
    required this.location,
    this.images,
  }) : super(key: key);

  @override
  State<ProfileDisplayScreen> createState() => _ProfileDisplayScreenState();
}

class _ProfileDisplayScreenState extends State<ProfileDisplayScreen>
    with TickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _professionController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;

  File? _profileImage;
  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isEditing = false;
  bool _isLoading = false;
  String? _userCode;
  Map<String, dynamic>? _userProfile;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _ageController = TextEditingController(text: widget.age.toString());
    _professionController = TextEditingController(text: widget.profession);
    _bioController = TextEditingController(text: widget.bio);
    _locationController = TextEditingController(text: widget.location);

    if (widget.images != null) {
      _images = List.from(widget.images!);
      if (_images.isNotEmpty) {
        _profileImage = _images[0];
      }
    }

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      print('🔍 Loading user profile...');
      
      // Check if user is authenticated first
      if (_firebaseService.currentUserId == null) {
        print('❌ User not authenticated, cannot load profile');
        return;
      }
      
      // First ensure user profile is initialized
      await _firebaseService.initializeUserProfile();
      
      // Add a small delay to ensure Firestore operations complete
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Then get the updated profile
      final profile = await _firebaseService.getUserProfile();
      if (profile != null) {
        print('✅ Profile loaded: ${profile.keys.toList()}');
        print('🔑 User code from profile: ${profile['userCode']}');
        
        setState(() {
          _userProfile = profile;
          _userCode = profile['userCode'];
        });
        
        // Check if userCode is still null or empty after initialization
        if (_userCode == null || _userCode!.isEmpty) {
          print('⚠️ User code is missing after initialization, forcing regeneration...');
          
          // Force generate a new code and update directly
          await _firebaseService.forceGenerateUserCode();
          
          // Wait a bit and reload
          await Future.delayed(const Duration(milliseconds: 1000));
          final updatedProfile = await _firebaseService.getUserProfile();
          if (updatedProfile != null) {
            setState(() {
              _userProfile = updatedProfile;
              _userCode = updatedProfile['userCode'];
            });
            print('🔄 Updated user code after force generation: ${_userCode}');
          }
        }
      } else {
        print('❌ No profile found after initialization, retrying...');
        // Wait a bit before retrying
        await Future.delayed(const Duration(milliseconds: 1000));
        final retryProfile = await _firebaseService.getUserProfile();
        if (retryProfile != null) {
          setState(() {
            _userProfile = retryProfile;
            _userCode = retryProfile['userCode'];
          });
          print('✅ Profile loaded on retry: ${_userCode}');
        } else {
          print('❌ Failed to load profile after retry');
        }
      }
    } catch (e) {
      print('❌ Error loading user profile: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _professionController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
          if (_images.isEmpty) {
            _images.add(_profileImage!);
          } else {
            _images[0] = _profileImage!;
          }
        });
        _showSnackBar('Profile photo updated');
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e');
    }
  }

  void _copyUserCode() {
    if (_userCode != null) {
      Clipboard.setData(ClipboardData(text: _userCode!));
      _showSnackBar('User code copied to clipboard');
    }
  }

  int _calculateProfileCompletionPercentage() {
    int completedFields = 0;
    int totalFields = 6;

    if (_nameController.text.isNotEmpty) completedFields++;
    if (_ageController.text.isNotEmpty) completedFields++;
    if (_professionController.text.isNotEmpty) completedFields++;
    if (_bioController.text.isNotEmpty) completedFields++;
    if (_locationController.text.isNotEmpty) completedFields++;
    if (_images.isNotEmpty) completedFields++;

    return ((completedFields / totalFields) * 100).round();
  }

  Future<void> _saveAndContinue() async {
    await _saveProfile();
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty) {
      _showSnackBar('Please enter your name');
      return;
    }
    if (_ageController.text.isEmpty) {
      _showSnackBar('Please enter your age');
      return;
    }
    int? age = int.tryParse(_ageController.text);
    if (age == null) {
      _showSnackBar('Please enter a valid age');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final percentage = _calculateProfileCompletionPercentage();

      final updatedData = {
        'fullName': _nameController.text,
        'age': age,
        'profession': _professionController.text,
        'bio': _bioController.text,
        'location': _locationController.text,
        'profileCompletionPercentage': percentage,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      await _firebaseService.updateUserProfile(updatedData);
      
      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      _showSnackBar('Profile updated successfully');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error updating profile: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.grey[800],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  _saveProfile();
                } else {
                  _isEditing = true;
                }
              });
            },
            child: Text(
              _isEditing ? 'Done' : 'Edit',
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildProfileImageSection(),
                    const SizedBox(height: 24),
                    _buildUserCodeSection(),
                    const SizedBox(height: 24),
                    _buildProfileInfoSection(),
                    const SizedBox(height: 24),
                    _buildAccountSettingsSection(),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: _profileImage != null
                    ? Image.file(
                        _profileImage!,
                        fit: BoxFit.cover,
                        width: 140,
                        height: 140,
                      )
                    : Container(
                        color: Colors.white.withOpacity(0.05),
                        child: const Icon(
                          Icons.person,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            if (_isEditing)
              Positioned(
                bottom: 5,
                right: 5,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          widget.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.age} years • ${widget.profession}',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        // Gender display
        if (_userProfile != null && _userProfile!['gender'] != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _userProfile!['gender'].toString().toLowerCase() == 'female' ? Icons.female : Icons.male,
                color: _userProfile!['gender'].toString().toLowerCase() == 'female' ? Colors.pink : Colors.blue,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                _userProfile!['gender'].toString().toLowerCase() == 'female' ? 'Female' : 'Male',
                style: TextStyle(
                  color: (_userProfile!['gender'].toString().toLowerCase() == 'female' ? Colors.pink : Colors.blue).withOpacity(0.9),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_calculateProfileCompletionPercentage()}% Complete',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserCodeSection() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.qr_code,
                  color: Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Code',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _userCode == null
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Generating...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              _userCode!,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.blue,
                                letterSpacing: 2,
                              ),
                            ),
                      const SizedBox(height: 2),
                      Text(
                        'Share this code with friends',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _userCode != null ? _copyUserCode : null,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (_userCode != null ? Colors.blue : Colors.grey).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.copy,
                      color: _userCode != null ? Colors.blue : Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Free Dates Section
        if (_userProfile != null && (_userProfile!['freeDatesRemaining'] ?? 0) > 0) ...[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.withOpacity(0.2), Colors.green.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.green.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.card_giftcard,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_userProfile!['freeDatesRemaining']} Free Date${(_userProfile!['freeDatesRemaining'] ?? 0) > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'You have free snacks to use on your dates!',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ],
      ],
    );
  }

  Widget _buildProfileInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: const Text(
              'Profile Information',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoItem(
                  icon: Icons.person_outline,
                  title: 'Name',
                  value: widget.name,
                  controller: _nameController,
                ),
                const SizedBox(height: 20),
                _buildInfoItem(
                  icon: Icons.cake_outlined,
                  title: 'Age',
                  value: widget.age.toString(),
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                _buildInfoItem(
                  icon: Icons.work_outline,
                  title: 'Profession',
                  value: widget.profession,
                  controller: _professionController,
                ),
                const SizedBox(height: 20),
                _buildInfoItem(
                  icon: Icons.location_on_outlined,
                  title: 'Location',
                  value: widget.location,
                  controller: _locationController,
                ),
                const SizedBox(height: 20),
                _buildInfoItem(
                  icon: Icons.info_outline,
                  title: 'Bio',
                  value: widget.bio,
                  controller: _bioController,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              _isEditing
                  ? TextField(
                      controller: controller,
                      keyboardType: keyboardType,
                      maxLines: maxLines,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Enter $title',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 16,
                        ),
                      ),
                    )
                  : Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: maxLines,
                      overflow: TextOverflow.ellipsis,
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSettingsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: const Text(
              'Account Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                _buildSettingsItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  onTap: () => _showSnackBar('Notification settings would open here'),
                ),
                _buildSettingsItem(
                  icon: Icons.lock_outline,
                  title: 'Privacy',
                  onTap: () => _showSnackBar('Privacy settings would open here'),
                ),
                _buildSettingsItem(
                  icon: Icons.security_outlined,
                  title: 'Security',
                  onTap: () => _showSnackBar('Security settings would open here'),
                ),
                _buildSettingsItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () => _showSnackBar('Help & support would open here'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white54,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_isEditing)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton(
              onPressed: () {
                _saveAndContinue();
                setState(() {
                  _isEditing = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Save and Continue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (Route<dynamic> route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Continue to Home',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showLogoutConfirmation(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Log Out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showDeleteAccountConfirmation(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.1),
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(
                  color: Colors.red,
                  width: 1,
                ),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Delete Account',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Log Out',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out? You\'ll need to sign in again to access your account.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'Log Out',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        },
      );

      // Sign out from Firebase Auth
      await _firebaseService.signOut();
      print('✅ Signed out from Firebase');
      
      // Sign out from Google Sign-In to clear cached account
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
        print('✅ Signed out from Google Sign-In');
      } catch (googleSignOutError) {
        print('⚠️ Error signing out from Google: $googleSignOutError');
        // Continue with logout even if Google sign-out fails
      }
      
      Navigator.of(context).pop();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const RayaWelcomeScreen()),
        (Route<dynamic> route) => false,
      );

      _showSnackBar('Successfully logged out');
      
    } catch (e) {
      Navigator.of(context).pop();
      print('❌ Logout error: $e');
      _showSnackBar('Error logging out. Please try again.');
    }
  }

  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            '⚠️ Delete Account',
            style: TextStyle(
              color: Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'This action is PERMANENT and cannot be undone.\n\nAll your data including:\n• Profile information\n• Photos\n• Chat history\n• Meetup history\n\nwill be permanently deleted.\n\nAre you absolutely sure?',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performDeleteAccount();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'Delete Forever',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performDeleteAccount() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
                SizedBox(height: 16),
                Text(
                  'Deleting account...',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          );
        },
      );

      final currentUserId = _firebaseService.currentUserId;
      if (currentUserId == null) throw Exception('No user logged in');

      print('🗑️ Starting account deletion for user: $currentUserId');

      // 1. Delete user photos from Supabase Storage
      try {
        print('🗑️ Deleting photos from Supabase...');
        final supabaseService = SupabaseService.instance;
        await supabaseService.deleteAllUserPhotos(currentUserId);
        print('✅ Photos deleted from Supabase');
      } catch (e) {
        print('⚠️ Error deleting photos from Supabase: $e');
      }

      // 2. Delete Firestore data
      final firestore = FirebaseFirestore.instance;
      
      // Delete user document
      print('🗑️ Deleting user document...');
      await firestore.collection('users').doc(currentUserId).delete();
      
      // Delete chat rooms where user is participant
      print('🗑️ Deleting chat rooms...');
      final chatRooms = await firestore
          .collection('chat_rooms')
          .where('participantIds', arrayContains: currentUserId)
          .get();
      
      for (var chatRoom in chatRooms.docs) {
        // Delete all messages in the chat room
        final messages = await chatRoom.reference.collection('messages').get();
        for (var message in messages.docs) {
          await message.reference.delete();
        }
        // Delete the chat room
        await chatRoom.reference.delete();
      }
      
      // Delete meetups where user is involved
      print('🗑️ Deleting meetups...');
      final meetupsRequesting = await firestore
          .collection('meetups')
          .where('requestingUserId', isEqualTo: currentUserId)
          .get();
      for (var meetup in meetupsRequesting.docs) {
        await meetup.reference.delete();
      }
      
      final meetupsInvited = await firestore
          .collection('meetups')
          .where('invitedUserId', isEqualTo: currentUserId)
          .get();
      for (var meetup in meetupsInvited.docs) {
        await meetup.reference.delete();
      }
      
      // Delete notifications
      print('🗑️ Deleting notifications...');
      final notifications = await firestore
          .collection('notifications')
          .where('userId', isEqualTo: currentUserId)
          .get();
      for (var notification in notifications.docs) {
        await notification.reference.delete();
      }

      // 3. Delete Firebase Auth user
      print('🗑️ Deleting Firebase Auth user...');
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await currentUser.delete();
      }

      // 4. Sign out from Google
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
      } catch (e) {
        print('⚠️ Error signing out from Google: $e');
      }

      print('✅ Account deletion complete');
      
      // Close loading dialog
      Navigator.of(context).pop();

      // Navigate to welcome screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const RayaWelcomeScreen()),
        (Route<dynamic> route) => false,
      );

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your account has been permanently deleted'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      print('❌ Account deletion error: $e');
      
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Error',
              style: TextStyle(
                color: Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Failed to delete account: ${e.toString()}\n\nPlease try again or contact support.',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }
}