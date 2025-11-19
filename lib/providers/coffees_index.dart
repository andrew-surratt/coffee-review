import 'package:coffee_review/repositories/coffees.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final AutoDisposeFutureProvider<List<CoffeeIndex>> coffeesIndexProvider =
    FutureProvider.autoDispose((ref) async {
  List<CoffeeIndex> list = await getCoffeeIndex();
  if (kDebugMode) {
    print("coffeeIndexProvider $list");
  }
  return list;
});
