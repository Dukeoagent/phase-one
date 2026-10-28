import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../models.dart';
import '../notifications.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    final r = Reminders.instance;
    final perm = r.permission;
    return AppPage(
      title: 'Settings',
      children: [
        Section(
          title: 'Reminders',
          icon: Icons.notifications_outlined,
          trailing: Text(perm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Browser notifications'),
                subtitle: const Text(
                  'Fire while this app is open or installed and running. Install it as an app on your phone and laptop '
                  'and leave it in the background.',
                ),
                value: s.remindersOn && perm == 'granted',
                onChanged: perm == 'unsupported'
                    ? null
                    : (v) async {
                        if (v) {
                          final res = await r.requestPermission();
                          s.setReminders(on: res == 'granted');
                          if (res == 'granted') r.show('Phase One', 'Reminders on. Floor first.');
                        } else {
                          s.setReminders(on: false);
                        }
                        setState(() {});
                      },
              ),
              _TimeRow(
                label: 'Morning floor',
                h: s.morningHour,
                m: s.morningMinute,
                onPick: (t) => s.setReminders(mh: t.hour, mm: t.minute),
              ),
              _TimeRow(
                label: 'Build 15 minutes',
                h: s.buildHour,
                m: s.buildMinute,
                onPick: (t) => s.setReminders(bh: t.hour, bm: t.minute),
              ),
              _TimeRow(
                label: 'Tomorrow\'s line',
                h: s.eveningHour,
                m: s.eveningMinute,
                onPick: (t) => s.setReminders(eh: t.hour, em: t.minute),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: perm == 'granted' ? () => r.show('Test', 'If you can read this, reminders work here.') : null,
                icon: const Icon(Icons.notifications_active_outlined),
                label: const Text('Send test notification'),
              ),
            ],
          ),
        ),
        Section(
          title: 'Install on phone and laptop',
          icon: Icons.install_mobile_rounded,
          child: const Text(
            'Android Chrome: menu, then "Add to Home screen" or "Install app". '
            'iPhone Safari: Share, then "Add to Home Screen". '
            'Desktop Chrome or Edge: the install icon in the address bar. '
            'Installed, it opens full screen with no address bar, which is one less door to YouTube.',
          ),
        ),
        Section(
          title: 'Sync between devices',
          icon: Icons.sync_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Data lives in each browser\'s local storage. To move it, copy the export here and paste it '
                'into the other device. Do this on Sunday with the review.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.upload),
                    label: const Text('Copy export'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: s.exportJson()));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export copied to clipboard.')));
                    },
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Paste import'),
                    onPressed: () => _import(context),
                  ),
                ],
              ),
            ],
          ),
        ),
        Section(
          title: 'Night mode',
          icon: Icons.nightlight_outlined,
          child: const Text(
            'From 10 PM to 5 AM the Today screen shows only the one-line box. This is not configurable on purpose.',
          ),
        ),
      ],
    );
  }

  Future<void> _import(BuildContext context) async {
    final c = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Paste export'),
        content: TextField(controller: c, maxLines: 6, decoration: const InputDecoration(hintText: '{ ... }')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Replace my data')),
        ],
      ),
    );
    if (ok != true) return;
    final res = await AppState.instance.importJson(c.text);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res ? 'Imported.' : 'That was not a valid export.')),
      );
    }
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({required this.label, required this.h, required this.m, required this.onPick});
  final String label;
  final int h, m;
  final ValueChanged<TimeOfDay> onPick;
  @override
  Widget build(BuildContext context) {
    final t = TimeOfDay(hour: h, minute: m);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: TextButton(
        child: Text(t.format(context)),
        onPressed: () async {
          final picked = await showTimePicker(context: context, initialTime: t);
          if (picked != null) onPick(picked);
        },
      ),
    );
  }
}
