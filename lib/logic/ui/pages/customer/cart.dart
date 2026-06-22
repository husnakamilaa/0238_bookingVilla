import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:booking_villa/logic/bloc/cart/cart_bloc.dart';
import 'package:booking_villa/logic/bloc/cart/cart_event.dart';
import 'package:booking_villa/logic/bloc/cart/cart_state.dart';
import 'package:booking_villa/logic/ui/components/colours.dart';
import 'package:booking_villa/logic/ui/components/custom_card.dart';
import 'package:booking_villa/logic/ui/pages/customer/bookingVilla.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();

    context.read<CartBloc>().add(FetchCartItems());
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Keranjang Saya"),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state is CartError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.navy),
            );
          } else if (state is CartLoaded) {
            if (state.cartItems.isEmpty) {
              return const Center(
                child: Text("Belum ada villa di keranjang kamu."),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: state.cartItems.length,
              itemBuilder: (context, index) {
                final item = state.cartItems[index];
                final villa = item.villa;

                if (villa == null) return const SizedBox();

                return CustomCard(
                  imageUrl: villa.image,
                  title: villa.namaVilla,
                  subtitle: "${currencyFormatter.format(villa.price)} / malam",
       
                  badge: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Label Status Villa
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lightblue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          villa.statusAvailable,
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                
                      GestureDetector(
                        onTap: () {
                          context.read<CartBloc>().add(
                            DeleteCartItemEvent(item.id!),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(right: 4.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Hapus",
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingPage(villa: villa),
                      ),
                    );
                  },
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
