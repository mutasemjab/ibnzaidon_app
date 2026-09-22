import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  const AppSettings({required this.showPrice});

  /// `show_price == 0` hides every price surface (App Store compliance).
  final bool showPrice;

  @override
  List<Object?> get props => [showPrice];
}
