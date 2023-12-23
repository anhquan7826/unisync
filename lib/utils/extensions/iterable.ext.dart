extension IterableExt on Iterable {
  bool containsAll<T>(List<T> list) {
    for (final e in list) {
      if (!contains(e)) {
        return false;
      }
    }
    return true;
  }
}
