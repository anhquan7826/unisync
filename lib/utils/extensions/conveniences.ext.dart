extension ConveniencesExt<T extends Object?> on T {
  T let(void Function(T) callback) {
    callback.call(this);
    return this;
  }

  U to<U extends Object?>(U Function(T) callback) {
    return callback.call(this);
  }
}
