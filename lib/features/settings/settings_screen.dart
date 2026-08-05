import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import 'settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _businessNameController;
  late final TextEditingController _ownerNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _currencyController;
  bool _isLoading = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _businessNameController = TextEditingController();
    _ownerNameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _currencyController = TextEditingController();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  void _initControllers(BusinessProfile profile) {
    if (_initialized) return;
    _businessNameController.text = profile.businessName;
    _ownerNameController.text = profile.ownerName;
    _phoneController.text = profile.phone;
    _addressController.text = profile.address;
    _currencyController.text = profile.currencySymbol;
    _initialized = true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(settingsNotifierProvider.notifier).save(
            BusinessProfile(
              businessName: _businessNameController.text.trim(),
              ownerName: _ownerNameController.text.trim(),
              phone: _phoneController.text.trim(),
              address: _addressController.text.trim(),
              currencySymbol: _currencyController.text.trim(),
            ),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business profile saved successfully!'),
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Profile'),
      ),
      body: settingsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          _initControllers(profile);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Business avatar
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              profile.businessName.isNotEmpty
                                  ? profile.businessName[0]
                                      .toUpperCase()
                                  : 'B',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          profile.businessName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (profile.address.isNotEmpty)
                          Text(
                            profile.address,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Business info section
                  _sectionHeader(
                      'Business Information', Icons.store_outlined),
                  const SizedBox(height: 12),
                  _field(
                    controller: _businessNameController,
                    label: 'Business Name',
                    icon: Icons.store_outlined,
                    isRequired: true,
                  ),
                  const SizedBox(height: 12),
                  _field(
                    controller: _addressController,
                    label: 'Address',
                    icon: Icons.location_on_outlined,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  // Owner info section
                  _sectionHeader(
                      'Owner Information', Icons.person_outlined),
                  const SizedBox(height: 12),
                  _field(
                    controller: _ownerNameController,
                    label: 'Owner Name',
                    icon: Icons.person_outlined,
                  ),
                  const SizedBox(height: 12),
                  _field(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),

                  // Regional settings
                  _sectionHeader(
                      'Regional Settings', Icons.language_outlined),
                  const SizedBox(height: 12),
                  _field(
                    controller: _currencyController,
                    label: 'Currency Symbol (e.g. ZMW, USD, ZAR)',
                    icon: Icons.attach_money_outlined,
                    isRequired: true,
                  ),
                  const SizedBox(height: 32),

                  const SizedBox(height: 24),

// Appearance section
_sectionHeader('Appearance', Icons.palette_outlined),
const SizedBox(height: 12),

Consumer(
  builder: (context, ref, _) {
    final darkModeAsync = ref.watch(darkModeProvider);
    final isDark = darkModeAsync.valueOrNull ?? false;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SwitchListTile(
        title: const Text('Dark Mode'),
        subtitle: Text(
          isDark ? 'Dark theme enabled' : 'Light theme enabled',
          style: const TextStyle(fontSize: 12),
        ),
        secondary: Icon(
          isDark
              ? Icons.dark_mode_outlined
              : Icons.light_mode_outlined,
          color: AppColors.primary,
        ),
        value: isDark,
        activeThumbColor: AppColors.primary,
        onChanged: (_) =>
            ref.read(darkModeProvider.notifier).toggle(),
      ),
    );
  },
),

const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isLoading ? null : _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white),
                            )
                          : const Icon(Icons.save_outlined),
                      label: const Text('Save Profile',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (v) {
        if (isRequired && (v == null || v.trim().isEmpty)) {
          return '$label is required';
        }
        return null;
      },
    );
  }
}