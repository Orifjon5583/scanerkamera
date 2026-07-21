import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan_ai/core/constants/app_constants.dart';
import 'package:smartscan_ai/features/settings/providers/settings_provider.dart';
import 'package:smartscan_ai/models/scan_settings_model.dart';
import 'package:smartscan_ai/services/backup_service.dart';

/// Application settings screen.
/// Allows users to configure theme, quality, OCR language, and manage backups.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Appearance section
          _SectionHeader(title: 'Appearance'),
          _ThemeTile(
            currentMode: settings.themeMode,
            onChanged: (mode) {
              ref.read(settingsProvider.notifier).setThemeMode(mode);
            },
          ),

          const Divider(),

          // Scanning section
          _SectionHeader(title: 'Scanning'),
          SwitchListTile(
            title: const Text('Auto Capture'),
            subtitle: const Text('Automatically capture when document is detected'),
            value: settings.autoCapture,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setAutoCapture(value);
            },
          ),
          SwitchListTile(
            title: const Text('Show Grid'),
            subtitle: const Text('Display grid overlay in camera'),
            value: settings.showGrid,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setShowGrid(value);
            },
          ),

          const Divider(),

          // Quality section
          _SectionHeader(title: 'Quality'),
          ListTile(
            title: const Text('Image Quality'),
            subtitle: Text(settings.imageQuality.label),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showImageQualityPicker(context, ref, settings),
          ),
          ListTile(
            title: const Text('PDF Quality'),
            subtitle: Text(settings.pdfQuality.label),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPdfQualityPicker(context, ref, settings),
          ),

          const Divider(),

          // OCR section
          _SectionHeader(title: 'OCR'),
          ListTile(
            title: const Text('OCR Language'),
            subtitle: Text(settings.ocrLanguage.label),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showOcrLanguagePicker(context, ref, settings),
          ),

          const Divider(),

          // Backup section
          _SectionHeader(title: 'Data'),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('Create Backup'),
            subtitle: const Text('Backup all documents and settings'),
            onTap: () => _createBackup(context),
          ),
          ListTile(
            leading: const Icon(Icons.restore_outlined),
            title: const Text('Restore Backup'),
            subtitle: const Text('Restore from a previous backup'),
            onTap: () => _restoreBackup(context),
          ),

          const Divider(),

          // About section
          _SectionHeader(title: 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('SmartScan AI'),
            subtitle: const Text('Version ${AppConstants.appVersion}'),
          ),
        ],
      ),
    );
  }

  void _showImageQualityPicker(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Image Quality',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...ImageQuality.values.map((quality) => RadioListTile<ImageQuality>(
                title: Text(quality.label),
                subtitle: Text('${quality.value}% JPEG quality'),
                value: quality,
                groupValue: settings.imageQuality,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(settingsProvider.notifier).setImageQuality(value);
                  }
                  Navigator.pop(context);
                },
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showPdfQualityPicker(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'PDF Quality',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...PdfQuality.values.map((quality) => RadioListTile<PdfQuality>(
                title: Text(quality.label),
                value: quality,
                groupValue: settings.pdfQuality,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(settingsProvider.notifier).setPdfQuality(value);
                  }
                  Navigator.pop(context);
                },
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showOcrLanguagePicker(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'OCR Language',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: OcrLanguage.values
                    .map((lang) => RadioListTile<OcrLanguage>(
                          title: Text(lang.label),
                          value: lang,
                          groupValue: settings.ocrLanguage,
                          onChanged: (value) {
                            if (value != null) {
                              ref
                                  .read(settingsProvider.notifier)
                                  .setOcrLanguage(value);
                            }
                            Navigator.pop(context);
                          },
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createBackup(BuildContext context) async {
    final backupService = BackupService();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Creating backup...'),
          ],
        ),
      ),
    );

    try {
      final path = await backupService.createBackup();
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup created successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e')),
        );
      }
    }
  }

  Future<void> _restoreBackup(BuildContext context) async {
    final backupService = BackupService();
    final backups = await backupService.getAvailableBackups();

    if (!context.mounted) return;

    if (backups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No backups found')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Select Backup to Restore',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...backups.map((backup) => ListTile(
                leading: const Icon(Icons.backup),
                title: Text('${backup.documentCount} documents'),
                subtitle: Text(backup.createdAt.toString()),
                onTap: () async {
                  Navigator.pop(context);
                  final success =
                      await backupService.restoreBackup(backup.path);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Backup restored successfully'
                              : 'Restore failed',
                        ),
                      ),
                    );
                  }
                },
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Section header widget for settings groups.
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Theme selection tile.
class _ThemeTile extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeTile({
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_getThemeIcon()),
      title: const Text('Theme'),
      subtitle: Text(_getThemeLabel()),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Choose Theme',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              RadioListTile<ThemeMode>(
                title: const Text('System Default'),
                value: ThemeMode.system,
                groupValue: currentMode,
                onChanged: (value) {
                  onChanged(value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Light'),
                value: ThemeMode.light,
                groupValue: currentMode,
                onChanged: (value) {
                  onChanged(value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark'),
                value: ThemeMode.dark,
                groupValue: currentMode,
                onChanged: (value) {
                  onChanged(value!);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  IconData _getThemeIcon() {
    switch (currentMode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }

  String _getThemeLabel() {
    switch (currentMode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }
}
