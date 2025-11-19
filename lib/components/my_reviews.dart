import 'package:coffee_review/components/review_card.dart';
import 'package:coffee_review/components/scaffold.dart';
import 'package:coffee_review/repositories/ratings.dart';
import 'package:coffee_review/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/coffees.dart';
import 'coffee.dart';

class MyReviews extends ConsumerStatefulWidget {
  const MyReviews({super.key});

  @override
  ConsumerState<MyReviews> createState() => _MyReviewsState();
}

class _MyReviewsState extends ConsumerState<MyReviews> {
  late Future<List<Rating>> ratings;

  @override
  void initState() {
    super.initState();

    User? user = getUser();
    ratings = getUserRatings(user);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ratings,
      builder: (BuildContext context, AsyncSnapshot<List<Rating>> snapshot) {
        return ScaffoldBuilder(
          body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(10),
                    children: snapshot.data?.map((r) {
                          return ReviewCard(
                            rating: r,
                            showCoffeeName: true,
                            showUserName: false,
                            onTap: () {
                              getCoffeeByRef(r.coffeeRef).then((coffee) {
                                if (context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            CoffeeInfo(coffee: coffee)),
                                  );
                                }
                              });
                            },
                          );
                        }).toList() ??
                        [],
                  ),
                ),
              ]),
        );
      },
    );
  }
}
