import 'package:booking_villa/data/models/stats.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminStatsRepository {
  final _client = Supabase.instance.client;
 
  Future<AdminStatsModel> fetchStats() async {
  final response = await _client.functions.invoke('admin-stats');

  if (response.data == null) {
    throw Exception("Gagal memuat statistik");
  }

  final data = response.data as Map<String, dynamic>;

  return AdminStatsModel(
    totalCustomers: data['totalCustomers'] ?? 0,
    villaAvailable: data['villaAvailable'] ?? 0,
    bookingConfirmed: data['bookingConfirmed'] ?? 0,
    bookingPaid: data['bookingPaid'] ?? 0,
    bookingCancelled: data['bookingCancelled'] ?? 0,
  );
}
}