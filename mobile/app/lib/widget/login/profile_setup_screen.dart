import 'dart:io';
import 'package:app/utils/global_country_map.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app/model/user.dart';
import 'package:app/utils/auth_service.dart';
import 'package:app/widget/splash_screen.dart';
import 'package:country_picker/country_picker.dart';

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
  String? _selectedState;
  String? _selectedCity;
  String? _selectedSuburb;
  String? _selectedCountry;
  double? _countryLat;
  double? _countryLng;
  String? _selectedCountryFlag;

  Future<void> getCoordinatesFromCountry(String countryName) async {
    try {
      List<Location> locations = await locationFromAddress(countryName);
      if (locations.isNotEmpty) {
        setState(() {
          _countryLat = locations.first.latitude;
          _countryLng = locations.first.longitude;
        });
        print('✅ Country Lat: $_countryLat, Lng: $_countryLng');
      }
    } catch (e) {
      print('Failed to get coordinates: $e');
    }
  }

  final Map<String, Map<String, List<String>>> _locationData = {
    "New South Wales": {
      "Sydney": ["Parramatta", "Bondi", "Manly", "Chatswood"],
      "Newcastle": ["Cessnock", "Maitland", "Lake Macquarie"],
    },
    "Victoria": {
      "Melbourne": ["Carlton", "Fitzroy", "Brunswick"],
      "Geelong": ["Lara", "Torquay"],
    },
    "Queensland": {
      "Brisbane": ["Fortitude Valley", "South Bank", "Paddington"],
      "Gold Coast": ["Surfers Paradise", "Broadbeach"],
    },
  };

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(
      text: "widget.user.location ?? ''",
    );
    _skillsController = TextEditingController(
      text: widget.user.skills != null ? widget.user.skills.join(', ') : '',
    );

    initializeCountryMap();

    // 🔥 After initializing the map, pre-fill selected country and flag
    if (widget.user.location != null &&
        widget.user.location!['country'] != null) {
      _selectedCountry = widget.user.location!['country'];
      _selectedCountryFlag = countryNameToFlag[_selectedCountry!] ?? '🌍';
      _countryLat = double.tryParse(
        widget.user.location!['lat']?.toString() ?? '',
      );
      _countryLng = double.tryParse(
        widget.user.location!['lng']?.toString() ?? '',
      );
    }
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
      final location =
          (_selectedCountry != null &&
                  _countryLat != null &&
                  _countryLng != null)
              ? {
                'country': _selectedCountry!,
                'lat': _countryLat.toString(),
                'lng': _countryLng.toString(),
              }
              : null;

      if (location != null) {
        await AuthService().updateUserProfile(
          userId: widget.user.id,
          name: widget.user.name,
          location: location,
          skills:
              widget.user.role == "provider"
                  ? _skillsController.text
                      .split(',')
                      .map((e) => e.trim())
                      .toList()
                  : [],
          profilePhoto: _profileImage,
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Location is null!')));
      }

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
      backgroundColor: Colors.white,
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
              OutlinedButton(
                onPressed: () {
                  showCountryPicker(
                    context: context,
                    showPhoneCode: false,
                    onSelect: (Country country) {
                      setState(() {
                        _selectedCountry = country.name;
                        _selectedCountryFlag = country.flagEmoji;
                      });
                      getCoordinatesFromCountry(
                        country.name.trim(),
                      ); // <-- Correct!
                    },
                  );
                },
                child: Text(
                  _selectedCountry == null
                      ? '🌍 Select Country'
                      : '$_selectedCountryFlag   $_selectedCountry',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
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
