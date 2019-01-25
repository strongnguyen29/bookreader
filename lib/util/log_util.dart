class Log {

  static void d(String TAG, String msg) {
    print("--/DEBUG/ $TAG :: $msg");
  }

  static void e(String TAG, String msg) {
    print("--/ERROR/ $TAG :: $msg");
  }
}