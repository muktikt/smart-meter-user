class DateFormatUtil {
  DateFormatUtil._();

  static const List<String> _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];

  static const List<String> _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];

  /// Mengubah format tanggal ISO/String ke format Indonesia lengkap
  /// Contoh: "2026-06-03 23:28:03" -> "3 Juni 2026"
  static String indonesian(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString).toLocal();
      final day = date.day;
      final month = _months[date.month - 1];
      final year = date.year;
      return '$day $month $year';
    } catch (e) {
      return dateString;
    }
  }

  /// Mengubah format tanggal ke format Indonesia dengan Waktu
  /// Contoh: "2026-06-03 23:28:03" -> "3 Juni 2026, 23:28"
  static String indonesianWithTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString).toLocal();
      final day = date.day;
      final month = _months[date.month - 1];
      final year = date.year;
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$day $month $year, $hour:$minute';
    } catch (e) {
      return dateString;
    }
  }

  /// Mengubah format tanggal ke format Hari, Tanggal Indonesia
  /// Contoh: "2026-06-03 23:28:03" -> "Rabu, 3 Juni 2026"
  static String dayAndDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString).toLocal();
      final dayName = _days[date.weekday - 1];
      final day = date.day;
      final month = _months[date.month - 1];
      final year = date.year;
      return '$dayName, $day $month $year';
    } catch (e) {
      return dateString;
    }
  }

  /// Mengubah format tanggal menjadi DD/MM/YYYY
  /// Contoh: "2026-06-03 23:28:03" -> "03/06/2026"
  static String simple(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString).toLocal();
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year;
      return '$day/$month/$year';
    } catch (e) {
      return dateString;
    }
  }

  /// Mengambil waktu saja dari tanggal
  /// Contoh: "2026-06-03 23:28:03" -> "23:28"
  static String timeOnly(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString).toLocal();
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (e) {
      return dateString;
    }
  }
}
