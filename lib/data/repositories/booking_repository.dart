import 'package:booking_villa/data/models/booking.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingRepository {
  final _client = Supabase.instance.client;

  Future<void> createBooking(BookingModel booking) async {
    await _client
        .from('booking')
        .insert(booking.toJson());
  }

  Future<List<BookingModel>> getMyBookings(String userId) async {
  final response = await _client
      .from('booking')
      .select('''
        *,
        villa!booking_villa_id_fkey (
          nama_villa,
          image
        ),
        profiles!booking_user_id_fkey (
          nama
        )
      ''')
      .eq('user_id', userId)
      .order('created_at', ascending: false);

  return (response as List)
      .map((e) => BookingModel.fromJson(e))
      .toList();
}

Future<List<BookingModel>> getAllBookingsAdmin() async {
  final response = await _client.functions.invoke(
    'admin-bookings',
  );

  final data = response.data as List;

  return data
      .map((e) => BookingModel.fromJson(e))
      .toList();
}

  Future<BookingModel> getBookingById(String bookingId) async {
    final response = await _client
        .from('booking')
        .select()
        .eq('id', bookingId)
        .single();

    return BookingModel.fromJson(response);
  }

  Future<void> updateBookingStatus(
    String bookingId,
    String status,
  ) async {
  
   try {
    await _client
        .from('booking')
        .update({'status_booking': status})
        .eq('id', bookingId);
    
  } catch (e) {
   
    rethrow;
  }
  }

  Future<void> saveInvoice(
    String bookingId,
    String invoiceUrl,
    String paymentMethod,
  ) async {
    await _client
        .from('booking')
        .update({
          'payment_proof': invoiceUrl,
          'payment': paymentMethod,
        })
        .eq('id', bookingId);
  }

  Future<void> cancelBooking(String bookingId) async {
    await _client
        .from('booking')
        .update({
          'status_booking': 'cancelled',
        })
        .eq('id', bookingId);
  }
}