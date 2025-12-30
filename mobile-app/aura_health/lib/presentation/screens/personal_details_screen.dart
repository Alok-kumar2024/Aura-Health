import 'dart:io';
import 'package:aura_heallth/presentation/screens/home_screen.dart';
import 'package:aura_heallth/state/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../service/local_storage_service.dart';

class PersonalDetailsScreen extends ConsumerStatefulWidget {
  final ProfileState? existingProfile;

  const PersonalDetailsScreen({super.key, this.existingProfile});

  @override
  ConsumerState<PersonalDetailsScreen> createState() =>
      _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends ConsumerState<PersonalDetailsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;

  String _selectedGender = "Male";
  String? _selectedBloodGroup;
  File? _profileImage;

  // 1. LOADING STATE
  bool _isLoading = false;

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];

  @override
  void initState() {
    super.initState();
    final profile = widget.existingProfile;

    _nameController = TextEditingController(text: profile?.name ?? "");
    _ageController = TextEditingController(
      text: (profile?.age == "--" || profile?.age == null) ? "" : profile!.age,
    );
    _weightController = TextEditingController(
      text: (profile?.weight == "--" || profile?.weight == null)
          ? ""
          : profile!.weight,
    );
    _heightController = TextEditingController(
      text: (profile?.height == "--" || profile?.height == null)
          ? ""
          : profile!.height,
    );

    if (profile != null) {
      if (['Male', 'Female', 'Other'].contains(profile.gender))
        _selectedGender = profile.gender;
      if (_bloodGroups.contains(profile.bloodGroup))
        _selectedBloodGroup = profile.bloodGroup;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.existingProfile != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            title: Text(
              isEditMode ? "Edit Profile" : "Complete Profile",
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w800,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: isEditMode
                ? IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.black,
                    ),
                    onPressed: () => Navigator.pop(context),
                  )
                : null,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- PROFILE IMAGE HEADER ---
                Center(
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: _getAvatarImage(),
                          child:
                              _profileImage == null &&
                                  widget.existingProfile?.imagePath == null
                              ? const Icon(
                                  Icons.person,
                                  size: 55,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E88E5),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF1E88E5,
                                  ).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // --- PERSONAL INFO ---
                _buildSectionHeader("Personal Information"),

                _buildLabel("Full Name"),
                _buildTextField(
                  _nameController,
                  "John Doe",
                  Icons.person_outline,
                ),
                const SizedBox(height: 20),

                const Text(
                  "Gender",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildGenderChip("Male", Icons.male),
                    const SizedBox(width: 12),
                    _buildGenderChip("Female", Icons.female),
                    const SizedBox(width: 12),
                    _buildGenderChip("Other", Icons.transgender),
                  ],
                ),

                const SizedBox(height: 32),

                // --- VITALS ---
                _buildSectionHeader("Body Vitals"),

                _buildLabel("Age"),
                _buildNumberField(_ageController, "e.g. 24", "yrs"),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Weight"),
                          _buildNumberField(_weightController, "e.g. 70", "kg"),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Height"),
                          _buildNumberField(
                            _heightController,
                            "e.g. 175",
                            "cm",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _buildLabel("Blood Group (Optional)"),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedBloodGroup,
                      hint: Text(
                        "Select Type",
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF1E88E5),
                      ),
                      borderRadius: BorderRadius.circular(16),
                      items: _bloodGroups.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) =>
                          setState(() => _selectedBloodGroup = newValue),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // --- SAVE BUTTON WITH LOADING ---
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSave,
                    // Disable when loading
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: const Color(0xFF1E88E5).withOpacity(0.3),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            isEditMode ? "Save Changes" : "Complete Setup",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- LOGIC ---
  ImageProvider? _getAvatarImage() {
    if (_profileImage != null) {
      return FileImage(_profileImage!);
    }
    if (widget.existingProfile?.imagePath != null &&
        widget.existingProfile!.imagePath!.isNotEmpty) {
      return FileImage(File(widget.existingProfile!.imagePath!));
    }
    return null;
  }

  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus();
    final isEditMode = widget.existingProfile != null;

    if (_nameController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _heightController.text.isEmpty) {
      _showCustomSnackBar(context, "Please fill in all required fields", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final storage = LocalStorageService();

      // 1. This now updates Hive AND Firestore (via the new LocalStorageService code)
      await storage.saveVitals(
        gender: _selectedGender,
        age: _ageController.text.trim(),
        weight: _weightController.text.trim(),
        height: _heightController.text.trim(),
        bloodGroup: _selectedBloodGroup,
      );

      await storage.updateName(_nameController.text.trim());

      if (_profileImage != null) {
        await storage.saveProfileImage(_profileImage!.path);
      }

      // 2. Trigger a Cloud Sync to ensure Notifier state is fresh
      await ref.read(profileProvider.notifier).syncFromCloud();

      if (mounted) {
        if (isEditMode) {
          Navigator.pop(context);
          _showCustomSnackBar(context, "Profile Updated Successfully!");
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showCustomSnackBar(context, "Error saving data. Please try again.", isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- HELPERS ---

  // 2. CUSTOM SNACKBAR
  void _showCustomSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
  );

  Widget _buildNumberField(TextEditingController c, String h, String s) =>
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF1E88E5),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            hintText: h,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.normal,
            ),
            suffixText: s,
            suffixStyle: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

  Widget _buildTextField(TextEditingController c, String h, IconData i) =>
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: c,
          style: const TextStyle(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF1E88E5),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            prefixIcon: Icon(i, color: Colors.grey),
            hintText: h,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      );

  Widget _buildGenderChip(String l, IconData i) {
    final s = _selectedGender == l;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedGender = l),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: s ? const Color(0xFF1E88E5).withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: s ? const Color(0xFF1E88E5) : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: s
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            children: [
              Icon(
                i,
                color: s ? const Color(0xFF1E88E5) : Colors.grey.shade400,
                size: 26,
              ),
              const SizedBox(height: 6),
              Text(
                l,
                style: TextStyle(
                  color: s ? const Color(0xFF1E88E5) : Colors.grey.shade400,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
