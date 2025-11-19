import 'package:coffee_review/components/coffees.dart';
import 'package:coffee_review/components/comparison_chart.dart';
import 'package:coffee_review/components/user_profile.dart';
import 'package:coffee_review/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/config.dart';
import '../repositories/configs.dart';
import 'my_reviews.dart';

class ScaffoldBuilder extends ConsumerWidget {
  final Widget body;

  final String? widgetTitle;

  final FloatingActionButton? floatingActionButton;

  final List<Widget>? appBarActions;

  const ScaffoldBuilder(
      {super.key,
      required this.body,
      this.widgetTitle,
      this.floatingActionButton,
      this.appBarActions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var themeData = Theme.of(context);
    final AsyncValue<Config> config = ref.watch(configProvider);
    User? user = getUser();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeData.colorScheme.primary,
        foregroundColor: themeData.colorScheme.secondaryContainer,
        title: Text(config.value?.title ?? defaultConfig.title),
        actions: appBarActions,
      ),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: Center(child: body),
      ),
      floatingActionButton: floatingActionButton,
      drawer: user != null ? buildDrawer(context, config) : null,
    );
  }

  Drawer buildDrawer(BuildContext context, AsyncValue<Config> config) {
    var theme = Theme.of(context);
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 140,
            child: DrawerHeader(
              decoration: BoxDecoration(color: theme.primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: const Row(children: [
                Icon(Icons.coffee),
                Spacer(),
              ]),
            ),
          ),
          ListTile(
            title: const Text('Home'),
            leading: const Icon(Icons.home),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Coffees()));
            },
          ),
          ListTile(
            title: const Text('My Reviews'),
            leading: const Icon(Icons.rate_review),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const MyReviews()));
            },
          ),
          if (config.value?.isComparisonChartEnabled ?? false)
            ListTile(
              title: const Text('Compare'),
              leading: const Icon(Icons.bar_chart),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ComparisonChart(chartComponents: [
                              ChartComponent(ComponentName.price),
                              ChartComponent(ComponentName.rating),
                            ])));
              },
            ),
          const Spacer(),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: ListTile(
                title: const Text('Profile'),
                leading: const Icon(Icons.person),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserProfile(),
                      ));
                },
              )),
        ],
      ),
    );
  }
}
