import 'package:flutter/material.dart';
import 'package:divelogtest/theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidad'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Política de Privacidad de Dive Log App',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Última actualización: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            _Section(
              title: '1. Información que recopilamos',
              content:
                  'Recopilamos información personal que nos proporcionas directamente cuando te registras, actualizas tu perfil o registras inmersiones de buceo. Esto puede incluir tu nombre, correo electrónico, nivel de certificación, contacto de emergencia y detalles de tus actividades de buceo.',
            ),
            _Section(
              title: '2. Uso de la información',
              content:
                  'Usamos tu información para proporcionar y mejorar la aplicación, mantener tu bitácora de buceo sincronizada y segura (usando Firebase de Google), generar estadísticas personales y permitir la exportación de tus registros (por ejemplo, en formato PDF o CSV).',
            ),
            _Section(
              title: '3. Almacenamiento y Seguridad',
              content:
                  'Tu información se almacena localmente en tu dispositivo y se sincroniza con los servidores seguros de Firebase en la nube. Tomamos medidas razonables para proteger tus datos contra acceso no autorizado, alteración o destrucción.',
            ),
            _Section(
              title: '4. Compartir información',
              content:
                  'No vendemos, alquilamos ni compartimos de otra manera tu información personal con terceros, excepto cuando sea necesario para proporcionar nuestro servicio (como proveedores de infraestructura en la nube) o cuando lo requiera la ley.',
            ),
            _Section(
              title: '5. Tus Derechos',
              content:
                  'Tienes derecho a acceder, editar y eliminar tus datos personales en cualquier momento a través de las opciones de configuración de la aplicación. También puedes eliminar tu cuenta y toda la información asociada contactando a nuestro soporte.',
            ),
            _Section(
              title: '6. Cambios a esta política',
              content:
                  'Podemos actualizar esta política ocasionalmente. Cualquier cambio se publicará dentro de la aplicación y la fecha de la última actualización se modificará correspondientemente.',
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                '© ${DateTime.now().year} Dive Log App',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;

  const _Section({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.5,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
