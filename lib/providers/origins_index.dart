import 'package:coffee_review/repositories/origins.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final originIndexProvider = FutureProvider.autoDispose((ref) async {
  var list = await getOriginIndex();
  if (kDebugMode) {
    print("originIndexProvider $list");
  }
  return list;
});
