import 'package:expense_manager/constants/appcolor.dart';
import 'package:expense_manager/features/auth/bloc/auth_bloc.dart';
import 'package:expense_manager/features/auth/bloc/auth_event.dart';
import 'package:expense_manager/features/auth/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final List<TextEditingController> controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  int secondsRemaining = 32;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      print("ModalRoute.arguments: $args"); 

      if (args == null) {
        print(" Arguments are null! OTP cannot be shown");
        return;
      }

      final otpState = args as OtpSentState;
      print("OTP received from Bloc: ${otpState.otp}");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("OTP: ${otpState.otp}")));
    });
    startTimer();
  }

  bool _filled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_filled) return;

    final args = ModalRoute.of(context)!.settings.arguments as OtpSentState;

    for (int i = 0; i < args.otp.length && i < 6; i++) {
      controllers[i].text = args.otp[i];
    }

    _filled = true;
  }

  Timer? _timer;

  void startTimer() {
    _timer?.cancel(); 
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (secondsRemaining > 0) {
        setState(() => secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget otpBox(int index) {
    return Container(
      width: 50, 
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: TextField(
        controller: controllers[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as OtpSentState;
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
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

          
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  "Verify OTP",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                    children: [
                      const TextSpan(text: "Enter the 6-Digit code sent to "),
                      TextSpan(
                        text: args.phone,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    "Change Number",
                    style: TextStyle(
                      color:AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

            
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) => otpBox(index)),
                ),

                const SizedBox(height: 30),

                GestureDetector(
                  onTap: () {
                    final args =
                        ModalRoute.of(context)!.settings.arguments
                            as OtpSentState;

                    if (args.userExists) {
            
                      Navigator.pushReplacementNamed(context, '/home');
                    } else {
                
                      Navigator.pushReplacementNamed(
                        context,
                        '/name',
                        arguments: args.phone,
                      );
                    }
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.primary,
                    ),
                    child: const Center(
                      child: Text(
                        "Verify",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: secondsRemaining == 0
                      ? () {
                          final args =
                              ModalRoute.of(context)!.settings.arguments
                                  as OtpSentState;

                          context.read<AuthBloc>().add(
                            SendOtpEvent(args.phone),
                          );

                          setState(() {
                            secondsRemaining = 32;
                          });
                          startTimer();
                        }
                      : null,
                  child: Text(
                    secondsRemaining > 0
                        ? "Resend OTP in ${secondsRemaining}s"
                        : "Resend OTP",
                    style: TextStyle(
                      color: secondsRemaining > 0
                          ? Colors.white54
                          : Colors.white,
                      fontSize: 14,
                      fontWeight: secondsRemaining > 0
                          ? FontWeight.normal
                          : FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
