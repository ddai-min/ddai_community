class DataUtils {
  static String setAnonymousName({
    required String uid,
  }) {
    return '익명${uid.substring(0, 6)}';
  }
}
