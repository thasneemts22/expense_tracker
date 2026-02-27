import 'package:expense_manager/constants/appcolor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  Widget navItem(String svgPath, int index) {
    bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: SvgPicture.asset(
          svgPath,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            isActive ? Colors.white : Colors.white54,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 60, right: 60, bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          navItem('assets/icons/pie.svg', 0),
          navItem('assets/icons/swap.svg', 1),
          navItem('assets/icons/user.svg', 2),
        ],
      ),
    );
  }
}
