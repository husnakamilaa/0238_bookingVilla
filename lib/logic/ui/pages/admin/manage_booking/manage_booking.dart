import 'package:booking_villa/data/models/booking.dart';
import 'package:booking_villa/data/repositories/booking_repository.dart';
import 'package:booking_villa/logic/bloc/booking/booking_bloc.dart';
import 'package:booking_villa/logic/bloc/booking/booking_event.dart';
import 'package:booking_villa/logic/bloc/booking/booking_state.dart';
import 'package:booking_villa/logic/ui/components/colours.dart';
import 'package:booking_villa/logic/ui/components/custom_card.dart';
import 'package:booking_villa/logic/ui/components/search_bar.dart';
import 'package:booking_villa/logic/ui/pages/admin/manage_booking/detailBooking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageBookingPage extends StatefulWidget {
  const ManageBookingPage({super.key});

  @override
  State<ManageBookingPage> createState() => _ManageBookingPageState();
}

class _ManageBookingPageState extends State<ManageBookingPage> {
  final _supabase = Supabase.instance.client;
  String _searchQuery = '';
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    context.read<BookingBloc>().add(FetchAllBookingsEvent());
  }

  List<BookingModel> _filtered(List<BookingModel> bookings) {
    return bookings.where((b) {
      final name = b.customerName?.toLowerCase() ?? '';
      final villa = b.villaName?.toLowerCase() ?? '';
      final matchSearch =
          _searchQuery.isEmpty ||
          name.contains(_searchQuery.toLowerCase()) ||
          villa.contains(_searchQuery.toLowerCase());
      final matchStatus =
          _selectedStatus == 'All' || b.statusBooking == _selectedStatus;
      return matchSearch && matchStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          "Manage Bookings",
          style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.navy),
      ),
      body: Column(
        children: [
          CustomSearchBar(
            hintText: "Search by customer or villa...",
            onChanged: (q) => setState(() => _searchQuery = q),
          ),
          _buildFilterChips(),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<BookingBloc, BookingState>(
              builder: (context, state) {
                if (state is BookingLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.navy),
                  );
                }
                if (state is BookingError) {
                  return Center(child: Text(state.message));
                }
                if (state is BookingLoaded) {
                  final filtered = _filtered(state.bookings);
                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text("Tidak ada booking ditemukan."),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) =>
                        _buildBookingCard(filtered[index]),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'paid', 'confirmed', 'cancelled'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: filters.map((status) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              label: Text(_labelStatus(status)),
              selected: _selectedStatus == status,
              onSelected: (_) => setState(() => _selectedStatus = status),
              selectedColor: AppColors.lightblue,
              checkmarkColor: AppColors.navy,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    final customerName = booking.customerName ?? 'Unknown';
    final villaName = booking.villaName ?? 'Unknown Villa';
    final villaImage = booking.villaImage ?? '';

    return CustomCard(
      imageUrl: villaImage,
      title: customerName,
      subtitle: villaName,
      badge: _statusBadge(booking.statusBooking),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailBookingAdminPage(
              booking: booking,
              customerName: customerName,
              villaName: villaName,
              villaImage: villaImage,
            ),
          ),
        );
   
        if (mounted) {
          context.read<BookingBloc>().add(FetchAllBookingsEvent());
        }
      },
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'paid':
  color = Colors.blue;
  break;
      case 'confirmed':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        _labelStatus(status),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _labelStatus(String status) {
    const map = {
      'All': 'Semua',
      'paid': 'sudah bayar',
      'confirmed': 'Dikonfirmasi',
      'cancelled': 'Dibatalkan',
    };
    return map[status] ?? status;
  }
}
