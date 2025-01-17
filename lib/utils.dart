  String twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }

  String formatDateTime(DateTime dt) {
    final hours = dt.hour.toString().padLeft(2, '0');
    final minutes = dt.minute.toString().padLeft(2, '0');
    final seconds = dt.second.toString().padLeft(2, '0');
    return '$hours:$minutes:${seconds == "00" ? "00" : seconds}';
  } 