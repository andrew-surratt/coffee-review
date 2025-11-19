import 'package:coffee_review/repositories/roasters.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final AutoDisposeFutureProvider<List<String>> roastersIndexProvider =
    FutureProvider.autoDispose((ref) async {
  List<String> list = await getRoastersIndex();
  if (kDebugMode) {
    print("roastersIndexProvider $list");
  }
  return list;
});
