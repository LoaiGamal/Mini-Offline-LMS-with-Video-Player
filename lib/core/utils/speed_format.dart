String formatSpeed(double speed) {
  final String value = speed == speed.roundToDouble()
      ? speed.toInt().toString()
      : speed.toString();
  return '${value}x';
}
