import 'package:expense_manager/constants/appcolor.dart';
import 'package:expense_manager/features/auth/bloc/auth_bloc.dart';
import 'package:expense_manager/features/auth/bloc/auth_event.dart';
import 'package:expense_manager/features/auth/bloc/auth_state.dart';
import 'package:expense_manager/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is OtpSentState) {
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("OTP: ${state.otp}"),
              duration: const Duration(seconds: 1), 
            ),
          );

      
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pushNamed(
              context,
              '/verifyOtp',
              arguments: state, 
            );
          });
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.msg)));
        }
      },

      child: Scaffold(
        backgroundColor: const Color(0xFF000000),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),

              
                  const Text(
                    "Get Started",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

              
                  const Text(
                    "Log In Using Phone & OTP",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 40),

                  CustomTextfield(
                    controller: phoneController,
                    hintText: "Phone",
                    keyboardType: TextInputType.phone,
                    showPrefix91: true, 
                  ),
                  const SizedBox(height: 30),

                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final loading = state is AuthLoading;

                      return GestureDetector(
                        onTap: loading
                            ? null
                            : () {
                                final rawPhone = phoneController.text.trim();

                                if (rawPhone.isEmpty || rawPhone.length < 10) {
                          
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Please enter a valid phone number",
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final phone = "+91$rawPhone";
                                context.read<AuthBloc>().add(
                                  SendOtpEvent(phone),
                                );
                              },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.primary,
                          ),
                          child: Center(
                            child: loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Continue",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
