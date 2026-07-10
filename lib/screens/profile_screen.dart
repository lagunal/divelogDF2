import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:divedatapro/models/user_profile.dart';
import 'package:divedatapro/services/user_service.dart';
import 'package:divedatapro/services/firebase_storage_service.dart';
import 'package:divedatapro/auth/firebase_auth_manager.dart';
import 'package:divedatapro/screens/privacy_policy_screen.dart';
import 'package:divedatapro/widgets/custom_about_dialog.dart';
import 'package:divedatapro/theme.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:divedatapro/providers/dive_provider.dart';
import 'package:divedatapro/screens/paywall_screen.dart';
import 'package:divedatapro/services/subscription_service.dart';

class ProfileScreen extends StatefulWidget {
  final UserService? userService;
  final FirebaseAuthManager? authManager;

  const ProfileScreen({
    super.key,
    this.userService,
    this.authManager,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static final Logger _log = Logger('ProfileScreen');
  late final UserService _userService;
  late final FirebaseAuthManager _authManager;
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _isUploadingPhoto = false;
  User? _currentFirebaseUser;
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseStorageService _storageService = FirebaseStorageService();

  Future<void> _handleLogout() async {
    try {
      await _authManager.signOut();
      // No need to navigate - AuthWrapper will automatically show LoginScreen
      // when Firebase auth state changes to null
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesión cerrada correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    }
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null || _currentFirebaseUser == null) return;

      setState(() => _isUploadingPhoto = true);

      final File imageFile = File(pickedFile.path);
      final downloadUrl = await _storageService.uploadProfilePhoto(
        imageFile,
        _currentFirebaseUser!.uid,
      );

      if (downloadUrl != null) {
        await _userService.updateUserProfile(photoUrl: downloadUrl);
        await _loadUserProfile();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto de perfil actualizada')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al subir la foto')),
          );
        }
      }
    } catch (e) {
      _log.severe('Error in _pickAndUploadImage', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar la imagen: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de galería'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    if (_userProfile == null) return;

    final nameController = TextEditingController(text: _userProfile!.name);
    final emailController = TextEditingController(text: _userProfile!.email);
    final certLevelController =
        TextEditingController(text: _userProfile!.certificationLevel);
    final certNumberController =
        TextEditingController(text: _userProfile!.certificationNumber);
    final bloodTypeController =
        TextEditingController(text: _userProfile!.bloodType);
    final emergencyContactController =
        TextEditingController(text: _userProfile!.emergencyContact);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                enabled: false,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: certLevelController,
                decoration:
                    const InputDecoration(labelText: 'Nivel Certificación'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: certNumberController,
                decoration:
                    const InputDecoration(labelText: 'Número Certificación'),
              ),
              const SizedBox(height: 8),
              const SizedBox(height: 8),
              TextField(
                controller: bloodTypeController,
                decoration: const InputDecoration(labelText: 'Tipo de Sangre'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emergencyContactController,
                decoration:
                    const InputDecoration(labelText: 'Contacto de Emergencia'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await _userService.updateUserProfile(
                name: nameController.text,
                certificationLevel: certLevelController.text,
                certificationNumber: certNumberController.text,
                bloodType: bloodTypeController.text.isEmpty
                    ? null
                    : bloodTypeController.text,
                emergencyContact: emergencyContactController.text.isEmpty
                    ? null
                    : emergencyContactController.text,
              );
              if (mounted) {
                Navigator.pop(context);
                _loadUserProfile();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _userService = widget.userService ?? UserService();
    _authManager = widget.authManager ?? FirebaseAuthManager();
    _currentFirebaseUser = FirebaseAuth.instance.currentUser;
    _loadUserProfile();

    // Listen to auth state changes to refresh profile when user changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted && user != null && user.uid != _currentFirebaseUser?.uid) {
        _currentFirebaseUser = user;
        _log.info('Auth state changed, reloading profile for: ${user.uid}');
        _loadUserProfile();
      }
    });
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      await _userService.initialize();
      final userId = _userService.getCurrentUserId();
      if (userId != null) {
        final profile = await _userService.getUserProfile();
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final diveProvider = Provider.of<DiveProvider>(context);
    final isPremium = diveProvider.isPremium;
    final stats = diveProvider.statistics;
    final totalDives = stats['totalDives'] ?? _userProfile?.totalDives ?? 0;
    final totalBottomTime =
        stats['totalBottomTime'] ?? _userProfile?.totalBottomTime ?? 0;

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadUserProfile,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Profile Header
                      Container(
                        width: double.infinity,
                        padding: AppSpacing.paddingLg,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.primary,
                              colorScheme.primary.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _showImageSourceDialog,
                              child: Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 4,
                                      ),
                                      image: _userProfile?.photoUrl != null &&
                                              _userProfile!.photoUrl!.isNotEmpty
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                  _userProfile!.photoUrl!),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: _userProfile?.photoUrl != null &&
                                            _userProfile!.photoUrl!.isNotEmpty
                                        ? null
                                        : Center(
                                            child: Text(
                                              _userProfile?.name
                                                      .substring(0, 1)
                                                      .toUpperCase() ??
                                                  'D',
                                              style: theme
                                                  .textTheme.displayMedium
                                                  ?.copyWith(
                                                color: colorScheme.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                  ),
                                  if (_isUploadingPhoto)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black45,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: colorScheme.secondary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _userProfile?.name ?? 'Usuario Demo',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userProfile?.email ?? 'demo@buceo.com',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Profile Stats
                      Padding(
                        padding: AppSpacing.horizontalLg,
                        child: Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                icon: Icons.water,
                                value: '$totalDives',
                                label: 'Inmersiones',
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.schedule,
                                value: '${totalBottomTime}m',
                                label: 'Tiempo Total',
                                color: colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Profile Information
                      Padding(
                        padding: AppSpacing.horizontalLg,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Información Personal',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _InfoCard(
                              icon: Icons.person,
                              label: 'Nombre',
                              value: _userProfile?.name ?? 'Usuario Demo',
                            ),
                            const SizedBox(height: 8),
                            _InfoCard(
                              icon: Icons.email,
                              label: 'Email',
                              value: _userProfile?.email ?? 'demo@buceo.com',
                            ),
                            const SizedBox(height: 8),
                            _InfoCard(
                              icon: Icons.badge,
                              label: 'Nivel de Certificación',
                              value: _userProfile?.certificationLevel ??
                                  'No especificada',
                            ),
                            const SizedBox(height: 8),
                            _InfoCard(
                              icon: Icons.numbers,
                              label: 'Número Certificación',
                              value: _userProfile?.certificationNumber ??
                                  'No especificado',
                            ),
                            const SizedBox(height: 8),
                            _InfoCard(
                              icon: Icons.bloodtype,
                              label: 'Tipo de Sangre',
                              value:
                                  _userProfile?.bloodType ?? 'No especificado',
                            ),
                            const SizedBox(height: 8),
                            _InfoCard(
                              icon: Icons.contact_emergency,
                              label: 'Contacto de Emergencia',
                              value: _userProfile?.emergencyContact ??
                                  'No especificado',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Premium Banner
                      _buildPremiumBanner(context, isPremium),

                      const SizedBox(height: 24),

                      // Settings Section
                      Padding(
                        padding: AppSpacing.horizontalLg,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Configuración',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _SettingsItem(
                              icon: Icons.edit,
                              title: 'Editar Perfil',
                              onTap: _showEditProfileDialog,
                            ),
                            /*
                            _SettingsItem(
                              icon: Icons.notifications,
                              title: 'Notificaciones',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Próximamente')),
                                );
                              },
                            ),
                            */
                            _SettingsItem(
                              icon: Icons.privacy_tip,
                              title: 'Privacidad',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PrivacyPolicyScreen(),
                                  ),
                                );
                              },
                            ),
                            /*
                            _SettingsItem(
                              icon: Icons.help,
                              title: 'Ayuda y Soporte',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Próximamente')),
                                );
                              },
                            ),
                            */
                            _SettingsItem(
                              icon: Icons.info,
                              title: 'Acerca de',
                              onTap: () => showCustomAboutDialog(context),
                            ),
                            const SizedBox(height: 8),
                            _SettingsItem(
                              icon: Icons.logout,
                              title: 'Cerrar Sesión',
                              isDestructive: true,
                              onTap: _handleLogout,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildPremiumBanner(BuildContext context, bool isPremium) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isPremium) {
      return Padding(
        padding: AppSpacing.horizontalLg,
        child: Container(
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border:
                Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.star, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Cuenta Premium Activa',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: AppSpacing.horizontalLg,
      child: InkWell(
        onTap: () async {
          // final result = await Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => const PaywallScreen()),
          // );

          final result =
              await SubscriptionService.checkPremiumAndProceed(context);

          if (result == true) {
            _loadUserProfile(); // Reload to get updated premium status
            context
                .read<DiveProvider>()
                .refreshData(_userService.getCurrentUserId() ?? '');
          }
        },
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              const Icon(Icons.diamond_outlined, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actualizar a Premium',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Desbloquea exportación a PDF/CSV y más',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                icon,
                color: colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive
                  ? colorScheme.error
                  : colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color:
                      isDestructive ? colorScheme.error : colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
