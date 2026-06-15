/// Tracks whether the expiry reminder dialog has already been shown during the
/// current app start.
class ExpiryReminderDialogService {
  static bool _shownForCurrentAppStart = false;

  Future<void> markPendingForLogin() async {
    _shownForCurrentAppStart = false;
  }

  Future<bool> hasShownForCurrentLogin() async {
    return _shownForCurrentAppStart;
  }

  Future<void> markShownForCurrentLogin() async {
    _shownForCurrentAppStart = true;
  }
}
