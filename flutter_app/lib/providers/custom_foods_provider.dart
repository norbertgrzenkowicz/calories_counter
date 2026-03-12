import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/custom_food.dart';

class CustomFoodsNotifier extends AsyncNotifier<List<CustomFood>> {
  @override
  Future<List<CustomFood>> build() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await client
        .from('custom_foods')
        .select()
        .eq('uid', userId)
        .order('name');

    return (data as List)
        .map((d) => CustomFood.fromSupabase(d as Map<String, dynamic>))
        .toList();
  }

  Future<void> addFood(CustomFood food) async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    await client.from('custom_foods').insert({
      ...food.toSupabase(),
      'uid': userId,
    });
    ref.invalidateSelf();
  }

  Future<void> updateFood(CustomFood food) async {
    if (food.id == null) throw Exception('Cannot update food without id');
    final client = Supabase.instance.client;
    await client
        .from('custom_foods')
        .update(food.toSupabase())
        .eq('id', food.id!);
    ref.invalidateSelf();
  }

  Future<void> deleteFood(int id) async {
    final client = Supabase.instance.client;
    await client.from('custom_foods').delete().eq('id', id);
    ref.invalidateSelf();
  }
}

final customFoodsProvider =
    AsyncNotifierProvider<CustomFoodsNotifier, List<CustomFood>>(
  CustomFoodsNotifier.new,
);
