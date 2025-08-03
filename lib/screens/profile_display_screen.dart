import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';

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

class _ProfileDisplayScreenState extends State<ProfileDisplayScreen> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _professionController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  
  File? _profileImage;
  List<File> _images = [];
  
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
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _professionController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    // In a real app, you would use image_picker package
    // For this example, we'll just simulate the action
    setState(() {
      // This is just a placeholder - in a real app you would:
      // final picker = ImagePicker();
      // final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      // if (pickedFile != null) {
      //   _profileImage = File(pickedFile.path);
      //   _images = [_profileImage!];
      // }
      _showSnackBar('Image picker would open here');
    });
  }
  
  void _saveProfile() {
    // Validate inputs
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
    
    // In a real app, you would save to your backend/database
    // For this example, we'll just show a success message
    _showSnackBar('Profile saved successfully!');
    
    // Navigate back to profile display screen
    Navigator.pop(context, {
      'name': _nameController.text,
      'age': age,
      'profession': _professionController.text,
      'bio': _bioController.text,
      'location': _locationController.text,
      'images': _images,
    });
  }
  
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _saveProfile,
            icon: const Icon(Icons.check, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image Section
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[800],
                        ),
                        child: _profileImage != null
                            ? ClipOval(
                                child: Image.file(
                                  _profileImage!,
                                  fit: BoxFit.cover,
                                  width: 120,
                                  height: 120,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white54,
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 2),
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
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _pickImage,
                    child: const Text(
                      'Change Profile Photo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Form Fields
            _buildTextField(
              controller: _nameController,
              label: 'Name',
              hint: 'Enter your name',
            ),
            
            const SizedBox(height: 24),
            
            _buildTextField(
              controller: _ageController,
              label: 'Age',
              hint: 'Enter your age',
              keyboardType: TextInputType.number,
            ),
            
            const SizedBox(height: 24),
            
            _buildTextField(
              controller: _professionController,
              label: 'Profession',
              hint: 'Enter your profession',
            ),
            
            const SizedBox(height: 24),
            
            _buildTextField(
              controller: _locationController,
              label: 'Location',
              hint: 'Enter your location',
            ),
            
            const SizedBox(height: 24),
            
            _buildTextField(
              controller: _bioController,
              label: 'Bio',
              hint: 'Tell us about yourself',
              maxLines: 4,
            ),
            
            const SizedBox(height: 32),
            
            // Account Settings Section
            const Text(
              'Account Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildSettingsItem(
              icon: Icons.notifications,
              title: 'Notification Settings',
              onTap: () {
                _showSnackBar('Notification settings would open here');
              },
            ),
            
            _buildSettingsItem(
              icon: Icons.lock,
              title: 'Privacy Settings',
              onTap: () {
                _showSnackBar('Privacy settings would open here');
              },
            ),
            
            _buildSettingsItem(
              icon: Icons.security,
              title: 'Security',
              onTap: () {
                _showSnackBar('Security settings would open here');
              },
            ),
            
            _buildSettingsItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {
                _showSnackBar('Help & support would open here');
              },
            ),
            
            const SizedBox(height: 32),
            
            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showSnackBar('Logout functionality would be implemented here');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.5),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
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
}