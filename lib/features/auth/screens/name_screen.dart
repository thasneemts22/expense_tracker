import 'package:expense_manager/constants/appcolor.dart';
import 'package:expense_manager/features/auth/bloc/auth_bloc.dart';
import 'package:expense_manager/features/auth/bloc/auth_event.dart';
import 'package:expense_manager/features/auth/bloc/auth_state.dart';
import 'package:expense_manager/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final TextEditingController nameController = TextEditingController();
  bool isValid = false;

  @override
  void initState() {
    super.initState();
    nameController.addListener(() {
      setState(() {
        isValid = nameController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.pushReplacementNamed(context, '/home');
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.msg)));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
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
                    "👋 What should we call you?",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "This name stays only on your device.",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),

                  const SizedBox(height: 40),

                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomTextfield(
                      controller: nameController,
                      hintText: "Eg: Johnnie",
                      keyboardType: TextInputType.name,
                      suffixIcon: isValid
                          ? const Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                            )
                          : null,
                    ),
                  ),

                  const SizedBox(height: 30),

                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final loading = state is AuthLoading;

                      return GestureDetector(
                        onTap: (!isValid || loading)
                            ? null
                            : () {
                                final phone =
                                    ModalRoute.of(context)!.settings.arguments
                                        as String;

                                context.read<AuthBloc>().add(
                                  CreateAccountEvent(
                                    phone,
                                    nameController.text.trim(),
                                  ),
                                );
                              },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: isValid
                                ? AppColors.primary
                                : const Color(0xFF2A2A2C),
                          ),
                          child: Center(
                            child: loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    "Continue",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isValid
                                          ? Colors.white
                                          : Colors.white38,
                                    ),
                                  ),
                          ),
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
