/// Compile-time switches for modules whose backend contract is incomplete.
final class FeatureFlags {
  const FeatureFlags({
    this.announcements = false,
    this.conduct = false,
    this.planners = false,
    this.schedules = false,
    this.siblingSwitch = false,
  });

  final bool announcements;
  final bool conduct;
  final bool planners;
  final bool schedules;
  final bool siblingSwitch;

  bool get anySchoolLife =>
      announcements || conduct || planners || schedules || siblingSwitch;
}
