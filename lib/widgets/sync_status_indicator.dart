import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:divelogtest/providers/dive_provider.dart';

/// Displays sync status indicator with online/offline state and pending sync count
class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DiveProvider>(
      builder: (context, provider, child) {
        if (!provider.isInitialized) {
          return const SizedBox.shrink();
        }

        final isOnline = provider.isOnline;
        final isSyncing = provider.isSyncing;
        final pendingCount = provider.pendingSyncCount;
        final syncStatus = provider.syncStatus;

        // Determine icon and color
        IconData icon;
        Color iconColor;
        String tooltip;

        if (isSyncing) {
          icon = Icons.sync;
          iconColor = Colors.orange;
          tooltip = 'Sincronizando $pendingCount elemento(s)...';
        } else if (!isOnline) {
          icon = Icons.cloud_off;
          iconColor = Colors.grey;
          tooltip = 'Sin conexión - Modo offline';
        } else if (pendingCount > 0) {
          icon = Icons.cloud_upload;
          iconColor = Colors.orange;
          tooltip = '$pendingCount elemento(s) pendiente(s) de sincronizar';
        } else {
          icon = Icons.cloud_done;
          iconColor = Colors.green;
          tooltip = 'Todo sincronizado';
        }

        return Tooltip(
          message: tooltip,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSyncing)
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                    ),
                  )
                else
                  Icon(icon, size: 16, color: iconColor),
                if (pendingCount > 0 && !isSyncing) ...[
                  const SizedBox(width: 6),
                  Text(
                    '$pendingCount',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Expandable sync status banner with more details and manual sync button
class SyncStatusBanner extends StatelessWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DiveProvider>(
      builder: (context, provider, child) {
        if (!provider.isInitialized) {
          return const SizedBox.shrink();
        }

        final isOnline = provider.isOnline;
        final isSyncing = provider.isSyncing;
        final pendingCount = provider.pendingSyncCount;

        // Only show banner when offline or have pending items
        if (isOnline && pendingCount == 0 && !isSyncing) {
          return const SizedBox.shrink();
        }

        Color backgroundColor;
        IconData icon;
        String message;
        bool showSyncButton = false;

        if (isSyncing) {
          backgroundColor = Colors.blue;
          icon = Icons.sync;
          message = 'Sincronizando $pendingCount elemento(s)...';
        } else if (!isOnline && pendingCount > 0) {
          backgroundColor = Colors.orange;
          icon = Icons.cloud_off;
          message = 'Sin conexión - $pendingCount cambio(s) pendiente(s)';
        } else if (!isOnline) {
          backgroundColor = Colors.grey;
          icon = Icons.cloud_off;
          message = 'Modo offline - Los cambios se sincronizarán al reconectar';
        } else if (pendingCount > 0) {
          backgroundColor = Colors.orange;
          icon = Icons.cloud_upload;
          message = '$pendingCount elemento(s) pendiente(s) de sincronizar';
          showSyncButton = true;
        } else {
          return const SizedBox.shrink();
        }

        return Material(
          color: backgroundColor.withValues(alpha: 0.15),
          child: InkWell(
            onTap: showSyncButton && !isSyncing
                ? () => provider.manualSync()
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: backgroundColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: backgroundColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (showSyncButton && !isSyncing)
                    TextButton.icon(
                      onPressed: () => provider.manualSync(),
                      icon: Icon(Icons.sync, size: 16, color: backgroundColor),
                      label: Text(
                        'Sincronizar',
                        style: TextStyle(color: backgroundColor),
                      ),
                    ),
                  if (isSyncing)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(backgroundColor),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
