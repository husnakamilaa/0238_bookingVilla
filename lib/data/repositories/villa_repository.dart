import 'package:booking_villa/data/models/villa.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VillaRepository {
  final _client = Supabase.instance.client;

  Future<List<VillaModel>> getAllVillas({
    bool onlyAvailable = true,
    int page = 0,
    int pageSize = 10,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;
    late PostgrestList response;

    if (onlyAvailable) {
      response = await _client
          .from('villa')
          .select()
          .eq('status_available', 'available')
          .order('created_at', ascending: false)
          .range(from, to);
    } else {
      response = await _client
          .from('villa')
          .select()
          .order('created_at', ascending: false)
          .range(from, to);
    }
    return response.map((v) => VillaModel.fromJson(v)).toList();
  }

  Future<VillaModel> getVillaById(int id) async {
    final response = await _client
        .from('villa')
        .select()
        .eq('id', id)
        .single(); 

    return VillaModel.fromJson(response);
  }

  Future<List<VillaModel>> searchVilla(String query) async {
    final response = await _client
        .from('villa')
        .select()
        .ilike('nama_villa', '%$query%')
        .order('nama_villa', ascending: true);

    return (response as List).map((v) => VillaModel.fromJson(v)).toList();
  }

  Future<List<VillaModel>> searchAvailableVilla({
    required String query,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {

    final availResponse = await _client.functions.invoke(
      'check-availability',
      body: {
        'checkIn': checkIn.toIso8601String(),
        'checkOut': checkOut.toIso8601String(),
      },
    );

    final bookedVillaIds = (availResponse.data as List)
        .map((e) => e['villa_id'])
        .toList();

    dynamic villaQuery = _client
        .from('villa')
        .select()
        .ilike('nama_villa', '%$query%');

    if (bookedVillaIds.isNotEmpty) {
      villaQuery = villaQuery.not('id', 'in', '(${bookedVillaIds.join(',')})');
    }

    final response = await villaQuery;
    return (response as List).map((v) => VillaModel.fromJson(v)).toList();
  }

  Future<List<VillaModel>> filterByStatus(String status) async {
    final response = await _client
        .from('villa')
        .select()
        .eq('status_available', status)
        .order('created_at', ascending: false);

    return (response as List).map((v) => VillaModel.fromJson(v)).toList();
  }

  Future<void> updateVillaStatus(int id, String status) async {
    await _client
        .from('villa')
        .update({'status_available': status})
        .eq('id', id);
  }

  Future<void> addVilla(VillaModel villa) async {
    await _client.from('villa').insert(villa.toJson());
  }

  Future<void> updateVilla(int id, VillaModel villa) async {
    await _client.from('villa').update(villa.toJson()).eq('id', id);
  }

  Future<void> deleteVilla(int id) async {
    await _client.from('villa').delete().eq('id', id);
  }
}
