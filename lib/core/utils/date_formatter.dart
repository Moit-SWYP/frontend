import 'package:intl/intl.dart';

/// 날짜 포맷팅 유틸리티
class DateFormatter {
  /// ISO 8601 DateTime을 한글 형식으로 변환
  /// 예: 2026-01-03T15:00:00 → "1월 3일 오후 3시"
  static String toKoreanDateTime(DateTime dateTime) {
    final month = dateTime.month;
    final day = dateTime.day;
    final hour = dateTime.hour;
    final minute = dateTime.minute;

    String period;
    int displayHour;

    if (hour < 12) {
      period = '오전';
      displayHour = hour == 0 ? 12 : hour;
    } else {
      period = '오후';
      displayHour = hour == 12 ? 12 : hour - 12;
    }

    if (minute == 0) {
      return '$month월 $day일 $period $displayHour시';
    } else {
      return '$month월 $day일 $period $displayHour시 $minute분';
    }
  }

  /// yyyy-MM-dd 형식을 한글로 변환
  /// 예: 2026-01-03 → "1월 3일"
  static String toKoreanDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '날짜 미정';
    }

    try {
      final date = DateTime.parse(dateString);
      return '${date.month}월 ${date.day}일';
    } catch (e) {
      print('❌ [DateFormatter] 날짜 파싱 실패: $dateString');
      return '날짜 미정';
    }
  }

  /// yyyy-MM-dd 형식을 "MM.dd" 형식으로 변환
  /// 예: 2026-01-03 → "01.03"
  static String toShortDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '--.-';
    }

    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MM.dd').format(date);
    } catch (e) {
      print('❌ [DateFormatter] 날짜 파싱 실패: $dateString');
      return '--.--';
    }
  }

  /// DateTime을 "yyyy년 M월 d일" 형식으로 변환
  static String toFullKoreanDate(DateTime dateTime) {
    return '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일';
  }

  /// 현재 시간과의 차이를 계산하여 표시
  /// 예: "3일 전", "2시간 전", "방금 전"
  static String toRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  /// 요일을 한글로 변환
  /// 예: 1 → "월요일"
  static String toKoreanWeekday(int weekday) {
    const weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return weekdays[weekday - 1];
  }

  /// D-day 계산
  /// 예: "D-3", "D-day", "D+2"
  static String toDday(DateTime targetDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final difference = target.difference(today).inDays;

    if (difference == 0) {
      return 'D-day';
    } else if (difference > 0) {
      return 'D-$difference';
    } else {
      return 'D+${-difference}';
    }
  }
}
