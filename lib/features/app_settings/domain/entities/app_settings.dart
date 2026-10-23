import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  const AppSettings({required this.showPrice, this.whatsappNumber});

  /// `show_price == 0` hides every price surface (App Store compliance).
  final bool showPrice;

  /// International-format number (e.g. `962790000000`) the Home FAB opens a
  /// WhatsApp chat with. `null` hides the FAB until the server has one.
  final String? whatsappNumber;

  @override
  List<Object?> get props => [showPrice, whatsappNumber];
}
