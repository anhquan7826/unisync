extension ListExtension<T> on List<T> {
  List<T> plus(T element) {
    return [...this, element];
  }

  List<T> plusAll(Iterable<T> iterable) {
    return [...this, ...iterable];
  }

  List<T> minus(T element) {
    return where((e) => e != element).toList();
  }

  List<T> minusAll(Iterable<T> iterable) {
    return where((e) => !iterable.contains(e)).toList();
  }

  bool differ(List<T> other) {
    if (length != other.length) {
      return true;
    }
    for (int i = 0; i < length; i++) {
      if ([i] != other[i]) {
        return true;
      }
    }
    return false;
  }
}
