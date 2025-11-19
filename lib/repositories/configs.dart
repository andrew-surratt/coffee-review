import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_review/providers/config.dart';
import 'package:flutter/foundation.dart';

var configCollection = FirebaseFirestore.instance
    .collection('configs')
    .withConverter(
        fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot, _) {
  var repoConfig = snapshot.data();
  return RepoConfig(
      type: repoConfig?['type'],
      title: repoConfig?['title'] ?? defaultConfig.title,
      isComparisonChartEnabled: repoConfig?['isComparisonChartEnabled'] ?? defaultConfig.isComparisonChartEnabled,
      defaultChartCoffeeNames: repoConfig?['defaultChartCoffeeNames'] ?? defaultConfig.defaultChartCoffeeNames,
      defaultRoasterQuery: repoConfig?['defaultRoasterQuery'] ?? defaultConfig.defaultRoasterQuery
  );
}, toFirestore: (RepoConfig repoConfig, _) {
  return {
    'type': repoConfig.type,
    'title': repoConfig.title,
    'isComparisonChartEnabled': repoConfig.isComparisonChartEnabled,
    'defaultChartCoffeeNames': repoConfig.defaultChartCoffeeNames,
    'defaultRoasterQuery': repoConfig.defaultRoasterQuery
  };
});

Future<Config> getConfig() async {
  return await configCollection.where('type', isEqualTo: 'default')
      .get().then((event) {

    RepoConfig? defaultRepoConfig = event.docs
        .map((e) {
          var data = e.data();
          if (kDebugMode) {
            print("${e.id} => $data");
          }
          return data;
        })
        .firstOrNull;
    return defaultRepoConfig ?? defaultConfig;
  });
}

class Config {
  final String title;
  final bool isComparisonChartEnabled;
  final List<String> defaultChartCoffeeNames;
  final String defaultRoasterQuery;

  Config({required this.title, required this.isComparisonChartEnabled, required this.defaultChartCoffeeNames, required this.defaultRoasterQuery});
}

class RepoConfig extends Config {
  final String type;

  RepoConfig({required this.type, required super.title, required super.isComparisonChartEnabled, required super.defaultChartCoffeeNames, required super.defaultRoasterQuery});
}
