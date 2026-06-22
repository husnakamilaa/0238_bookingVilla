import 'package:booking_villa/data/models/villa.dart';
import 'package:booking_villa/data/repositories/auth_repository.dart';
import 'package:booking_villa/data/repositories/booking_repository.dart';
import 'package:booking_villa/data/repositories/cart_repository.dart';
import 'package:booking_villa/data/repositories/profiles_repository.dart';
import 'package:booking_villa/data/repositories/stats_repository.dart';
import 'package:booking_villa/data/repositories/villa_repository.dart';
import 'package:booking_villa/logic/bloc/auth/auth_bloc.dart';
import 'package:booking_villa/logic/bloc/booking/booking_bloc.dart';
import 'package:booking_villa/logic/bloc/cart/cart_bloc.dart';
import 'package:booking_villa/logic/bloc/profiles/profiles_bloc.dart';
import 'package:booking_villa/logic/bloc/profiles/profiles_event.dart';
import 'package:booking_villa/logic/bloc/stats/stats_bloc.dart';
import 'package:booking_villa/logic/bloc/villa/villa_bloc.dart';
import 'package:booking_villa/logic/ui/components/colours.dart';
import 'package:booking_villa/logic/ui/pages/admin/dashboard_admin.dart';
import 'package:booking_villa/logic/ui/pages/admin/manage_villa/addVilla.dart';
import 'package:booking_villa/logic/ui/pages/admin/manage_villa/editVilla.dart';
import 'package:booking_villa/logic/ui/pages/admin/manage_villa/manage_villa.dart';
import 'package:booking_villa/logic/ui/pages/auth/login.dart';
import 'package:booking_villa/logic/ui/pages/auth/register.dart';
import 'package:booking_villa/logic/ui/pages/customer/dahsboard_customer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (_) => VillaRepository()),
        RepositoryProvider(create: (_) => ProfileRepository()),
        RepositoryProvider(create: (_) => BookingRepository()),
        RepositoryProvider(create: (_) => AdminStatsRepository()),
        RepositoryProvider(create: (_) => CartRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(context.read<AuthRepository>()),
          ),
          BlocProvider(
            // create: (context) => VillaBloc(repository: VillaRepository()),
            create: (context) => VillaBloc(repository: context.read<VillaRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                ProfileBloc(repository: context.read<ProfileRepository>())
                  ..add(FetchProfile()),
          ),
          BlocProvider(
            create: (context) => BookingBloc(context.read<BookingRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                AdminStatsBloc(context.read<AdminStatsRepository>()),
          ),
          BlocProvider(
          create: (context) => CartBloc(repository: context.read<CartRepository>()), 
        ),
        ],
        child: MaterialApp(
          title: 'Booking Villa',
          debugShowCheckedModeBanner: false,

          theme: ThemeData(
            primaryColor: AppColors.navy,
            scaffoldBackgroundColor: AppColors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.navy,
              foregroundColor: AppColors.white,
              elevation: 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          initialRoute: '/',
          routes: {
            '/': (context) => LoginPage(),
            '/register': (context) => RegisterPage(),
            '/customer_home': (context) => CustomerHome(),
            '/admin_dashboard': (context) => DashboardAdmin(),
            'manage_villa': (context) => ManageVillaPage(),
            '/add_villa': (context) => AddVillaPage(),
            '/edit_villa': (context) {
              final argVilla =
                  ModalRoute.of(context)!.settings.arguments as VillaModel;
              return EditVillaScreen(villa: argVilla);
            },
          },
        ),
      ),
    );
  }
}
