extension IterableExt<T> on Iterable<T> {
  bool containsAll(List<T> list) {
    for (final e in list) {
      if (!contains(e)) {
        return false;
      }
    }
    return true;
  }
}
