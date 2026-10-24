import 'dart:math';

import 'package:clock/clock.dart';

typedef IdGenerator = String Function();

IdGenerator createIdGenerator(Clock appClock, Random random) {
  return () {
    final timestamp = appClock.now().microsecondsSinceEpoch.toRadixString(36);
    final noise = random.nextInt(0x7fffffff).toRadixString(36);
    return '$timestamp$noise';
  };
}
