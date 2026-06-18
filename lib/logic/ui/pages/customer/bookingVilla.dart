import 'package:booking_villa/data/models/villa.dart';
import 'package:booking_villa/data/repositories/payment_repository.dart';
import 'package:booking_villa/logic/bloc/payment/payment_bloc.dart';
import 'package:booking_villa/logic/bloc/payment/payment_event.dart';
import 'package:booking_villa/logic/bloc/payment/payment_state.dart';
import 'package:booking_villa/logic/ui/components/colours.dart';
import 'package:booking_villa/logic/ui/components/date_picker.dart';
import 'package:booking_villa/logic/ui/pages/customer/payment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingPage extends StatefulWidget {
  final VillaModel villa;
  final DateTime? initialCheckIn;
  final DateTime? initialCheckOut;

  const BookingPage({
    super.key,
    required this.villa,
    this.initialCheckIn,
    this.initialCheckOut,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? checkInDate;
  DateTime? checkOutDate;

  @override
  void initState() {
    super.initState();
    checkInDate = widget.initialCheckIn;
    checkOutDate = widget.initialCheckOut;
  }

  int get totalNight {
    if (checkInDate == null || checkOutDate == null) return 0;
    return checkOutDate!.difference(checkInDate!).inDays;
  }

  int get totalPrice => totalNight * widget.villa.price;

  String _formatDate(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return BlocProvider(
      create: (_) => PaymentBloc(PaymentRepository()),
      child: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentPage(
                  redirectUrl: state.redirectUrl,
                  bookingId: state.bookingId,
                ),
              ),
            );
          } else if (state is PaymentFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final currencyFormatter = NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          );

          final isLoading = state is PaymentLoading;

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text("Booking Villa"),
              backgroundColor: AppColors.navy,
              foregroundColor: Colors.white,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= VILLA =================
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      widget.villa.image,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    widget.villa.namaVilla,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    currencyFormatter.format(widget.villa.price),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // ================= TANGGAL =================
                  const Text(
                    "Tanggal Menginap",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: CustomDatePicker(
                          label: "Check In",
                          selectedDate: checkInDate,
                          onDateChanged: (date) {
                            setState(() => checkInDate = date);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomDatePicker(
                          label: "Check Out",
                          selectedDate: checkOutDate,
                          onDateChanged: (date) {
                            setState(() => checkOutDate = date);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // ================= RINGKASAN =================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        _summaryRow(
                          "Harga / malam",
                          currencyFormatter.format(widget.villa.price),
                        ),
                        const SizedBox(height: 12),
                        _summaryRow(
                          "Jumlah malam",
                          "$totalNight malam",
                        ),
                        const Divider(height: 25),
                        _summaryRow(
                          "Total pembayaran",
                          currencyFormatter.format(totalPrice),
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SizedBox(
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (checkInDate == null || checkOutDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Pilih tanggal terlebih dahulu"),
                              ),
                            );
                            return;
                          }

                          if (totalNight <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Tanggal tidak valid"),
                              ),
                            );
                            return;
                          }

                          // Ambil data user dari Supabase
                          final user = supabase.auth.currentUser;
                          if (user == null) return;

                          final profile = await supabase
                              .from('profiles')
                              .select('nama')
                              .eq('id', user.id)
                              .single();

                          if (!context.mounted) return;

                          context.read<PaymentBloc>().add(
                            CreatePayment(
                              villaId: widget.villa.id.toString(),
                              userId: user.id,
                              tglCheckin: _formatDate(checkInDate!),
                              tglCheckout: _formatDate(checkOutDate!),
                              amount: totalPrice,
                              customerName: profile['nama'] ?? 'Customer',
                              customerEmail: user.email ?? '',
                            ),
                          );
                        },
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Lanjut Pembayaran",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _summaryRow(String title, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? AppColors.navy : Colors.black,
          ),
        ),
      ],
    );
  }
}