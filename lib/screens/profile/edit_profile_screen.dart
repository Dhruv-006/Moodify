import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  
  String? _selectedGender;
  DateTime? _selectedDob;
  
  bool _isLoading = false;

  final List<String> _genderOptions = ['Male', 'Female', 'Non-binary', 'Prefer not to say'];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _selectedGender = user?.gender;
    if (user?.dob != null) {
      try {
        _selectedDob = DateFormat('yyyy-MM-dd').parse(user!.dob!);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final theme = Theme.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              onPrimary: theme.colorScheme.onPrimary,
              surface: theme.colorScheme.surfaceContainerHighest,
              onSurface: theme.colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDob) {
      setState(() {
        _selectedDob = picked;
      });
    }
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    
    final dobString = _selectedDob != null ? DateFormat('yyyy-MM-dd').format(_selectedDob!) : null;
    
    final success = await auth.updateProfileDetails(
      name: _nameController.text.trim(),
      gender: _selectedGender,
      dob: dobString,
    );
    
    setState(() => _isLoading = false);
    
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profile updated successfully!',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green.shade700,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            auth.errorMessage ?? 'Failed to update profile',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showEmailUpdateDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Email', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(hintText: 'New Email Address'),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              if (emailController.text.isNotEmpty) {
                final success = await context.read<AuthProvider>().updateEmail(emailController.text.trim());
                if (mounted) {
                  _showFeedback(success, 'Email updated! Check your inbox to verify.');
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPasswordUpdateDialog() {
    final passController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Password', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: passController,
          decoration: const InputDecoration(hintText: 'New Password'),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              if (passController.text.length >= 6) {
                final success = await context.read<AuthProvider>().updatePassword(passController.text);
                if (mounted) {
                  _showFeedback(success, 'Password updated successfully!');
                }
              } else {
                _showFeedback(false, 'Password must be at least 6 characters.');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  void _showFeedback(bool success, String successMsg) {
    final auth = context.read<AuthProvider>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? successMsg : (auth.errorMessage ?? 'An error occurred'),
          style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: success ? Colors.green.shade700 : Theme.of(context).colorScheme.error,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().user;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: AppBar(
              backgroundColor: theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.7),
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: theme.colorScheme.onSurface),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Edit Profile',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, kToolbarHeight + 40, 24, 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.surfaceContainerLowest,
                        border: Border.all(
                          color: theme.colorScheme.surfaceContainerLowest,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                            blurRadius: 32,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: user?.photoUrl != null
                          ? ClipOval(
                              child: Image.network(
                                user!.photoUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.person_rounded,
                                size: 48,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Photo upload coming soon!')),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.surfaceContainerLowest,
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 20,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Personal Information
              Text(
                'Personal Information',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              
              // Full Name
              TextFormField(
                controller: _nameController,
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your name' : null,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
              const SizedBox(height: 16),

              // Gender Dropdown
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: _genderOptions.map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Gender (Optional)',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
              const SizedBox(height: 16),

              // Date of Birth
              InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(16),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date of Birth (Optional)',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(20),
                  ),
                  child: Text(
                    _selectedDob != null 
                        ? DateFormat('MMMM d, yyyy').format(_selectedDob!) 
                        : 'Select date',
                    style: TextStyle(
                      color: _selectedDob != null 
                          ? theme.colorScheme.onSurface 
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Security Settings
              Text(
                'Security',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tileColor: theme.colorScheme.surfaceContainerLow,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.email_rounded, color: theme.colorScheme.primary),
                ),
                title: Text('Email Address', style: GoogleFonts.manrope(fontWeight: FontWeight.w600)),
                subtitle: Text(user?.email ?? '', style: GoogleFonts.manrope(fontSize: 13)),
                trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
                onTap: _showEmailUpdateDialog,
              ),
              const SizedBox(height: 12),
              
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tileColor: theme.colorScheme.surfaceContainerLow,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.lock_rounded, color: theme.colorScheme.primary),
                ),
                title: Text('Password', style: GoogleFonts.manrope(fontWeight: FontWeight.w600)),
                subtitle: Text('Change your password', style: GoogleFonts.manrope(fontSize: 13)),
                trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
                onTap: _showPasswordUpdateDialog,
              ),
              
              const SizedBox(height: 40),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primaryContainer,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(9999),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.6),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                        spreadRadius: -12,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
