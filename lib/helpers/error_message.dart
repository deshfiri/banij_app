/// Readable error text for toasts: the error's `toString()` without Dart's
/// `Exception: ` prefix. Same output as `e.toString().replaceAll('Exception: ', '')`.
extension ApiErrorMessage on Object {
  String get apiErrorMessage => toString().replaceAll('Exception: ', '');
}
