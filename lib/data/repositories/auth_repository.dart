import 'package:booking_villa/data/models/auth_request.dart';
import 'package:booking_villa/data/models/profiles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final _supabase = Supabase.instance.client;

  Future<ProfilesModel> login(AuthRequest request) async {
  try {
    final response = await _supabase.auth.signInWithPassword(
      email: request.email,
      password: request.password,
    );

    if (response.user == null) {
      throw Exception("Login gagal, coba lagi.");
    }

    final profileData = await _supabase
        .from('profiles')
        .select()
        .eq('id', response.user!.id)
        .single();

    return ProfilesModel.fromJson(profileData);

  } on AuthException catch (e) {
    final msg = e.message.toLowerCase();

    if (msg.contains('invalid login credentials')) {
      throw Exception('Email atau password salah. Periksa kembali.');
    } else if (msg.contains('email not confirmed')) {
      throw Exception('Email belum diverifikasi, cek inbox kamu.');
    } else if (msg.contains('too many requests')) {
      throw Exception('Terlalu banyak percobaan. Coba lagi nanti.');
    } else {
      throw Exception('Login gagal, coba lagi.');
    }
  } on PostgrestException catch (_) {
    throw Exception('Terjadi kesalahan koneksi, coba lagi.');
  }
}

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  Future<void> register(
    AuthRequest request,
    String nama,
    String notelp, {
    String? photoUrl, // ← tambah ini
  }) async {
    final response = await _supabase.auth.signUp(
      email: request.email,
      password: request.password,
    );

    if (response.user != null) {
      await _supabase.from('profiles').insert({
        'id': response.user!.id,
        'nama': nama,
        'notelp': notelp,
        'role': 'customer',
        'image': photoUrl ?? '', 
      });
    }
  }

  Future<bool> isLoggedIn() async {
    final user = _supabase.auth.currentUser;
    return user != null;
  }

  Future<ProfilesModel> getUser() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception("User belum login");
    }

    final profileData = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    return ProfilesModel.fromJson(profileData);
  }
}
