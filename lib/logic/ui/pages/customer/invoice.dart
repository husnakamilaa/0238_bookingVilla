import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:booking_villa/data/models/booking.dart';
import 'package:booking_villa/data/repositories/booking_repository.dart';
import 'package:booking_villa/logic/ui/components/colours.dart';
import 'package:booking_villa/logic/ui/components/invoice.dart';
import 'package:booking_villa/logic/ui/pages/customer/riwayat/riwayatBooking.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InvoicePage extends StatefulWidget {
  final String bookingId;

  const InvoicePage({super.key, required this.bookingId});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  final GlobalKey _invoiceKey = GlobalKey();

  BookingModel? _booking;
  String _villaName = '';
  String _villaImage = '';
  String _customerName = '';
  String _customerEmail = '';
  bool _isLoading = true;
  bool _isGeneratingPdf = false;

  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final repo = BookingRepository();

      BookingModel? booking;
      int retries = 3;

      while (retries > 0) {
        booking = await repo.getBookingById(widget.bookingId);
        if (booking != null) break;
        await Future.delayed(const Duration(seconds: 2));
        retries--;
      }

      if (booking == null) {
        setState(() => _isLoading = false);
        return;
      }

      final villa = await _supabase
          .from('villa')
          .select('nama_villa, image')
          .eq('id', booking.villaId)
          .maybeSingle(); 

      if (villa == null) {
        throw Exception(
          'Data villa tidak ditemukan untuk id: ${booking.villaId}',
        );
      }

      final profile = await _supabase
          .from('profiles')
          .select('nama')
          .eq('id', booking.userId)
          .maybeSingle(); 

      final user = _supabase.auth.currentUser;

      setState(() {
        _booking = booking;
        _villaName = villa['nama_villa'] ?? '';
        _villaImage = villa['image'] ?? '';
        _customerName = profile?['nama'] ?? user?.email ?? 'Customer';
        _customerEmail = user?.email ?? '';
        _isLoading = false;
      });

      if (booking.paymentProof == null || booking.paymentProof!.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 500));
        await _generateAndUploadPdf();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('_fetchData error: $e'); 
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal memuat invoice: $e")));
      }
    }
  }

  Future<Uint8List> _capturePdfBytes() async {

    await Future.delayed(const Duration(milliseconds: 300));

    final boundary =
        _invoiceKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;

    if (boundary == null) throw Exception("Widget belum siap");

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    final pdf = pw.Document();
    final pdfImage = pw.MemoryImage(pngBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Image(pdfImage, fit: pw.BoxFit.contain);
        },
      ),
    );

    return await pdf.save();
  }

  Future<void> _generateAndUploadPdf() async {
    if (_booking == null) return;

    setState(() => _isGeneratingPdf = true);

    try {
      final pdfBytes = await _capturePdfBytes();

      final fileName =
          'invoice_${widget.bookingId.substring(0, 8).toUpperCase()}_${DateTime.now().millisecondsSinceEpoch}.pdf';

     
      await _supabase.storage
          .from('invoice')
          .uploadBinary(
            fileName,
            pdfBytes,
            fileOptions: const FileOptions(contentType: 'application/pdf'),
          );

  
      final publicUrl = _supabase.storage
          .from('invoice')
          .getPublicUrl(fileName);

      await _supabase
          .from('booking')
          .update({'payment_proof': publicUrl})
          .eq('id', widget.bookingId);

   
      setState(() {
        _booking = BookingModel(
          id: _booking!.id,
          userId: _booking!.userId,
          villaId: _booking!.villaId,
          tglCheckin: _booking!.tglCheckin,
          tglCheckout: _booking!.tglCheckout,
          statusBooking: _booking!.statusBooking,
          payment: _booking!.payment,
          paymentProof: publicUrl,
          totalPrice: _booking!.totalPrice,
          createdAt: _booking!.createdAt,
        );
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal membuat PDF: $e")));
      }
    } finally {
      setState(() => _isGeneratingPdf = false);
    }
  }


  Future<void> _sharePdf() async {
    if (_booking == null) return;

    setState(() => _isGeneratingPdf = true);

    try {
      final pdfBytes = await _capturePdfBytes();

      final dir = await getTemporaryDirectory();
      final fileName =
          'invoice_${widget.bookingId.substring(0, 8).toUpperCase()}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      await Share.shareXFiles([
        XFile(file.path),
      ], subject: 'Invoice Booking Villa - $_villaName');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal share PDF: $e")));
      }
    } finally {
      setState(() => _isGeneratingPdf = false);
    }
  }


  Future<void> _downloadPdf() async {
    if (_booking == null) return;

    setState(() => _isGeneratingPdf = true);

    try {
      final pdfBytes = await _capturePdfBytes();

      final downloadsDir = await getApplicationDocumentsDirectory();
      final fileName =
          'invoice_${widget.bookingId.substring(0, 8).toUpperCase()}.pdf';
      final file = File('${downloadsDir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("PDF disimpan ke: ${file.path}"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal simpan PDF: $e")));
      }
    } finally {
      setState(() => _isGeneratingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Invoice"),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          if (!_isLoading && _booking != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'share') _sharePdf();
                if (value == 'download') _downloadPdf();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share_outlined),
                      SizedBox(width: 8),
                      Text("Bagikan Invoice"),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'download',
                  child: Row(
                    children: [
                      Icon(Icons.download_outlined),
                      SizedBox(width: 8),
                      Text("Simpan PDF"),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _booking == null
          ? const Center(child: Text("Data tidak ditemukan"))
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  child: RepaintBoundary(
                    key: _invoiceKey,
                    child: InvoiceWidget(
                      booking: _booking!,
                      villaName: _villaName,
                      villaImage: _villaImage,
                      customerName: _customerName,
                      customerEmail: _customerEmail,
                    ),
                  ),
                ),

                if (_isGeneratingPdf)
                  Container(
                    color: Colors.black.withOpacity(0.4),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            "Membuat PDF...",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

      bottomNavigationBar: _booking == null
          ? null
          : Container(
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
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isGeneratingPdf ? null : _sharePdf,
                      icon: const Icon(Icons.share_outlined, size: 18),
                      label: const Text("Bagikan"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.navy,
                        side: const BorderSide(color: AppColors.navy),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const RiwayatBookingPage(),
                          ),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.history_rounded, size: 18),
                      label: const Text("Riwayat Booking"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
