import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:logging/logging.dart';
import 'package:divedatapro/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:divedatapro/providers/dive_provider.dart';
import 'package:divedatapro/screens/paywall_screen.dart';

class SubscriptionService {
  static final Logger _log = Logger('SubscriptionService');
  static final SubscriptionService _instance = SubscriptionService._internal();

  factory SubscriptionService() => _instance;

  SubscriptionService._internal();

  // TODO: Replace with your actual RevenueCat API keys
  // For Test Store: Create a Test Store in RevenueCat Dashboard -> Apps and Providers
  // and paste the API key starting with 'test_' here.
  // IMPORTANT: Clear this out before releasing to production!
  static const String _testApiKey = ''; // e.g., 'test_...'

  static const String _appleApiKey = 'YOUR_APPLE_API_KEY';
  static const String _googleApiKey = 'goog_YHMzrlNhuWqAKzfCqjEAWDWmjea';
  static const String _entitlementId = 'premium';

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    if (kIsWeb) {
      _log.warning('RevenueCat is not fully supported on Web natively yet.');
      return;
    }

    try {
      await Purchases.setLogLevel(LogLevel.info);

      PurchasesConfiguration? configuration;

      // Prioritize Test API key if provided
      if (_testApiKey.isNotEmpty && _testApiKey.startsWith('test_')) {
        _log.info('Using RevenueCat Test Store API Key');
        configuration = PurchasesConfiguration(_testApiKey);
      } else {
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          configuration = PurchasesConfiguration(_appleApiKey);
        } else if (defaultTargetPlatform == TargetPlatform.android) {
          configuration = PurchasesConfiguration(_googleApiKey);
        }
      }

      if (configuration != null) {
        await Purchases.configure(configuration);
        _isInitialized = true;
        _log.info('RevenueCat initialized successfully');

        // Identify user if already logged in
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await login(user.uid);
        }
      }
    } catch (e) {
      _log.severe('Failed to initialize RevenueCat', e);
    }
  }

  Future<void> login(String userId) async {
    if (!_isInitialized) return;
    try {
      await Purchases.logIn(userId);
      await checkPremiumAccess();
    } catch (e) {
      _log.severe('Failed to login to RevenueCat', e);
    }
  }

  Future<void> logout() async {
    if (!_isInitialized) return;
    try {
      await Purchases.logOut();
    } catch (e) {
      _log.severe('Failed to logout from RevenueCat', e);
    }
  }

  Future<bool> checkPremiumAccess() async {
    if (!_isInitialized) return false;

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final isPremium =
          customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;

      // Sync with our local UserProfile database
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userService = UserService();
        // Passing true for 'forceRefresh' isn't explicitly available, just get current profile
        final profile = await userService.getUserProfile();
        if (profile != null && profile.isPremium != isPremium) {
          await userService.updateUserProfile(isPremium: isPremium);
        }
      }

      return isPremium;
    } catch (e) {
      _log.severe('Error checking premium access', e);
      return false;
    }
  }

  Future<List<Package>> getOfferings() async {
    if (!_isInitialized) return [];

    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        return offerings.current!.availablePackages;
      }
      return [];
    } catch (e) {
      _log.severe('Error getting offerings', e);
      return [];
    }
  }

  /// Checks if the user is premium. If not, shows the Paywall.
  /// Returns `true` if the user is premium or successfully purchased premium.
  static Future<bool> checkPremiumAndProceed(BuildContext context) async {
    try {
      final isPremium = context.read<DiveProvider>().isPremium;
      if (isPremium) return true;

      // When migrating to RevenueCatUI, simply replace these lines with:
      // await RevenueCatUI.presentPaywall();
      // TODO: migrate to GoRouter (context.push) instead of Navigator.push.
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (context) => const PaywallScreen()),
      );
      return result == true;
    } catch (e) {
      _log.severe('Error checking premium/proceeding to paywall', e);
      return false;
    }
  }

  Future<bool> purchasePackage(Package package) async {
    if (!_isInitialized) return false;

    try {
      final purchaseParams = PurchaseParams.package(package);
      final result = await Purchases.purchase(purchaseParams);
      final isPremium =
          result.customerInfo.entitlements.all[_entitlementId]?.isActive ??
              false;

      // Update local db if successful
      if (isPremium) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final userService = UserService();
          final profile = await userService.getUserProfile();
          if (profile != null) {
            await userService.updateUserProfile(isPremium: true);
          }
        }
      }

      return isPremium;
    } catch (e) {
      _log.severe('Purchase failed', e);
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    if (!_isInitialized) return false;

    try {
      final customerInfo = await Purchases.restorePurchases();
      final isPremium =
          customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;

      if (isPremium) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final userService = UserService();
          final profile = await userService.getUserProfile();
          if (profile != null) {
            await userService.updateUserProfile(isPremium: true);
          }
        }
      }

      return isPremium;
    } catch (e) {
      _log.severe('Restore purchases failed', e);
      return false;
    }
  }
}
