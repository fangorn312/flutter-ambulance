import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime date, {String format = 'dd.MM.yyyy'}) {
    return DateFormat(format).format(date);
  }

  static String formatTime(DateTime time, {String format = 'HH:mm'}) {
    return DateFormat(format).format(time);
  }

  static String formatDateTime(DateTime dateTime,
      {String format = 'dd.MM.yyyy HH:mm'}) {
    return DateFormat(format).format(dateTime);
  }

  static DateTime? parseDate(String date, {String format = 'dd.MM.yyyy'}) {
    try {
      return DateFormat(format).parse(date);
    } catch (e) {
      return null;
    }
  }

  static DateTime? parseDateTime(String dateTime,
      {String format = 'dd.MM.yyyy HH:mm'}) {
    try {
      return DateFormat(format).parse(dateTime);
    } catch (e) {
      return null;
    }
  }

  static String timeAgo(DateTime date) {
    final Duration difference = DateTime.now().difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} год(а) назад';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} месяц(ев) назад';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} день(дней) назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} час(ов) назад';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} минут(ы) назад';
    } else {
      return 'Только что';
    }
  }
}
