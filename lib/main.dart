import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/seed/exercise_seed.dart';
import 'features/home/home_providers.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/identity_screen.dart';
import 'features/session/session_controller.dart';
import 'features/session/session_screen.dart';
import 'providers.dart';
import 'theme.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const ProviderScope(child: RepTrackerApp()));
}

class RepTrackerApp extends StatelessWidget {
  const RepTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'REP Tracker',
      theme: buildAppTheme(),
      home: const _Bootstrap(),
    );
  }
}

/// Seeds the exercise catalog, then routes to onboarding (no [WeekPlan] has
/// ever been written yet) or straight to [HomeScreen] — milestone 07's gate.
/// Everything downstream (session start/resume) is driven from there.
class _Bootstrap extends ConsumerStatefulWidget {
  const _Bootstrap();

  @override
  ConsumerState<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends ConsumerState<_Bootstrap> with WidgetsBindingObserver {
  bool _ready = false;
  bool _needsOnboarding = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _prepare();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// §7: drain on resume *and* cold start, before first render of whatever
  /// screen the user lands on — a set logged from a locked phone must show
  /// up the instant the app is back, not on some later refresh.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _drainAndMaybeLand();
  }

  Future<void> _drainAndMaybeLand() async {
    try {
      final landing = await ref.read(triggerDrainServiceProvider).drainAndApply();
      if (landing == null) return;
      ref.invalidate(homeStateProvider);
      // A SessionScreen for this session may already be open (e.g. the user
      // background-locked the phone mid-session) — its SessionController
      // is a live Riverpod instance that drainAndApply's direct-repository
      // writes never touch, so it needs an explicit nudge to reload.
      ref.invalidate(sessionControllerProvider(landing.sessionId));
      final nav = _navigatorKey.currentState;
      if (nav != null) {
        unawaited(
          nav.push(
            MaterialPageRoute(
              builder: (_) => SessionScreen(
                sessionId: landing.sessionId,
                autoOpenExerciseId: landing.exerciseId,
              ),
            ),
          ),
        );
      }
    } catch (_) {
      // No native trigger channel available (desktop/test run) — nothing
      // to drain, and the ambient surface is best-effort anyway.
    }
  }

  Future<void> _prepare() async {
    final db = ref.read(databaseProvider);
    final seedJson = await rootBundle.loadString('assets/seed/exercises.json');
    await seedIfNeeded(db, seedJson);

    final plans = ref.read(planRepositoryProvider);
    final hasPlan = await plans.getLatestWeekPlan(demoRoutineId) != null;

    if (!mounted) return;
    setState(() {
      _needsOnboarding = !hasPlan;
      _ready = true;
    });
    if (hasPlan) await _drainAndMaybeLand();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _needsOnboarding ? const IdentityScreen() : const HomeScreen();
  }
}
