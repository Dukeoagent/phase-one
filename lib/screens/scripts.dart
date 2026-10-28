import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';

class _Script {
  const _Script(this.name, this.when, this.text, this.example);
  final String name;
  final String when;
  final String text;
  final String example;
}

const _scripts = [
  _Script(
    '1. The Pause Request',
    'Use when you feel the urge to apologize just to end the discomfort. Always first.',
    'I can tell this matters and I don\'t want to say something just to make it stop. Give me 20 minutes and I\'ll come back to this properly.',
    'Then set a timer and actually come back.',
  ),
  _Script(
    '2. The Split Statement',
    'Use when you are being handed the whole blame.',
    'I hear that [specific thing] hurt you, and I\'m sorry for my part in that. I also need to say [your need or perspective]. Both of these are true and I want us to look at both.',
    'I hear that not replying for three hours hurt you, and I\'m sorry I didn\'t send a quick message. I also need you to know I was in back-to-back meetings and can\'t always text during work. Both are true.',
  ),
  _Script(
    '3. The Need Statement',
    'Use when you have a need you have been swallowing.',
    'Something I\'ve been holding back: when [situation], I feel [emotion]. What would help me is [concrete, small ask]. Can we try that?',
    'When plans change last minute without a heads-up, I feel like an afterthought. What would help me is a quick message when you know. Can we try that?',
  ),
];

class ScriptsScreen extends StatelessWidget {
  const ScriptsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AppPage(
      title: 'Scripts',
      subtitle: 'Separate acknowledging the impact from accepting all the blame.',
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: cs.tertiaryContainer, borderRadius: BorderRadius.circular(14)),
          child: const Text(
            'Two rules. Never send any of these while your heart rate is up: Script 1 first, every time. '
            'And for 30 days, "I\'m sorry for my part" is the only apology phrasing you use. Never "it\'s my fault".',
          ),
        ),
        for (final sc in _scripts)
          Section(
            title: sc.name,
            icon: Icons.format_quote_rounded,
            trailing: IconButton(
              tooltip: 'Copy',
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: sc.text));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied. Fill the brackets before sending.')));
              },
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sc.when, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 10),
                SelectableText(sc.text, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 10),
                Text('Example: ${sc.example}', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        Section(
          title: 'Heart rate check',
          icon: Icons.favorite_outline_rounded,
          child: const Text(
            'Before any hard message: 4 seconds in, 6 seconds out, five times. One minute. '
            'If you still want to send it after that, send it.',
          ),
        ),
      ],
    );
  }
}
