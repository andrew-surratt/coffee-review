import 'package:coffee_review/components/image_box.dart';
import 'package:coffee_review/components/origin_text.dart';
import 'package:coffee_review/components/review.dart';
import 'package:coffee_review/components/review_card.dart';
import 'package:coffee_review/components/scaffold.dart';
import 'package:coffee_review/components/thumbnail.dart';
import 'package:coffee_review/providers/compare_coffees.dart';
import 'package:coffee_review/providers/icons.dart';
import 'package:coffee_review/services/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/config.dart';
import '../repositories/coffee_images.dart';
import '../repositories/coffees.dart';
import '../repositories/configs.dart';
import '../repositories/ratings.dart';

class CoffeeInfo extends ConsumerStatefulWidget {
  final Coffee coffee;

  const CoffeeInfo({super.key, required this.coffee});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CoffeeInfo();
}

enum MenuItem { addToComparison }

class _CoffeeInfo extends ConsumerState<CoffeeInfo> {
  ExpansionTileController expansionTileController = ExpansionTileController();
  late List<Rating> ratings = [];
  Uint8List? image;

  @override
  void initState() {
    super.initState();
    initRatings();
  }

  void initRatings() async {
    var r = await getCoffeeRatings(widget.coffee);
    setState(() {
      ratings = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final AsyncValue<Config> config = ref.watch(configProvider);

    var inputForm = ListView(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 1,
            child: widget.coffee.thumbnailPath.isNotEmpty
                ? Thumbnail(thumbnailPath: widget.coffee.thumbnailPath)
                : ImageBox(
                    image: image,
                    onChanged: ({required String extension, Uint8List? data}) {
                      setState(() {
                        image = data;
                        if (data != null) {
                          String uploadedPath = createUploadPath(extension);
                          uploadImageData(data, uploadedPath);
                          updateCoffeeImage(widget.coffee.ref, uploadedPath);
                        }
                      });
                    },
                  ),
          ),
          Flexible(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: buildInfo(),
              ),
            ),
          ),
        ],
      ),
      const Divider(height: 50, thickness: 1),
      ExpansionTile(
        title: Text('Leave a review'),
        controller: expansionTileController,
        collapsedBackgroundColor: theme.focusColor,
        backgroundColor: theme.focusColor,
        collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5))),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5))),
        children: <Widget>[
          Review(
              coffee: widget.coffee,
              onSubmit: (rating) {
                expansionTileController.collapse();
                initRatings();
              }),
        ],
      ),
      const Divider(height: 50, thickness: 1),
      ...buildReview(ratings),
    ]);
    return ScaffoldBuilder(
      body: inputForm,
      appBarActions: (config.value?.isComparisonChartEnabled ?? false)
          ? [
              PopupMenuButton<MenuItem>(
                onSelected: (MenuItem i) {
                  switch (i) {
                    case MenuItem.addToComparison:
                      ref
                          .read(compareCoffeesProvider)
                          .addCoffee(widget.coffee, getUser());
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<MenuItem>(
                      value: MenuItem.addToComparison,
                      child: Text('Add to comparison'),
                    ),
                  ];
                },
              ),
            ]
          : null,
    );
  }

  List<Widget> buildInfo() {
    var icons = ref.watch(iconsProvider);

    List<Widget> tastingNotesRow = [];
    for (var note in widget.coffee.tastingNotes) {
      if (tastingNotesRow.isNotEmpty) {
        tastingNotesRow.add(const Text(' | '));
      }
      tastingNotesRow.add(Text(
        note,
        style: const TextStyle(
            fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
      ));
    }

    var h1Style = const TextStyle(fontSize: 25, fontWeight: FontWeight.bold);

    var fairTradeIcon = icons.value?.fairTrade;
    var organicIcon = icons.value?.organic;
    List<Widget> iconsRow = [];
    const iconPadding = EdgeInsets.symmetric(horizontal: 5, vertical: 5);
    if (fairTradeIcon != null && widget.coffee.fairTrade) {
      iconsRow.add(Padding(
          padding: iconPadding,
          child: Image.memory(
            fairTradeIcon,
            scale: 8,
            semanticLabel: 'Fair Trade Certified',
          )));
    }
    if (organicIcon != null && widget.coffee.usdaOrganic) {
      iconsRow.add(Padding(
          padding: iconPadding,
          child: Image.memory(
            organicIcon,
            scale: 8,
            semanticLabel: 'USDA Organic Certified',
          )));
    }

    return [
      Text(widget.coffee.roaster),
      Text(widget.coffee.name, style: h1Style),
      Text("(\$${widget.coffee.costPerOz.toString()} / oz)"),
      Wrap(children: tastingNotesRow),
      OriginText(
        origins: widget.coffee.origins,
        maxLines: 3,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: iconsRow,
      ),
    ];
  }

  List<ReviewCard> buildReview(List<Rating> reviews) {
    if (kDebugMode) {
      print("Building reviews for ${widget.coffee.name}: ${reviews.map((r) {
        return r.userName;
      }).join(", ")}");
    }
    return reviews.map((r) {
      return ReviewCard(rating: r);
    }).toList();
  }
}
