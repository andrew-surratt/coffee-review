import 'package:coffee_review/repositories/coffees.dart';
import 'package:coffee_review/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/ratings.dart';
import 'config.dart';

class CompareCoffeesNotifier extends ChangeNotifier {
  List<CoffeeWithRating> state = [];

  CompareCoffeesNotifier() {
    setCoffees(defaultConfig.defaultChartCoffeeNames, getUser());
  }

  void setCoffees(List<String> coffeeNames, User? user) async {
    if (kDebugMode) {
      print("[CompareCoffeesNotifier.setCoffees] user: $user, coffeeNames: $coffeeNames");
    }
    var coffees = await getCoffees(coffeeNames);
    if (user == null) {
      state = coffees.map((c) => CoffeeWithRating(coffee: c, rating: null)).toList();
    } else {
      state = await getUserRatingsForCoffees(user, coffees);
    }
    notifyListeners();
  }

  void addCoffee(Coffee coffee, User? user) async {
    if (kDebugMode) {
      print({"[CompareCoffeesNotifier.addCoffee] user:", user, "coffee:", coffee});
    }
    if (user == null) {
      state.add(CoffeeWithRating(coffee: coffee, rating: null));
    } else {
      state.add(await getUserRatingForCoffee(user, coffee));
    }
    notifyListeners();
  }

  void clearCoffees() async {
    if (kDebugMode) {
      print("[CompareCoffeesNotifier.clearCoffees]");
    }

    state = [];

    notifyListeners();
  }
}

/// Provider for coffees used in comparison functionality
final compareCoffeesProvider = ChangeNotifierProvider<CompareCoffeesNotifier>((ref) {
  return CompareCoffeesNotifier();
});
