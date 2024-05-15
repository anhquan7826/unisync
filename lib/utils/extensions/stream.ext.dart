import 'dart:async';

import 'package:rxdart/rxdart.dart';

extension StreamExtension<T> on Stream<T> {
  /// Adding an ability to close the stream subscription inside [callback].
  /// To close the stream subscription, simply return true inside [callback].
  void listenCancellable(
    bool Function(T) callback, {
    void Function(Object error, StackTrace stackTrace)? onError,
    bool cancelOnError = true,
    void Function()? onDone,
  }) {
    late final StreamSubscription<T> subscription;
    subscription = listen(
      (event) {
        if (callback(event)) {
          subscription.cancel();
        }
      },
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

extension StreamSubscriptionExtension on StreamSubscription {
  void addTo(CompositeSubscription subscriptions) {
    subscriptions.add(this);
  }
}