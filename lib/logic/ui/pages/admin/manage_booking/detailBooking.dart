import 'package:booking_villa/data/models/booking.dart';
import 'package:booking_villa/logic/bloc/booking/booking_bloc.dart';
import 'package:booking_villa/logic/bloc/booking/booking_event.dart';
import 'package:booking_villa/logic/bloc/booking/booking_state.dart';
import 'package:booking_villa/logic/ui/components/colours.dart';
import 'package:booking_villa/logic/ui/components/invoice_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class DetailBookingAdminPage extends StatefulWidget {
  final BookingModel booking;
  final String customerName;
  final String villaName;
  final String villaImage;

  const DetailBookingAdminPage({
    super.key,
    required this.booking,
    required this.customerName,
    required this.villaName,
    required this.villaImage,
  });

  @override
  State<DetailBookingAdminPage> createState() => _DetailBookingAdminPageState();
}

class _DetailBookingAdminPageState extends State<DetailBookingAdminPage> {
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.booking.statusBooking; 
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final date = DateFormat('dd MMMM yyyy');

    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
    
          context.read<BookingBloc>().add(FetchAllBookingsEvent());
          Navigator.pop(context);
        }
        if (state is BookingError) {
          setState(() => _currentStatus = widget.booking.statusBooking);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text(
            "Detail Booking",
            style: TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.navy),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: widget.villaImage.isNotEmpty
                    ? Image.network(
                        widget.villaImage,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 180,
                        color: AppColors.lightblue,
                        child: const Icon(
                          Icons.villa,
                          size: 60,
                          color: AppColors.navy,
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.villaName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                  _statusBadge(_currentStatus), 
                ],
              ),
              const SizedBox(height: 20),

              _sectionCard(
                children: [
                  _infoRow(
                    Icons.person_outline,
                    "Customer",
                    widget.customerName,
                  ),
                  const Divider(height: 20),
                  _infoRow(
                    Icons.tag,
                    "ID Booking",
                    "#${widget.booking.id.substring(0, 8).toUpperCase()}",
                  ),
                  const Divider(height: 20),
                  _infoRow(
                    Icons.login_rounded,
                    "Check In",
                    date.format(widget.booking.tglCheckin),
                  ),
                  const Divider(height: 20),
                  _infoRow(
                    Icons.logout_rounded,
                    "Check Out",
                    date.format(widget.booking.tglCheckout),
                  ),
                  const Divider(height: 20),
                  _infoRow(
                    Icons.nights_stay_outlined,
                    "Durasi",
                    "${widget.booking.tglCheckout.difference(widget.booking.tglCheckin).inDays} malam",
                  ),
                  const Divider(height: 20),
                  _infoRow(
                    Icons.payments_outlined,
                    "Total",
                    currency.format(widget.booking.totalPrice),
                  ),
                  if (widget.booking.payment != null) ...[
                    const Divider(height: 20),
                    _infoRow(
                      Icons.credit_card_outlined,
                      "Metode Bayar",
                      widget.booking.payment!,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              InvoiceViewerWidget(paymentProof: widget.booking.paymentProof),

              const SizedBox(height: 24),

              const Text(
                "Update Status",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 12),

              BlocBuilder<BookingBloc, BookingState>(
                builder: (context, state) {
                  final isLoading = state is BookingLoading;
                  return Row(
                    children: [
                      _statusButton(
                        context,
                        label: "Konfirmasi",
                        color: Colors.green,
                        icon: Icons.check_circle_outline,
                        status: "confirmed",
                        isLoading: isLoading,
                        currentStatus: _currentStatus, 
                      ),
                      const SizedBox(width: 10),
                      _statusButton(
                        context,
                        label: "Batalkan",
                        color: Colors.red,
                        icon: Icons.cancel_outlined,
                        status: "cancelled",
                        isLoading: isLoading,
                        currentStatus: _currentStatus,
                      ),
                      const SizedBox(width: 10),
                      _statusButton(
                        context,
                        label: "Paid",
                        color: Colors.blue,
                        icon: Icons.hourglass_empty_rounded,
                        status: "paid",
                        isLoading: isLoading,
                        currentStatus: _currentStatus,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade400),
        const SizedBox(width: 10),
        Text(
          "$label: ",
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'confirmed':
        color = Colors.green;
        label = 'Dikonfirmasi';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Dibatalkan';
        break;
      default:
        color = Colors.orange;
        label = 'Paid';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _statusButton(
    BuildContext context, {
    required String label,
    required Color color,
    required IconData icon,
    required String status,
    required bool isLoading,
    required String currentStatus,
  }) {
    final isActive = currentStatus == status;
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: isLoading || isActive
            ? null
            : () => _confirmUpdate(context, status),
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? color : color.withOpacity(0.1),
          foregroundColor: isActive ? Colors.white : color,
          disabledBackgroundColor: isActive ? color : Colors.grey.shade200,
          disabledForegroundColor: isActive ? Colors.white : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          elevation: 0,
        ),
      ),
    );
  }

  void _confirmUpdate(BuildContext context, String newStatus) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Konfirmasi"),
        content: Text(
          "Ubah status booking menjadi \"${_labelStatus(newStatus)}\"?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              setState(() => _currentStatus = newStatus);
              print('BOOKING ID: ${widget.booking.id}');
              print('NEW STATUS: $newStatus');
              context.read<BookingBloc>().add(
                UpdateBookingStatusEvent(widget.booking.id, newStatus),
              );
            },
            child: const Text("Ya, Ubah"),
          ),
        ],
      ),
    );
  }

  String _labelStatus(String status) {
    const map = {
      'paid': 'sudah bayar',
      'confirmed': 'Dikonfirmasi',
      'cancelled': 'Dibatalkan',
    };
    return map[status] ?? status;
  }
}
