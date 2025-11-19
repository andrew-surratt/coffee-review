import 'package:coffee_review/components/coffee.dart';
import 'package:coffee_review/components/coffee_input.dart';
import 'package:coffee_review/components/scaffold.dart';
import 'package:coffee_review/components/thumbnail.dart';
import 'package:coffee_review/providers/coffees_index.dart';
import 'package:coffee_review/providers/config.dart';
import 'package:coffee_review/providers/roasters_index.dart';
import 'package:coffee_review/repositories/coffees.dart';
import 'package:coffee_review/repositories/configs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'origin_text.dart';

class Coffees extends ConsumerStatefulWidget {
  const Coffees({super.key});

  @override
  ConsumerState<Coffees> createState() => _CoffeesState();
}

class _CoffeesState extends ConsumerState<Coffees> {
  late Future<List<Coffee>> coffees;
  String roasterSearch = '';
  String nameSearch = '';

  @override
  void initState() {
    super.initState();
    AsyncValue<Config> config = ref.read(configProvider);
    coffees = getCoffeesByRoaster(
        config.value?.defaultRoasterQuery ?? defaultConfig.defaultRoasterQuery);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: coffees,
      builder: (BuildContext context, AsyncSnapshot<List<Coffee>> snapshot) {
        var results = !snapshot.hasData ||
                snapshot.connectionState == ConnectionState.waiting
            ? Container(
                padding: EdgeInsets.all(30),
                alignment: Alignment.center,
                child: CircularProgressIndicator())
            : buildResults(context, snapshot);

        return ScaffoldBuilder(
            body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 60,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: buildSearchAnchor(),
                    ),
                  ),
                  Expanded(
                    child: results,
                  ),
                ]),
            floatingActionButton: FloatingActionButton.small(
                onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CoffeeInput()),
                    ),
                child: const Icon(Icons.add)));
      },
    );
  }

  ListView buildResults(
      BuildContext context, AsyncSnapshot<List<Coffee>> snapshot) {
    return ListView(
      padding: const EdgeInsets.all(10),
      children: snapshot.data
              ?.map((e) => SizedBox(
                    height: 70,
                    child: buildCard(context, e),
                  ))
              .toList() ??
          [],
    );
  }

  SearchAnchor buildSearchAnchor() {
    var coffeesIndex = ref.watch(coffeesIndexProvider);
    var roastersIndex = ref.watch(roastersIndexProvider);

    return SearchAnchor(
        builder: (BuildContext context, SearchController controller) {
      return SearchBar(
        controller: controller,
        padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0)),
        onTap: () {
          controller.openView();
        },
        onChanged: (_) {
          controller.openView();
        },
        onSubmitted: (String _) {
          setState(() {
            if (roasterSearch.isNotEmpty) {
              coffees = getCoffeesByRoaster(roasterSearch);
            } else {
              coffees = getCoffee(nameSearch);
            }
          });
        },
        leading: const Icon(Icons.search),
      );
    }, suggestionsBuilder: (BuildContext context, SearchController controller) {
      var searchQuery = controller.value.text.toLowerCase();
      var roasterTiles = roastersIndex.value
              ?.where((element) =>
                  searchQuery.isEmpty ||
                  element.toLowerCase().contains(searchQuery))
              .map((e) => ListTile(
                    title: Text(e),
                    onTap: () {
                      setState(() {
                        roasterSearch = e;
                        nameSearch = '';
                        controller.closeView(e);
                      });
                    },
                  )) ??
          [];
      return roasterTiles.followedBy(coffeesIndex.value?.where((e) {
            return searchQuery.isEmpty ||
                e.roaster.toLowerCase().contains(searchQuery) ||
                e.name.toLowerCase().contains(searchQuery);
          }).map((e) => ListTile(
                title: Text(e.name),
                subtitle: Text(e.roaster),
                onTap: () {
                  setState(() {
                    roasterSearch = '';
                    nameSearch = e.name;
                    controller.closeView("${e.roaster} ${e.name}");
                  });
                },
              )) ??
          []);
    });
  }

  Widget buildCard(
    BuildContext context,
    Coffee coffee,
  ) {
    var theme = Theme.of(context);
    var info = Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("${coffee.roaster} ${coffee.name}",
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(coffee.tastingNotes.join(', '),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(fontStyle: FontStyle.italic)),
        OriginText(origins: coffee.origins),
      ],
    );
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CoffeeInfo(coffee: coffee)),
        );
      },
      splashColor: theme.primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Thumbnail(thumbnailPath: coffee.thumbnailPath),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: info,
          )),
        ],
      ),
    );
  }
}
