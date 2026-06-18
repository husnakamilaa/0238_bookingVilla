import 'package:booking_villa/data/repositories/stats_repository.dart';
import 'package:booking_villa/logic/bloc/stats/stats_event.dart';
import 'package:booking_villa/logic/bloc/stats/stats_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminStatsBloc extends Bloc<AdminStatsEvent, AdminStatsState> {
  final AdminStatsRepository repository;
 
  AdminStatsBloc(this.repository) : super(AdminStatsInitial()) {
    on<FetchAdminStats>((event, emit) async {
      emit(AdminStatsLoading());
      try {
        final stats = await repository.fetchStats();
        emit(AdminStatsLoaded(stats));
      } catch (e) {
        emit(AdminStatsError("Gagal memuat statistik: $e"));
      }
    });
  }
}