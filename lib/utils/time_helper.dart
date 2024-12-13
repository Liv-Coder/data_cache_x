class TimeHelper {
  static bool isExpired(DateTime? expiry) {
    if (expiry == null) {
      return false;
    }
    return DateTime.now().isAfter(expiry);
  }
}
