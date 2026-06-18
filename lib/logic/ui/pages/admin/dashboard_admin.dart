import 'package:booking_villa/data/repositories/booking_repository.dart';
import 'package:booking_villa/data/repositories/villa_repository.dart';
import 'package:booking_villa/logic/bloc/auth/auth_bloc.dart';
import 'package:booking_villa/logic/bloc/auth/auth_event.dart';
import 'package:booking_villa/logic/bloc/auth/auth_state.dart';
import 'package:booking_villa/logic/bloc/booking/booking_bloc.dart';
import 'package:booking_villa/logic/bloc/booking/booking_event.dart';
import 'package:booking_villa/logic/bloc/stats/stats_bloc.dart';
import 'package:booking_villa/logic/bloc/stats/stats_event.dart';
import 'package:booking_villa/logic/bloc/stats/stats_state.dart';
import 'package:booking_villa/logic/bloc/villa/villa_bloc.dart';
import 'package:booking_villa/logic/bloc/villa/villa_event.dart';
import 'package:booking_villa/logic/ui/pages/admin/manage_booking/manage_booking.dart';
import 'package:booking_villa/logic/ui/pages/admin/manage_villa/manage_villa.dart';
import 'package:booking_villa/logic/ui/pages/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:booking_villa/logic/ui/components/colours.dart';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  @override
  void initState() {
    super.initState();
    context.read<AdminStatsBloc>().add(FetchAdminStats());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => LoginPage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/bookingVilla.png', 
                  width: 64,
                  height: 64,
                ),
                const SizedBox(width: 10),
                const Text(
                  "BookingVilla",
                  style: TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
              icon: const Icon(Icons.logout, color: AppColors.navy),
              tooltip: "Logout",
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Admin Central",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navygrey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "A consolidated view of your luxury estate operations.",
                      style: TextStyle(color: AppColors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

            
              BlocBuilder<AdminStatsBloc, AdminStatsState>(
                builder: (context, state) {
                  if (state is AdminStatsLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.navy),
                      ),
                    );
                  }

                  if (state is AdminStatsError) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.message,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => context
                                  .read<AdminStatsBloc>()
                                  .add(FetchAdminStats()),
                              child: const Text("Coba Lagi"),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is AdminStatsLoaded) {
                    final s = state.stats;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                         
                          _buildStatCard(
                            "TOTAL CUSTOMERS",
                            s.totalCustomers.toString(),
                            Icons.people_alt_outlined,
                            "${s.totalCustomers} users",
                            isDark: false,
                          ),
                          const SizedBox(height: 16),

                      
                          _buildStatCard(
                            "VILLA TERSEDIA",
                            s.villaAvailable.toString(),
                            Icons.domain_outlined,
                            "Available",
                            isDark: true,
                          ),
                          const SizedBox(height: 16),

                        
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "STATUS BOOKING",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.grey,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildMiniStatCard(
                                  "Confirmed",
                                  s.bookingConfirmed.toString(),
                                  Icons.check_circle_outline,
                                  Colors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildMiniStatCard(
                                  "Paid",
                                  s.bookingPaid.toString(),
                                  Icons.payments_outlined,
                                  Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildMiniStatCard(
                                  "Cancelled",
                                  s.bookingCancelled.toString(),
                                  Icons.cancel_outlined,
                                  Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),

              const SizedBox(height: 40),

  
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Management Menu",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navygrey,
                      ),
                    ),
                    const Text(
                      "Quick access to operational tools",
                      style: TextStyle(color: AppColors.grey),
                    ),
                    const SizedBox(height: 20),
                    _buildMenuItem(
                      Icons.home_work_outlined,
                      "Manage Villa",
                      "Edit listings and availability",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) =>
                                VillaBloc(repository: VillaRepository())
                                  ..add(FetchAllVillas()),
                            child: const ManageVillaPage(),
                          ),
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      Icons.book_online_outlined,
                      "Bookings",
                      "Process reservations and logs",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) =>
                                BookingBloc(BookingRepository())
                                  ..add(FetchAllBookingsEvent()),
                            child: const ManageBookingPage(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    String badge, {
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navy : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : AppColors.lightblue.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isDark ? Colors.white : AppColors.navy,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.blue.withOpacity(0.2)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: isDark ? Colors.blueAccent : const Color(0xFF2E7D32),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white70 : AppColors.grey,
              fontSize: 13,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.navy,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String subtitle, {
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.lightblue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.navy),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.navygrey,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: AppColors.grey),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
