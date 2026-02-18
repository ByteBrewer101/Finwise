import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/category.dart';

final categoryProvider =
    FutureProvider<List<Category>>((ref) async {
  final client = Supabase.instance.client;

  final response = await client
      .from('categories')
      .select()
      .order('created_at');

  return (response as List)
      .map((e) => Category.fromJson(e))
      .toList();
});
