import 'dart:async';

/// A debounce function completely halts function calls
/// until the call rate of the function falls low enough
class DeBouncer {
  /// debouncer delay
  final Duration delay;

  /// debouncer timer
  Timer? _timer;

  /// default constructor
  DeBouncer({this.delay = const Duration(milliseconds: 300)});

  /// run the function
  run(void Function() action, {Duration? delay}) {
    _timer?.cancel();
    _timer = Timer(delay ?? this.delay, action);
  }
}
