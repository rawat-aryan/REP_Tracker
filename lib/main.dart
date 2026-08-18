import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'data/repositories/session_repository.dart';
import 'data/seed/exercise_seed.dart';
import 'domain/models/plan.dart';
import 'domain/models/session.dart';
import 'features/session/session_screen.dart';
import 'providers.dart';

const _uuid = Uuid();

void main() {
  runApp(const ProviderScope(child: RepTrackerApp()));
}

class RepTrackerApp extends StatelessWidget {
  const RepTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'REP Tracker',
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: const _Bootstrap(),
    );
  }
}

/// Milestone 04 is the session screen standalone — there's no home screen
/// or onboarding yet (milestones 05/07). This just seeds the catalog,
/// ensures a demo "Legs" day exists, resumes today's session for it if one
/// is already open, or starts one, then drops straight into the ledger.
class _Bootstrap extends ConsumerStatefulWidget {
  const _Bootstrap();

  @override
  ConsumerState<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends ConsumerState<_Bootstrap> {
  String? _sessionId;

  static const _demoDayId = 'demo_legs';
  static const _demoExerciseIds = [
    'hip_thrust',
    'barbell_squat',
    'balancing_lunge',
    'lying_leg_curl',
  ];

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final db = ref.read(databaseProvider);
    final seedJson = await rootBundle.loadString('assets/seed/exercises.json');
    await seedIfNeeded(db, seedJson);

    final plans = ref.read(planRepositoryProvider);
    if (await plans.getWorkoutDay(_demoDayId) == null) {
      await plans.upsertWorkoutDay(
        const WorkoutDay(
          id: _demoDayId,
          name: 'Legs',
          exercises: [
            PlannedExercise(exerciseId: 'hip_thrust', order: 0),
            PlannedExercise(exerciseId: 'barbell_squat', order: 1),
            PlannedExercise(
              exerciseId: 'balancing_lunge',
              order: 2,
              defaultUnilateral: true,
            ),
            PlannedExercise(exerciseId: 'lying_leg_curl', order: 3),
          ],
        ),
      );
    }

    final sessions = ref.read(sessionRepositoryProvider);
    final today = DateTime.now();
    final existing = await sessions.getForDate(today);
    final open = existing.where((s) => s.workoutDayId == _demoDayId);
    final session = open.isNotEmpty ? open.first : await _startSession(sessions, today);

    if (!mounted) return;
    setState(() => _sessionId = session.id);
  }

  Future<Session> _startSession(SessionRepository sessions, DateTime today) async {
    final session = Session(
      id: _uuid.v4(),
      date: today,
      startedAt: today,
      workoutDayId: _demoDayId,
      intendedExerciseIds: _demoExerciseIds,
      currentExerciseId: _demoExerciseIds.first,
      exercises: [
        for (var i = 0; i < _demoExerciseIds.length; i++)
          SessionExercise(exerciseId: _demoExerciseIds[i], planOrder: i),
      ],
    );
    await sessions.createSession(session);
    return session;
  }

  @override
  Widget build(BuildContext context) {
    final id = _sessionId;
    if (id == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return SessionScreen(sessionId: id);
  }
}
