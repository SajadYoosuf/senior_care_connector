import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';

class RequestHelpScreen extends StatefulWidget {
  const RequestHelpScreen({super.key});

  @override
  State<RequestHelpScreen> createState() => _RequestHelpScreenState();
}

class _RequestHelpScreenState extends State<RequestHelpScreen> {
  String? _selectedCategory;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _locationText = '';
  File? _imageFile;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isLoadingLocation = false;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Grocery Delivery',
    'Transportation',
    'Housekeeping',
    'Companionship',
    'Medical Assistance',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  // ─── Date → auto-open Time ───────────────────────────────────────────────────
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      if (context.mounted) await _selectTime(context);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  // ─── Get Current Location ────────────────────────────────────────────────────
  Future<void> _useCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      // 1. Check / request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _snack(
            'Permission denied. Please tap Allow when asked.',
            isError: true,
          );
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        _showSettingsDialog(
          icon: Icons.block,
          iconColor: Colors.red,
          title: 'Permission Blocked',
          message:
              'Location permission is permanently blocked.\n\n'
              'Go to: Settings → Apps → This App → Permissions → Location → Allow.',
          onSettings: () => Geolocator.openAppSettings(),
        );
        return;
      }

      // 2. Try last known cached position first (instant, no service wait)
      Position? position = await Geolocator.getLastKnownPosition();

      // 3. If no cache, actually request current position
      position ??=
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.lowest,
          ).timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('timeout'),
          );

      // 4. Reverse geocode coords → readable address
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        final Placemark p = placemarks.first;
        final String address = [
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
        ].where((e) => e != null && e.isNotEmpty).join(', ');
        setState(() => _locationText = address);
      }
    } on LocationServiceDisabledException {
      if (!mounted) return;
      _showSettingsDialog(
        icon: Icons.location_off,
        iconColor: Colors.orange,
        title: 'Location is Off',
        message:
            'Your phone\'s Location service is turned off.\n\n'
            'Please go to Settings and turn ON Location, then try again.',
        onSettings: () => Geolocator.openLocationSettings(),
      );
    } catch (e) {
      // Print real error for debugging in the run console
      debugPrint('📍 Location error [${e.runtimeType}]: $e');

      final errStr = e.toString().toLowerCase();
      if (errStr.contains('disabled') || errStr.contains('location_service')) {
        if (!mounted) return;
        _showSettingsDialog(
          icon: Icons.location_off,
          iconColor: Colors.orange,
          title: 'Location is Off',
          message:
              'Your phone\'s Location service is turned off.\n\n'
              'Please go to Settings and turn ON Location, then try again.',
          onSettings: () => Geolocator.openLocationSettings(),
        );
      } else if (errStr.contains('timeout')) {
        _snack('Took too long. Please try again.', isError: true);
      } else {
        // Show actual error type in snack to help debug
        _snack(
          'Error: ${e.runtimeType}. Check console for details.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _showSettingsDialog({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required Future<void> Function() onSettings,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 8),
            Flexible(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await onSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // ─── Submit to Firestore ─────────────────────────────────────────────────────
  Future<void> _submitRequest() async {
    if (_titleController.text.trim().isEmpty) {
      _snack('Please enter a task title.', isError: true);
      return;
    }
    if (_selectedCategory == null) {
      _snack('Please select a category.', isError: true);
      return;
    }
    if (_selectedDate == null) {
      _snack('Please select a date.', isError: true);
      return;
    }
    if (_selectedTime == null) {
      _snack('Please select a time.', isError: true);
      return;
    }
    if (_locationText.trim().isEmpty) {
      _snack('Please get your location first.', isError: true);
      return;
    }

    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() => _isSubmitting = true);
    try {
      final DateTime scheduledAt = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      String imageUrl = '';
      if (_imageFile != null) {
        final bytes = await _imageFile!.readAsBytes();
        imageUrl = base64Encode(bytes);
      }

      await FirebaseFirestore.instance.collection('help_requests').add({
        'userId': user.id,
        'userName': user.name,
        'userEmail': user.email,
        'title': _titleController.text.trim(),
        'category': _selectedCategory,
        'imageUrl': imageUrl,
        'scheduledAt': Timestamp.fromDate(scheduledAt),
        'location': _locationText.trim(),
        'notes': _notesController.text.trim(),
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      debugPrint('Submit error: $e');
      _snack('Failed to submit. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'Request Submitted!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your request has been posted. Volunteers will see it shortly.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  // Reset form for next time if desired
                  setState(() {
                    _titleController.clear();
                    _notesController.clear();
                    _selectedCategory = null;
                    _selectedDate = null;
                    _selectedTime = null;
                    _locationText = '';
                    _imageFile = null;
                  });
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Back to Dashboard',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade700 : AppColors.primary,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Request Help',
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 0. Title ───────────────────────────────────────────────────
              _sectionTitle('Task Title *'),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'e.g., Grocery Shopping, Doctor Visit',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── 1. Category ────────────────────────────────────────────────
              _sectionTitle('What do you need help with?'),
              const SizedBox(height: 4),
              const Text(
                'Select a category for your request',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 12),
              _categoryDropdown(),

              const SizedBox(height: 28),

              // ── 2. Date & Time ────────────────────────────────────────────
              _sectionTitle('When do you need help?'),
              const SizedBox(height: 4),
              const Text(
                'Select date — time picker opens right after',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _tappableField(
                      label: _selectedDate == null
                          ? 'Select Date *'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      icon: Icons.calendar_month,
                      onTap: () => _selectDate(context),
                      hasValue: _selectedDate != null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _tappableField(
                      label: _selectedTime == null
                          ? 'Select Time *'
                          : _selectedTime!.format(context),
                      icon: Icons.access_time,
                      onTap: () => _selectTime(context),
                      hasValue: _selectedTime != null,
                      highlightRequired:
                          _selectedDate != null && _selectedTime == null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── 3. Location ───────────────────────────────────────────────
              _sectionTitle('Where do you need help?'),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoadingLocation ? null : _useCurrentLocation,
                  icon: _isLoadingLocation
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.my_location, size: 20),
                  label: Text(
                    _isLoadingLocation
                        ? 'Getting location…'
                        : 'Get My Current Location',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // Show fetched address or "not yet" hint
              const SizedBox(height: 10),
              if (_locationText.isEmpty)
                Text(
                  'Tap the button above to detect your location',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                )
              else
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.green.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _locationText,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.refresh,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Refresh location',
                        onPressed: _useCurrentLocation,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 28),

              // ── 4. Image Upload ───────────────────────────────────────────
              _sectionTitle('Add an Image (Optional)'),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(_imageFile!, fit: BoxFit.cover),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _imageFile = null),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
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
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to upload an image',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 28),

              // ── 5. Notes ──────────────────────────────────────────────────
              _sectionTitle('Additional Notes'),
              const SizedBox(height: 4),
              const Text(
                'Describe how a volunteer can help you (optional)',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                      'e.g. Need help carrying groceries to the 3rd floor, no elevator',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              _isSubmitting
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : CustomButton(
                      text: 'Submit Request',
                      onPressed: _submitRequest,
                      backgroundColor: AppColors.primary,
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: AppColors.black,
    ),
  );

  Widget _categoryDropdown() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedCategory,
        hint: const Text('Select a category'),
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
        items: _categories.map((String cat) {
          return DropdownMenuItem<String>(
            value: cat,
            child: Row(
              children: [
                Icon(_categoryIcon(cat), color: AppColors.primary, size: 18),
                const SizedBox(width: 10),
                Text(cat),
              ],
            ),
          );
        }).toList(),
        onChanged: (v) => setState(() => _selectedCategory = v),
      ),
    ),
  );

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Grocery Delivery':
        return Icons.shopping_cart_outlined;
      case 'Transportation':
        return Icons.directions_car_outlined;
      case 'Housekeeping':
        return Icons.cleaning_services_outlined;
      case 'Companionship':
        return Icons.favorite_outline;
      case 'Medical Assistance':
        return Icons.medical_services_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Widget _tappableField({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool hasValue,
    bool highlightRequired = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: highlightRequired
              ? Colors.orange.shade50
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: highlightRequired
                ? Colors.orange.shade400
                : Colors.grey.shade300,
            width: highlightRequired ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: highlightRequired ? Colors.orange : AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: hasValue
                      ? Colors.black87
                      : highlightRequired
                      ? Colors.orange.shade700
                      : Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: highlightRequired
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
