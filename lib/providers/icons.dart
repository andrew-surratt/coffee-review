import 'package:coffee_review/services/storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final iconsProvider = FutureProvider.autoDispose((ref) async {
  var ftIcon = await getStoredData('Fair_Trade_Icon.png');
  var organicIcon = await getStoredData('USDA_Organic_Icon.png');
  return (
    fairTrade: ftIcon,
    organic: organicIcon,
  );
});
