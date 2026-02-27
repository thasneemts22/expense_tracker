import 'package:expense_manager/constants/appcolor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  final List<Map<String, String>> pages = [
    {
      "image": "assets/images/onboard.png",
      "title": "Privacy by Default, With Zero Ads or Hidden Tracking",
      "subtitle": "No ads. No trackers. No third-party analytics.",
    },
    {
      "image": "assets/images/onboard.png",
      "title": "Insights That Help You Spend Better Without Complexity",
      "subtitle": "See category-wise spending, recent activity.",
    },
    {
      "image": "assets/images/onboard.png",
      "title": "Local-First Tracking That Stays Fully On Your Device",
      "subtitle": "Your finances stay on your phone.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light, 
          statusBarBrightness: Brightness.light,
        ),

        child: Stack(
          children: [
      
            Positioned.fill(
              child: Image.asset(
                "assets/images/onboard.png",
                fit: BoxFit.cover,
              ),
            ),

            
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54, Colors.black],
                  ),
                ),
              ),
            ),

            
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 200, 
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: pages.length,
                    onPageChanged: (index) {
                      setState(() => currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                    
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                pages.length,
                                (i) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  height: 4,
                                  width: 105,
                                  decoration: BoxDecoration(
                                    color: currentPage == i
                                        ? Colors.white
                                        : Colors.white24,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            Text(
                              pages[index]["title"]!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Text(
                              pages[index]["subtitle"]!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),

                            const Spacer(),

                            Row(
                              children: [
                                if (index != 0)
                                  GestureDetector(
                                    onTap: () {
                                      _controller.previousPage(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                    child: SvgPicture.asset(
                                      "assets/icons/arrow.svg",
                                      width: 50,
                                      height: 50,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ), 
                                    ),
                                  ),

                                const SizedBox(width: 8),

                                Expanded(
                                  child: SizedBox(
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (index == pages.length - 1) {
                                          Navigator.pushReplacementNamed(
                                            context,
                                            '/phone',
                                          );
                                        } else {
                                          _controller.nextPage(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            curve: Curves.easeInOut,
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        index == pages.length - 1
                                            ? "Get Started"
                                            : "Next",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

          
            Positioned(
              top: 50,
              right: 20,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/phone');
                },
                child: const Text(
                  "SKIP",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
