import 'dart:typed_data';

import 'package:coffee_review/components/image_box.dart';
import 'package:coffee_review/components/scaffold.dart';
import 'package:coffee_review/providers/coffees_index.dart';
import 'package:coffee_review/providers/origins_index.dart';
import 'package:coffee_review/providers/roasters_index.dart';
import 'package:coffee_review/providers/taste_notes.dart';
import 'package:coffee_review/repositories/coffee_images.dart';
import 'package:coffee_review/repositories/origins.dart';
import 'package:coffee_review/repositories/roasters.dart';
import 'package:coffee_review/repositories/taste_notes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:textfield_tags/textfield_tags.dart';

import '../repositories/coffees.dart';
import '../services/coffee.dart';
import '../services/finance.dart';
import '../utils/forms.dart';
import 'coffee.dart';
import 'multi_tag_field.dart';

class CoffeeInput extends ConsumerStatefulWidget {
  const CoffeeInput({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CoffeeInput();
}

class _CoffeeInput extends ConsumerState<CoffeeInput> {
  final _formKey = GlobalKey<FormState>();
  final roasterName = TextEditingController();
  final roasterFocusNode = FocusNode();
  final name = TextEditingController();
  final tasteNotesController = DynamicTagController<DynamicTagData>();
  final cost = TextEditingController();
  final weight = TextEditingController();

  var originFields = [
    (
      origin: TextEditingController(),
      originPercentage: TextEditingController(),
      focusNode: FocusNode(),
    )
  ];
  bool isOrganic = false;
  bool isFairTrade = false;
  Uint8List? image;
  String? imageExtension;

  @override
  Widget build(BuildContext context) {
    AsyncValue<List<String>> tasteNotes = ref.watch(tasteNotesProvider);
    AsyncValue<List<String>> roastersIndex = ref.watch(roastersIndexProvider);

    const itemPadding = EdgeInsets.symmetric(vertical: 5, horizontal: 5);
    var inputForm = Form(
        key: _formKey,
        child: ListView(
          padding: itemPadding,
          children: [
            Padding(
              padding: itemPadding,
              child: buildFormFieldTextAutocomplete(
                controller: roasterName,
                focusNode: roasterFocusNode,
                label: 'Roaster Name',
                hint: 'Stumptown',
                validationText: () => 'Enter a roaster',
                autocompleteOptions: roastersIndex.value ?? [],
              ),
            ),
            Padding(
              padding: itemPadding,
              child: buildFormFieldText(
                  controller: name,
                  label: 'Coffee Name',
                  hint: 'Holler Mountain',
                  validationText: () => 'Enter a coffee'),
            ),
            Padding(
              padding: itemPadding,
              child: buildImageUploadBox(),
            ),
            Padding(
                padding: itemPadding,
                child: DynamicAutoCompleteTags(
                  dynamicTagController: tasteNotesController,
                  initialTags: tasteNotes.value
                          ?.map((t) => DynamicTagData(t, null))
                          .toList() ??
                      [],
                )),
            Padding(
              padding: itemPadding,
              child: buildFormFieldDouble(
                  controller: cost,
                  label: 'Cost of beans/grounds (\$)',
                  hint: '20',
                  validationText: () => 'Enter an amount'),
            ),
            Padding(
              padding: itemPadding,
              child: buildFormFieldDouble(
                  controller: weight,
                  label: 'Weight of beans/grounds (oz)',
                  hint: '10',
                  validationText: () => 'Enter an amount'),
            ),
            Padding(
              padding: itemPadding,
              child: buildCertificationsCheckboxes(),
            ),
            ...buildOriginFields(),
            Padding(
              padding: itemPadding,
              child: buildAddOriginButton(context),
            ),
            Padding(
              padding: itemPadding,
              child: buildSubmitButton(context),
            ),
          ],
        ));
    return ScaffoldBuilder(
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: inputForm));
  }

  Row buildCertificationsCheckboxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        buildCheckboxField(
            isChecked: isOrganic,
            label: 'USDA Organic',
            onChanged: (isChecked) {
              setState(() {
                isOrganic = isChecked ?? false;
              });
            }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: buildCheckboxField(
              isChecked: isFairTrade,
              label: 'Fair Trade',
              onChanged: (isChecked) {
                setState(() {
                  isFairTrade = isChecked ?? false;
                });
              }),
        ),
      ],
    );
  }

  Row buildImageUploadBox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          flex: 1,
          child: ImageBox(
            onChanged: ({required String extension, Uint8List? data}) {
              setState(() {
                image = data;
                imageExtension = extension;
              });
            },
          ),
        ),
        const Spacer(flex: 2)
      ],
    );
  }

  List<Widget> buildOriginFields() {
    AsyncValue<List<String>> originsWatch = ref.watch(originIndexProvider);

    return originFields
        .map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 5,
                    child: buildFormFieldTextAutocomplete(
                      controller: e.origin,
                      focusNode: e.focusNode,
                      label: 'Origin',
                      hint: 'Brazil',
                      validationText: () => 'Enter an origin country',
                      autocompleteOptions: originsWatch.value ?? [],
                    ),
                  ),
                  const Spacer(flex: 1),
                  Flexible(
                    flex: 2,
                    child: buildFormFieldDouble(
                        controller: e.originPercentage,
                        label: '%',
                        hint: '100',
                        validationText: () => 'Enter a percentage 1-100'),
                  ),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          originFields.removeAt(originFields.indexOf(e));
                        });
                      },
                      child: const Icon(Icons.close))
                ])))
        .toList();
  }

  Widget buildAddOriginButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            originFields.add((
              origin: TextEditingController(),
              originPercentage: TextEditingController(),
              focusNode: FocusNode(),
            ));
          });
        },
        child: const Text('Add another origin'),
      ),
    );
  }

  Padding buildSubmitButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: FilledButton(
        onPressed: () {
          submitCoffee(context).then((coffee) {
            if (context.mounted) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CoffeeInfo(coffee: coffee),
                  ));
            }
          });
        },
        child: const Text('Submit'),
      ),
    );
  }

  Future<Coffee> submitCoffee(BuildContext context) async {
    _formKey.currentState?.validate();

    var costValue = double.parse(cost.value.text);
    var weightValue = double.parse(weight.value.text);
    var costPerOz = toPrecision(calculateCostPerOz(costValue, weightValue));
    var origins = originFields
        .map((e) => CoffeeOrigin(
              origin: e.origin.text,
              percentage: double.parse(e.originPercentage.text),
            ))
        .toList();

    String uploadedPath = '';
    if (image != null && imageExtension != null) {
      uploadedPath = createUploadPath(imageExtension!);
      uploadImageData(image!, uploadedPath);
    }

    var coffeeName = name.value.text;
    var roaster = roasterName.value.text;
    var coffee = await addCoffee(CoffeeCreateReq(
      roaster: roaster,
      name: coffeeName,
      costPerOz: costPerOz,
      tastingNotes:
          tasteNotesController.getTags?.map((e) => e.tag).toList() ?? [],
      usdaOrganic: isOrganic,
      fairTrade: isFairTrade,
      thumbnailPath: uploadedPath,
      origins: origins,
    ));

    AsyncValue<List<CoffeeIndex>> coffeeIndex = ref.watch(coffeesIndexProvider);

    upsertCoffeeIndex(coffeeName, roaster,
        createDoc: coffeeIndex.value == null || coffeeIndex.value!.isEmpty);

    ref.invalidate(coffeesIndexProvider);

    AsyncValue<List<String>> roastersIndex = ref.watch(roastersIndexProvider);

    upsertRoastersIndex(roaster,
        createDoc: roastersIndex.value == null || roastersIndex.value!.isEmpty);

    ref.invalidate(roastersIndexProvider);

    var originsWatch = ref.watch(originIndexProvider);

    for (final String o in origins.map((e) => e.origin).toList()) {
      await upsertOriginIndex(o,
          createDoc: originsWatch.value == null || originsWatch.value!.isEmpty);
    }

    ref.invalidate(originIndexProvider);

    tasteNotesController.getTags?.forEach((element) {
      addTastingNote(element.tag);
    });

    ref.invalidate(tasteNotesProvider);

    return coffee;
  }
}
