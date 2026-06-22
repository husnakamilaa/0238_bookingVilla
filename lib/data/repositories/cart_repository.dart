import 'package:booking_villa/data/models/cart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartRepository {
  final _client = Supabase.instance.client;

  String? get _currentUserId => _client.auth.currentUser?.id;

  Future<List<CartModel>> getCartItems() async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User belum login');

    final response = await _client
        .from('cart')
        .select('*, villa(*)')
        .eq('user_id', userId);

    return (response as List).map((c) => CartModel.fromJson(c)).toList();
  }

  Future<void> addToCart(int villaId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User belum login');

    await _client.from('cart').insert({
      'user_id': userId,
      'villa_id': villaId,
    });
  }


  Future<void> deleteCartItem(String id) async {
    await _client.from('cart').delete().eq('id', id);
  }
}