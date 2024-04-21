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

  List<R> mapIndexed<R>(R Function(int index, T element) callback) {
    return asMap().entries.map((e) => callback(e.key, e.value)).toList();
  }

  List<T> copyReplaced(T? Function(T) predicate) {
    final result = <T>[];
    for (final e in this) {
      result.add(predicate(e) ?? e);
    }
    return result;
  }

  List<T> copyReplacedIndex(T? Function(int index) predicate) {
    final result = <T>[];
    for (int i = 0; i < length; i++) {
      result.add(predicate(i) ?? this[i]);
    }
    return result;
  }

  Map<T, R> associate<R>(R Function(T) value) {
    return {for (final e in this) e: value(e)};
  }
}
