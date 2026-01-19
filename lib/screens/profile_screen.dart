import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:divelogtest/models/user_profile.dart';
import 'package:divelogtest/services/user_service.dart';
import 'package:divelogtest/auth/firebase_auth_manager.dart';
import 'package:divelogtest/theme.dart';
import 'package:logging/logging.dart';

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
  User? _currentFirebaseUser;

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

  void _showEditProfileDialog() {
    if (_userProfile == null) return;

    final nameController = TextEditingController(text: _userProfile!.name);
    final emailController = TextEditingController(text: _userProfile!.email);
    final certLevelController =
        TextEditingController(text: _userProfile!.certificationLevel);
    final certNumberController =
        TextEditingController(text: _userProfile!.certificationNumber);

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

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Dive Log App',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 Dive Log App',
      children: [
        const SizedBox(height: 16),
        const Text(
            'Una aplicación profesional para registrar y gestionar tus inmersiones de buceo.'),
      ],
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
                              ),
                              child: Center(
                                child: Text(
                                  _userProfile?.name
                                          .substring(0, 1)
                                          .toUpperCase() ??
                                      'D',
                                  style:
                                      theme.textTheme.displayMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
                                value: '${_userProfile?.totalDives ?? 0}',
                                label: 'Inmersiones',
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.schedule,
                                value: '${_userProfile?.totalBottomTime ?? 0}m',
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
                              label: 'Certificación',
                              value: _userProfile?.certificationLevel ??
                                  'No especificada',
                            ),
                          ],
                        ),
                      ),

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
                            _SettingsItem(
                              icon: Icons.notifications,
                              title: 'Notificaciones',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Próximamente')),
                                );
                              },
                            ),
                            _SettingsItem(
                              icon: Icons.privacy_tip,
                              title: 'Privacidad',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Próximamente')),
                                );
                              },
                            ),
                            _SettingsItem(
                              icon: Icons.help,
                              title: 'Ayuda y Soporte',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Próximamente')),
                                );
                              },
                            ),
                            _SettingsItem(
                              icon: Icons.info,
                              title: 'Acerca de',
                              onTap: _showAboutDialog,
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
