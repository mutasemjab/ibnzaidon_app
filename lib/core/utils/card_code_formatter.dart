import 'package:flutter/services.dart';

/// Uppercases and groups scratch-card codes in blocks of four: `ABCD-1234-…`.
class CardCodeFormatter extends TextInputFormatter {
  const CardCodeFormatter({this.groupSize = 4, this.maxLength = 24});

  final int groupSize;
  final int maxLength;

  static String normalize(String input) =>
      input.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var raw = normalize(newValue.text);
    if (raw.length > maxLength) raw = raw.substring(0, maxLength);
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      if (i > 0 && i % groupSize == 0) buffer.write('-');
      buffer.write(raw[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
