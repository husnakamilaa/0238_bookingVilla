import 'package:booking_villa/data/models/auth_request.dart';
import 'package:booking_villa/logic/bloc/auth/auth_bloc.dart';
import 'package:booking_villa/logic/bloc/auth/auth_event.dart';
import 'package:booking_villa/logic/bloc/auth/auth_state.dart';
import 'package:booking_villa/logic/ui/components/colours.dart';
import 'package:booking_villa/logic/ui/components/custom_textfield.dart';
import 'package:booking_villa/logic/ui/components/formatter.dart';
import 'package:booking_villa/logic/ui/components/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final notelpController = TextEditingController();

  String? photoUrl;

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    passwordController.dispose();
    notelpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text("Register", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.navy,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitial) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Berhasil Daftar!"),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),

                CustomImagePicker(
                    storageBucket: 'profile_photo',
                    shape: ImagePickerShape.circle,
                    onImageUploaded: (url) {
                      setState(() => photoUrl = url);
                    },
                  ),

                const SizedBox(height: 24),

                CustomTextField(
                    controller: namaController,
                    label: "Nama Lengkap",
                    icon: Icons.person_outline,
                   
                  ),

                  CustomTextField(
                    controller: notelpController,
                    label: "No. Telepon",
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [PhoneInputFormatter(maxDigits: 13)],
                  validator: (value) {
                    if (value == null || value.length < 10) {
                      return 'Nomor HP minimal 10 digit';
                    }
                    return null;
                  },
                    
                  ),

                  CustomTextField(
                    controller: emailController,
                    label: "Email",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: AppValidators.email, 
                  ),

                  CustomTextField(
                    controller: passwordController,
                    label: "Password",
                    icon: Icons.lock_outline,
                    isObscure: true, 
                    validator: AppValidators.password, 
                  ),

                const SizedBox(height: 24),

                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return const CircularProgressIndicator(
                        color: AppColors.navy,
                      );
                    }
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()){
                          context.read<AuthBloc>().add(
                          RegisterRequested(
                            AuthRequest(
                              email: emailController.text.trim(),
                              password: passwordController.text,
                            ),
                            namaController.text.trim(),
                            notelpController.text.trim(),
                            photoUrl: photoUrl, // ← kirim URL foto
                          ),
                        );
                        }
                      },
                      child: const Text(
                        "DAFTAR SEKARANG",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }
}