import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app/model/user.dart';
import 'package:app/utils/auth_service.dart';
import 'package:app/widget/splash_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final User user;

  const ProfileSetupScreen({required this.user, super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _locationController;
  late TextEditingController _skillsController;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(
      text: widget.user.location ?? '',
    );
    _skillsController = TextEditingController(
      text: widget.user.skills != null ? widget.user.skills.join(', ') : '',
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _profileImage = File(image.path));
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await AuthService().updateUserProfile(
        userId: widget.user.id,
        name: widget.user.name,
        location: _locationController.text.trim(),
        skills:
            widget.user.role == "provider"
                ? _skillsController.text
                    .split(',')
                    .map((e) => e.trim())
                    .toList()
                : [],
        profilePhoto: _profileImage,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Profile updated successfully!')));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SplashScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isProvider = widget.user.role == 'provider';

    return Scaffold(
      appBar: AppBar(title: Text("Complete Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_profileImage != null)
                CircleAvatar(
                  backgroundImage: FileImage(_profileImage!),
                  radius: 50,
                )
              else
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(Icons.person, size: 40),
                ),
              SizedBox(height: 12),
              TextButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.upload),
                label: Text("Upload Profile Photo"),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.user.email,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Divider(thickness: 1),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: "Location"),
              ),
              if (isProvider) ...[
                SizedBox(height: 20),
                TextFormField(
                  controller: _skillsController,
                  decoration: InputDecoration(
                    labelText: "Skills (comma-separated)",
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please enter at least one skill';
                    }
                    return null;
                  },
                ),
              ],
              SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _submitProfile,
                icon: Icon(Icons.save),
                label: Text("Save Profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
