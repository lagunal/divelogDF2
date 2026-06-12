import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:divelogtest/services/subscription_service.dart';
import 'package:divelogtest/theme.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _isLoading = true;
  List<Package> _packages = [];

  @override
  void initState() {
    super.initState();
    _fetchOfferings();
  }

  Future<void> _fetchOfferings() async {
    final packages = await SubscriptionService().getOfferings();
    if (mounted) {
      setState(() {
        _packages = packages;
        _isLoading = false;
      });
    }
  }

  Future<void> _makePurchase(Package package) async {
    setState(() => _isLoading = true);
    
    final isPremium = await SubscriptionService().purchasePackage(package);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (isPremium) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Gracias por actualizar a Premium!')),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La compra fue cancelada o falló.')),
        );
      }
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isLoading = true);
    
    final isPremium = await SubscriptionService().restorePurchases();
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (isPremium) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Compras restauradas con éxito!')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontraron compras previas.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade to Premium'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer,
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xxl),
              // Header Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.diamond_outlined,
                  size: 64,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              // Title
              Text(
                'Desbloquea Todo el Potencial',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Text(
                  'Exporta tus inmersiones en PDF y CSV para compartir, imprimir o respaldar. Obtén análisis avanzados y más.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              
              // Features List
              Padding(
                padding: AppSpacing.horizontalXl,
                child: Column(
                  children: [
                    _buildFeatureRow(context, 'Exportación de Inmersiones a PDF Profesional'),
                    const SizedBox(height: AppSpacing.sm),
                    _buildFeatureRow(context, 'Exportación masiva de datos a formato CSV'),
                    const SizedBox(height: AppSpacing.sm),
                    _buildFeatureRow(context, 'Acceso anticipado a nuevas funcionalidades'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              // Pricing Cards or Loading
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_packages.isEmpty)
                const Center(
                  child: Text('No hay planes disponibles en este momento.'),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: AppSpacing.horizontalMd,
                  itemCount: _packages.length,
                  itemBuilder: (context, index) {
                    final package = _packages[index];
                    return _buildPackageCard(context, package);
                  },
                ),
                
              // Restore Purchases Button
              TextButton(
                onPressed: _isLoading ? null : _restorePurchases,
                child: const Text('Restaurar compras previas'),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, String text) {
    return Row(
      children: [
        Icon(
          Icons.check_circle,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildPackageCard(BuildContext context, Package package) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Determine a nice title based on package type
    String title = package.storeProduct.title;
    if (package.packageType == PackageType.monthly) title = 'Plan Mensual';
    if (package.packageType == PackageType.twoMonth) title = '2 Meses';
    if (package.packageType == PackageType.threeMonth) title = 'Plan Trimestral';
    if (package.packageType == PackageType.sixMonth) title = '6 Meses';
    if (package.packageType == PackageType.annual) title = 'Plan Anual';
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: package.packageType == PackageType.annual
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _makePurchase(package),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (package.packageType == PackageType.annual)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        'Mejor Oferta',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              Text(
                package.storeProduct.priceString,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
