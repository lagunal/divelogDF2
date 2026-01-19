import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:divelogtest/screens/home_screen.dart';
import 'package:divelogtest/screens/dive_list_screen.dart';
import 'package:divelogtest/screens/statistics_screen.dart';
import 'package:divelogtest/screens/profile_screen.dart';
import 'package:divelogtest/providers/dive_provider.dart';
import 'package:divelogtest/services/user_service.dart';
import 'package:divelogtest/models/user_profile.dart';
import 'package:divelogtest/widgets/sync_status_indicator.dart';
import 'package:logging/logging.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  static final Logger _log = Logger('MainNavigationScreen');
  int _currentIndex = 0;
  final UserService _userService =
      UserService(); // Now using unified UserService
  UserProfile? _userProfile;
  bool _isInitialized = false;

  final List<Widget> _screens = const [
    HomeScreen(),
    DiveListScreen(),
    StatisticsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _log.info('Starting app initialization');
    final user = FirebaseAuth.instance.currentUser;

    try {
      await _initializeUserService(user);
      final profile = await _userService.getUserProfile();
      if (profile == null) throw Exception('Profile not found');

      _log.info('User profile loaded: ${profile.name} (${profile.id})');
      await _initializeDiveProvider(profile.id);

      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isInitialized = true;
        });
        _log.info('Initialization complete');
      }
    } catch (e, stackTrace) {
      _log.severe('Error initializing app', e, stackTrace);
      if (mounted) setState(() => _isInitialized = true);
    }
  }

  Future<void> _initializeUserService(User? user) async {
    if (user != null) {
      _log.info('Initializing with Firebase user: ${user.uid}');
      await _userService.initializeWithFirebaseUser(user);
    } else {
      _log.info('Initializing with local user');
      await _userService.initialize();
    }
  }

  Future<void> _initializeDiveProvider(String userId) async {
    _log.info('Initializing DiveProvider');
    final provider = Provider.of<DiveProvider>(context, listen: false);
    await provider.initialize(userId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Show loading screen while initializing
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        centerTitle: false,
        actions: [
          const SyncStatusIndicator(),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SyncStatusBanner(),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Inmersiones',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Estadísticas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Registro de Buceo';
      case 1:
        return 'Mis Inmersiones';
      case 2:
        return 'Estadísticas';
      case 3:
        return 'Perfil';
      default:
        return 'Registro de Buceo';
    }
  }

  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 48,
              bottom: 24,
              left: 24,
              right: 24,
            ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _userProfile?.name.substring(0, 1).toUpperCase() ?? 'D',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _userProfile?.name ?? 'Usuario Demo',
                  style: theme.textTheme.titleLarge?.copyWith(
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

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _DrawerItem(
                  icon: Icons.home,
                  title: 'Inicio',
                  isSelected: _currentIndex == 0,
                  onTap: () {
                    setState(() => _currentIndex = 0);
                    Navigator.pop(context);
                  },
                ),
                _DrawerItem(
                  icon: Icons.list_alt,
                  title: 'Mis Inmersiones',
                  isSelected: _currentIndex == 1,
                  onTap: () {
                    setState(() => _currentIndex = 1);
                    Navigator.pop(context);
                  },
                ),
                _DrawerItem(
                  icon: Icons.bar_chart,
                  title: 'Estadísticas',
                  isSelected: _currentIndex == 2,
                  onTap: () {
                    setState(() => _currentIndex = 2);
                    Navigator.pop(context);
                  },
                ),
                _DrawerItem(
                  icon: Icons.person,
                  title: 'Perfil',
                  isSelected: _currentIndex == 3,
                  onTap: () {
                    setState(() => _currentIndex = 3);
                    Navigator.pop(context);
                  },
                ),
                const Divider(height: 32),
                _DrawerItem(
                  icon: Icons.settings,
                  title: 'Configuración',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to settings screen
                  },
                ),
                _DrawerItem(
                  icon: Icons.help_outline,
                  title: 'Ayuda',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to help screen
                  },
                ),
                _DrawerItem(
                  icon: Icons.info_outline,
                  title: 'Acerca de',
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Registro de Buceo v1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.scuba_diving, color: colorScheme.primary, size: 28),
            const SizedBox(width: 12),
            const Text('Acerca de'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registro de Buceo',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Versión 1.0.0',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Una aplicación profesional para registrar y gestionar tus sesiones de buceo. Mantén un registro detallado de todas tus inmersiones, equipos, condiciones del agua y más.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              '© 2024 Registro de Buceo',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer.withValues(alpha: 0.5)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
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
