import 'package:coffee_review/repositories/taste_notes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tasteNotesProvider = FutureProvider.autoDispose((ref) async {
  var list = await getTasteNotes();
  if (kDebugMode) {
    print("TasteNotes $list");
  }
  return list;
});
