import 'package:flutter/material.dart';

import '../main.dart';
import '../models.dart';

class HustleScreen extends StatefulWidget {
  const HustleScreen({super.key});
  @override
  State<HustleScreen> createState() => _HustleScreenState();
}

class _HustleScreenState extends State<HustleScreen> {
  late int _week = AppState.instance.currentHustleWeek;

  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    final w = hustleWeeks[_week];
    final total = s.hustleDone.length;
    return AppPage(
      title: 'Build',
      subtitle: '15 minutes a day. Timer on. Stop when it rings, even on a roll. $total/42 micro-actions done.',
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < hustleWeeks.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 16),
                  child: ChoiceChip(
                    label: Text('W${i + 1}'),
                    selected: _week == i,
                    onSelected: (_) => setState(() => _week = i),
                    avatar: _weekDone(s, i) ? const Icon(Icons.check, size: 16) : null,
                  ),
                ),
            ],
          ),
        ),
        Section(
          title: w.title,
          icon: Icons.flag_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(w.goal, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              for (var d = 0; d < 7; d++) _DayTile(week: _week, day: d),
            ],
          ),
        ),
        Section(
          title: 'Directions worth putting in Week 1',
          icon: Icons.explore_outlined,
          child: const Text(
            'Security awareness content for small businesses. AppSec consulting for small dev teams. '
            'Technical writing for security vendors. Small automation tools for people in your field. '
            'Do not pick now. Let the inventory decide.',
          ),
        ),
      ],
    );
  }

  bool _weekDone(AppState s, int w) {
    for (var d = 0; d < 7; d++) {
      if (!s.hustleDone.contains(s.hustleKey(w, d))) return false;
    }
    return true;
  }
}

class _DayTile extends StatefulWidget {
  const _DayTile({required this.week, required this.day});
  final int week;
  final int day;
  @override
  State<_DayTile> createState() => _DayTileState();
}

class _DayTileState extends State<_DayTile> {
  bool _open = false;
  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    final k = s.hustleKey(widget.week, widget.day);
    final done = s.hustleDone.contains(k);
    final note = s.hustleNotes[k] ?? '';
    return Column(
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: done,
          onChanged: (_) => s.toggleHustle(widget.week, widget.day),
          title: Text(
            'Day ${widget.day + 1}: ${hustleWeeks[widget.week].days[widget.day]}',
            style: TextStyle(decoration: done ? TextDecoration.lineThrough : null),
          ),
          subtitle: note.isNotEmpty && !_open ? Text(note, maxLines: 2, overflow: TextOverflow.ellipsis) : null,
          secondary: IconButton(
            icon: Icon(_open ? Icons.expand_less : Icons.edit_note),
            tooltip: 'Notes',
            onPressed: () => setState(() => _open = !_open),
          ),
        ),
        if (_open)
          Padding(
            padding: const EdgeInsets.only(left: 48, bottom: 12, right: 8),
            child: TextFormField(
              initialValue: note,
              maxLines: 4,
              minLines: 2,
              decoration: const InputDecoration(hintText: 'Your 3 lines, the listing you found, the link...'),
              onChanged: (v) => s.setHustleNote(widget.week, widget.day, v),
            ),
          ),
      ],
    );
  }
}
