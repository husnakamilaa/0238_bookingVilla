import 'package:booking_villa/data/models/stats.dart';

abstract class AdminStatsState {}
 
class AdminStatsInitial extends AdminStatsState {}
 
class AdminStatsLoading extends AdminStatsState {}
 
class AdminStatsLoaded extends AdminStatsState {
  final AdminStatsModel stats;
  AdminStatsLoaded(this.stats);
}
 
class AdminStatsError extends AdminStatsState {
  final String message;
  AdminStatsError(this.message);
}