import 'load.dart';

enum Muscle {
  chest,
  back,
  lats,
  traps,
  frontDelt,
  sideDelt,
  rearDelt,
  biceps,
  triceps,
  forearms,
  quads,
  hamstrings,
  glutes,
  calves,
  abs,
  adductors,
}

enum Equipment { barbell, dumbbell, machine, cable, bodyweight, band, other }

/// The keystone of the whole data model.
///
/// Splits churn, day names change, routines get rewritten — exercises don't.
/// Every logged set points at an Exercise.id, and EVERY chart reads only that.
/// This is what makes history continuous across any change of split. (I1)
class Exercise {
  /// Human-readable slug for seeded exercises ("hip_thrust"); UUID for custom.
  ///
  /// Two ID spaces on purpose: seeds ship identically in every install, so they
  /// are safe to reference in seed data, migrations and future sync. Generating
  /// UUIDs for seeds makes seed updates guesswork.
  final String id;
  final bool isCustom;

  /// Freely renamable. The ID is the identity, never the name.
  final String name;

  /// Alternate names matched by the picker, so users don't fork a curve by
  /// typing "Incline BP" when "Incline bench press" already exists.
  final List<String> aliases;

  final Muscle primaryMuscle;
  final List<Muscle> secondaryMuscles;
  final Equipment equipment;

  /// Prefill FALLBACK only. Real execution is resolved per set index from
  /// history — see domain/rules/prefill.dart.
  final Execution defaultExecution;

  /// Points at another Exercise.id for variants (incline vs flat bench).
  /// Powers the compare overlay. NEVER a data link — curves stay separate.
  final String? variantOf;

  /// User override for the weight stepper, in kg. Null means "learn it".
  final double? incrementOverride;

  /// Fallback increment for this equipment type, in kg.
  final double equipmentIncrement;

  /// Archived exercises vanish from the picker but stay in history. (I7)
  final bool archived;

  const Exercise({
    required this.id,
    required this.name,
    required this.primaryMuscle,
    required this.equipment,
    this.isCustom = false,
    this.aliases = const [],
    this.secondaryMuscles = const [],
    this.defaultExecution = Execution.bilateral,
    this.variantOf,
    this.incrementOverride,
    this.equipmentIncrement = 2.5,
    this.archived = false,
  });

  /// Fallback [LoadSource] for a brand-new set with no history to prefill
  /// from — the equipment tells you what kind of load it is.
  LoadSource get defaultLoadSource => switch (equipment) {
        Equipment.barbell => LoadSource.barbell,
        Equipment.dumbbell => LoadSource.dumbbell,
        Equipment.machine => LoadSource.machineStack,
        Equipment.cable => LoadSource.cable,
        Equipment.bodyweight => LoadSource.bodyweight,
        Equipment.band => LoadSource.band,
        Equipment.other => LoadSource.barbell,
      };
}
