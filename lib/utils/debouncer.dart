import 'dart:async';

class Debouncer {
  Debouncer(this.duration);

  final Duration duration;
  Timer? _timer;

  void call(Function action) {
    _timer?.cancel();
    _timer = Timer(duration, () => action());
  }
}
