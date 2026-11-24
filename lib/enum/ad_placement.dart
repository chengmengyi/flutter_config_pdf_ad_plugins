// ignore_for_file: constant_identifier_names

enum AdPlacement {
  pr_new_launch,
  pr_launch,
  pr_ban1,
  pr_user_use,
  pr_exit,
  pr_ban2,
  pr_ban3,
  pr_new_int;

  static AdPlacement parse(String value) {
    return AdPlacement.values.firstWhere(
      (placement) => placement.name == value,
      orElse: () => throw FormatException('Unknown ad scene_id: $value'),
    );
  }
}
