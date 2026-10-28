import 'package:flutter/material.dart';

import 'design_tokens.dart';
import 'models.dart';
import 'notifications.dart';
import 'screens/dashboard.dart';
import 'screens/friction.dart';
import 'screens/hustle.dart';
import 'screens/review.dart';
import 'screens/scripts.dart';
import 'screens/settings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppState.instance.load().then((_) => Reminders.instance.start());
  runApp(const PhaseOneApp());
}

class PhaseOneApp extends StatelessWidget {
  const PhaseOneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phase One',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const Shell(),
    );
  }
}

class _Dest {
  const _Dest(this.label, this.icon, this.selectedIcon, this.builder);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final WidgetBuilder builder;
}

final _dests = <_Dest>[
  _Dest('Today', Icons.wb_sunny_outlined, Icons.wb_sunny, (_) => const DashboardScreen()),
  _Dest('Friction', Icons.shield_outlined, Icons.shield, (_) => const FrictionScreen()),
  _Dest('Scripts', Icons.chat_bubble_outline, Icons.chat_bubble, (_) => const ScriptsScreen()),
  _Dest('Build', Icons.rocket_launch_outlined, Icons.rocket_launch, (_) => const HustleScreen()),
  _Dest('Review', Icons.insights_outlined, Icons.insights, (_) => const ReviewScreen()),
  _Dest('Settings', Icons.tune_outlined, Icons.tune, (_) => const SettingsScreen()),
];

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        if (!AppState.instance.loaded) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final wide = MediaQuery.sizeOf(context).width >= 760;
        final body = AnimatedSwitcher(
          duration: Prim.durBase,
          switchInCurve: Prim.easeOut,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, 0.02), end: Offset.zero).animate(anim),
              child: child,
            ),
          ),
          child: KeyedSubtree(key: ValueKey(_index), child: _dests[_index].builder(context)),
        );
        if (wide) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  labelType: NavigationRailLabelType.all,
                  minWidth: 84,
                  leading: const Padding(
                    padding: EdgeInsets.only(top: Prim.space5, bottom: Prim.space6),
                    child: _Logo(),
                  ),
                  destinations: [
                    for (final d in _dests)
                      NavigationRailDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selectedIcon),
                        label: Text(d.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
          );
        }
        return Scaffold(
          body: body,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(border: Border(top: BorderSide(color: context.pc.border))),
            child: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                for (final d in _dests)
                  NavigationDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selectedIcon), label: d.label),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();
  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: c.heroGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(Prim.radiusMd),
      ),
      alignment: Alignment.center,
      child: Text('P1', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
    );
  }
}

/// Page scaffold: readable width on laptop, 16px gutters on phone.
class AppPage extends StatelessWidget {
  const AppPage({super.key, required this.title, required this.children, this.subtitle, this.hero});
  final String title;
  final String? subtitle;
  final Widget? hero;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Prim.space4, Prim.space6, Prim.space4, Prim.space12),
            children: [
              Text(title, style: t.headlineMedium),
              if (subtitle case final sub?) ...[
                const SizedBox(height: Prim.space2),
                Text(sub, style: t.bodyMedium?.copyWith(color: context.pc.muted)),
              ],
              const SizedBox(height: Prim.space5),
              if (hero case final h?) ...[h, const SizedBox(height: CardTokens.gap)],
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// A titled card. [icon] gives it an identity at a glance.
class Section extends StatelessWidget {
  const Section({super.key, required this.title, required this.child, this.trailing, this.icon, this.tint});
  final String title;
  final Widget child;
  final Widget? trailing;
  final IconData? icon;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    return Padding(
      padding: const EdgeInsets.only(bottom: CardTokens.gap),
      child: Card(
        child: Padding(
          padding: CardTokens.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon case final i?) ...[
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: (tint ?? c.primary).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(Prim.radiusSm + 2),
                      ),
                      child: Icon(i, size: 18, color: tint ?? c.primary),
                    ),
                    const SizedBox(width: Prim.space3),
                  ],
                  Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
                  if (trailing case final tr?)
                    DefaultTextStyle.merge(style: Theme.of(context).textTheme.labelMedium, child: tr),
                ],
              ),
              const SizedBox(height: Prim.space4),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Small rounded label, e.g. "3/7" or "2 away".
class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.color, this.icon});
  final String text;
  final Color? color;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    final col = color ?? context.pc.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Prim.space3, vertical: Prim.space1 + 1),
      decoration: BoxDecoration(
        color: col.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(Prim.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon case final i?) ...[Icon(i, size: 14, color: col), const SizedBox(width: Prim.space1)],
          Text(text, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: col)),
        ],
      ),
    );
  }
}

/// Full-width callout above the cards.
class Callout extends StatelessWidget {
  const Callout({super.key, required this.text, required this.icon, required this.color, this.foreground});
  final String text;
  final IconData icon;
  final Color color;
  final Color? foreground;
  @override
  Widget build(BuildContext context) {
    final fg = foreground ?? context.pc.foreground;
    return Padding(
      padding: const EdgeInsets.only(bottom: CardTokens.gap),
      child: Container(
        padding: const EdgeInsets.all(Prim.space4),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(Prim.radiusMd)),
        child: Row(
          children: [
            Icon(icon, color: fg),
            const SizedBox(width: Prim.space3),
            Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: fg))),
          ],
        ),
      ),
    );
  }
}
