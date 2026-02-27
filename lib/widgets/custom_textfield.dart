import 'package:expense_manager/constants/appcolor.dart';
import 'package:flutter/material.dart';

class CustomTextfield extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool showPrefix91;
  final Widget? suffixIcon;

  const CustomTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.showPrefix91 = false,
    this.suffixIcon,
  });

  @override
  State<CustomTextfield> createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: TextField(
        focusNode: _focusNode,
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        cursorColor: AppColors.primary,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),

          prefixIcon: widget.showPrefix91
              ? Padding(
                  padding: const EdgeInsets.only(left: 12, right: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        "+91",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text("|", style: TextStyle(color: Colors.white38)),
                      SizedBox(width: 6),
                    ],
                  ),
                )
              : null,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),

          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Colors.white54),

          suffixIcon: widget.suffixIcon,
        ),
        onTap: () => setState(() {}),
        onEditingComplete: () => setState(() {}),
      ),
    );
  }
}
