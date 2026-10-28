import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../models.dart';

class FrictionScreen extends StatelessWidget {
  const FrictionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    final done = s.frictionDone.length;
    final recent = s.gateEvents.reversed.take(12).toList();
    return AppPage(
      title: 'Friction',
      subtitle: 'Increase it on escapes, remove it from targets. Set up once, then the Pause Gate does the daily work.',
      children: [
        Section(
          title: 'One-time setup',
          icon: Icons.checklist_rounded,
          trailing: Text('$done/${frictionSteps.length}'),
          child: Column(
            children: [
              LinearProgressIndicator(value: done / frictionSteps.length, minHeight: 6),
              const SizedBox(height: 8),
              for (final f in frictionSteps)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: s.frictionDone.contains(f.id),
                  onChanged: (_) => s.toggleFriction(f.id),
                  title: Text(f.title),
                  subtitle: Text(f.detail),
                  secondary: f.url == null
                      ? null
                      : IconButton(
                          tooltip: 'Open tool',
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () => launchUrl(Uri.parse(f.url!), mode: LaunchMode.externalApplication),
                        ),
                ),
            ],
          ),
        ),
        Section(
          title: 'What this app can and cannot do',
          icon: Icons.info_outline_rounded,
          child: const Text(
            'A web app cannot uninstall your games, change DNS, or grayscale your phone. Those are the checklist above, '
            'and they are the real walls. What this app does enforce: the Pause Gate delay, the night-mode lockout '
            'after 10 PM, and a log of every time you walked through or walked away. Bookmark the Gate, '
            'not YouTube.',
          ),
        ),
        Section(
          title: 'Gate log',
          icon: Icons.history_rounded,
          trailing: Text(
            '${s.gateCount(wentThrough: false)} away · ${s.gateCount(wentThrough: true)} through (7d)',
          ),
          child: recent.isEmpty
              ? const Text('Nothing yet. Next time the urge hits, come here first.')
              : Column(
                  children: [
                    for (final g in recent)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          g.wentThrough ? Icons.arrow_forward : Icons.block,
                          color: g.wentThrough ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(
                          '${escapes.firstWhere((e) => e.id == g.escapeId, orElse: () => escapes.first).label}'
                          ' · ${g.wentThrough ? 'went through' : 'walked away'}',
                        ),
                        subtitle: Text(
                          '${_fmt(g.at)}${g.reason.isEmpty ? '' : '  ·  escaping: ${g.reason}'}',
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  String _fmt(DateTime d) =>
      '${d.day}/${d.month} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
