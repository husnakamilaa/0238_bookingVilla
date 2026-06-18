import 'package:booking_villa/logic/ui/components/colours.dart';
import 'package:booking_villa/logic/ui/pages/customer/invoice.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentPage extends StatefulWidget {
  final String redirectUrl;
  final String bookingId;

  const PaymentPage({
    super.key,
    required this.redirectUrl,
    required this.bookingId,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage>
    with WidgetsBindingObserver {
  bool _hasOpened = false;
  bool _waitingReturn = false;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _waitingReturn) {
      _waitingReturn = false;
      _checkBookingStatus();
    }
  }

  Future<void> _openPayment() async {
    final uri = Uri.parse(widget.redirectUrl);
    if (await canLaunchUrl(uri)) {
      setState(() {
        _hasOpened = true;
        _waitingReturn = true;
      });
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal membuka halaman pembayaran")),
        );
      }
    }
  }

  Future<void> _checkBookingStatus() async {
    setState(() => _isChecking = true);

    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(seconds: 2));

      try {
        final res = await Supabase.instance.client
            .from('booking')
            .select('status_booking')
            .eq('id', widget.bookingId)
            .single();

        final status = res['status_booking'];

        if (status == 'confirmed' || status == 'cancelled') {
          _navigateToInvoice();
          return;
        }
      } catch (_) {}
    }

    _navigateToInvoice();
  }

  void _navigateToInvoice() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => InvoicePage(bookingId: widget.bookingId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Pembayaran"),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: _isChecking
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    "Mengecek status pembayaran...",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.navy.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _hasOpened
                            ? Icons.pending_outlined
                            : Icons.payment_rounded,
                        size: 64,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _hasOpened
                          ? "Selesaikan pembayaran\ndi browser"
                          : "Siap untuk membayar?",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _hasOpened
                          ? "Setelah selesai bayar, kembali ke\naplikasi ini untuk melihat invoice."
                          : "Klik tombol di bawah untuk membuka\nhalaman pembayaran.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _openPayment,
                        icon: const Icon(
                          Icons.open_in_browser_rounded,
                          color: Colors.white,
                        ),
                        label: Text(
                          _hasOpened
                              ? "Buka ulang pembayaran"
                              : "Bayar Sekarang",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),

                  
                    if (_hasOpened) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() => _waitingReturn = false);
                            _checkBookingStatus();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.navy,
                            side: const BorderSide(color: AppColors.navy),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text("Saya sudah selesai pembayaran"),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}