extension SetExtension<T> on Set<T> {
  Set<T> plus(T element) {
    return {...this, element};
  }

  Set<T> plusAll(Iterable<T> iterable) {
    return {...this, ...iterable};
  }

  Set<T> minus(T element) {
    return where((e) => e != element).toSet();
  }

  Set<T> minusAll(Iterable<T> iterable) {
    return where((e) => !iterable.contains(e)).toSet();
  }
}
