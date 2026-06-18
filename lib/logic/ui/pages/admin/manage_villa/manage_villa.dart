import 'package:booking_villa/logic/ui/components/custom_card.dart';
import 'package:booking_villa/logic/ui/components/search_bar.dart';
import 'package:booking_villa/logic/ui/pages/admin/manage_villa/detailVilla.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:booking_villa/logic/ui/components/colours.dart';
import 'package:booking_villa/logic/bloc/villa/villa_bloc.dart';
import 'package:booking_villa/logic/bloc/villa/villa_event.dart';
import 'package:booking_villa/logic/bloc/villa/villa_state.dart';
import 'package:booking_villa/data/models/villa.dart';

class ManageVillaPage extends StatefulWidget {
  const ManageVillaPage({super.key});

  @override
  State<ManageVillaPage> createState() => _ManageVillaPageState();
}

class _ManageVillaPageState extends State<ManageVillaPage> {
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          "Manage Villa",
          style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.navy),
      ),
      body: BlocListener<VillaBloc, VillaState>(
        listener: (context, state) {
          if (state is VillaError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Column(
          children: [
            CustomSearchBar(
              hintText: "Search villa name...",
              onChanged: (query) {
                context.read<VillaBloc>().add(SearchVillaEvent(query));
              },
            ),
            _buildFilterChips(),
            const SizedBox(height: 20),
            _buildVillaList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.navy,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.pushNamed(context, '/add_villa');
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'available', 'Unavailable'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: filters.map((status) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              label: Text(status),
              selected: selectedFilter == status,
              onSelected: (bool selected) {
                setState(() {
                  selectedFilter = status;
                  context.read<VillaBloc>().add(FilterVillaStatusEvent(status));
                });
              },
              selectedColor: AppColors.lightblue,
              checkmarkColor: AppColors.navy,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVillaList() {
    return Expanded(
      child: BlocBuilder<VillaBloc, VillaState>(
        builder: (context, state) {
          if (state is VillaLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.navy),
            );
          } else if (state is VillaLoaded) {
            if (state.villas.isEmpty)
              return const Center(child: Text("No villa found."));
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: state.villas.length,
              itemBuilder: (context, index) =>
                  _buildVillaCard(state.villas[index]),
            );
          } else if (state is VillaError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildVillaCard(VillaModel villa) {
    bool isAvailable = villa.statusAvailable == 'available';
    return CustomCard(
    imageUrl: villa.image,
    title: villa.namaVilla,
    subtitle: "Rp ${villa.price}",
    badge: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (isAvailable ? Colors.green : Colors.red).withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        villa.statusAvailable,
        style: TextStyle(
          color: isAvailable ? Colors.green : Colors.red,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailVillaScreen(villa: villa)),
      );
    },
  );
  }
}
