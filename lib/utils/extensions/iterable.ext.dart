extension IterableExt<T> on Iterable<T> {
  bool containsAll(List<T> list) {
    for (final e in list) {
      if (!contains(e)) {
        return false;
      }
    }
    return true;
  }

  T? firstWhereOrNull(bool Function(T) predicate) {
    try {
      return firstWhere(predicate);
    } catch (_) {
      return null;
    }
  }
}
