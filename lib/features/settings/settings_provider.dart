import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BusinessProfile {
  final String businessName;
  final String ownerName;
  final String phone;
  final String address;
  final String currencySymbol;

  BusinessProfile({
    this.businessName = 'My Business',
    this.ownerName = '',
    this.phone = '',
    this.address = '',
    this.currencySymbol = 'ZMW',
  });

  BusinessProfile copyWith({
    String? businessName,
    String? ownerName,
    String? phone,
    String? address,
    String? currencySymbol,
  }) {
    return BusinessProfile(
      businessName: businessName ?? this.businessName,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      currencySymbol: currencySymbol ?? this.currencySymbol,
    );
  }
}

class SettingsNotifier extends AsyncNotifier<BusinessProfile> {
  static const _keyBusinessName = 'business_name';
  static const _keyOwnerName = 'owner_name';
  static const _keyPhone = 'phone';
  static const _keyAddress = 'address';
  static const _keyCurrency = 'currency_symbol';

  @override
  Future<BusinessProfile> build() async {
    final prefs = await SharedPreferences.getInstance();
    return BusinessProfile(
      businessName:
          prefs.getString(_keyBusinessName) ?? 'My Business',
      ownerName: prefs.getString(_keyOwnerName) ?? '',
      phone: prefs.getString(_keyPhone) ?? '',
      address: prefs.getString(_keyAddress) ?? '',
      currencySymbol: prefs.getString(_keyCurrency) ?? 'ZMW',
    );
  }

  Future<void> save(BusinessProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBusinessName, profile.businessName);
    await prefs.setString(_keyOwnerName, profile.ownerName);
    await prefs.setString(_keyPhone, profile.phone);
    await prefs.setString(_keyAddress, profile.address);
    await prefs.setString(_keyCurrency, profile.currencySymbol);
    state = AsyncValue.data(profile);
  }
}

final settingsNotifierProvider =
    AsyncNotifierProvider<SettingsNotifier, BusinessProfile>(
        SettingsNotifier.new);

// Convenience provider to just read the profile
final businessProfileProvider = Provider<BusinessProfile>((ref) {
  return ref.watch(settingsNotifierProvider).valueOrNull ??
      BusinessProfile();
});
const _keyDarkMode = 'dark_mode';

final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  Future<void> toggle() async {
    final current = state.valueOrNull ?? false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, !current);
    state = AsyncValue.data(!current);
  }
}