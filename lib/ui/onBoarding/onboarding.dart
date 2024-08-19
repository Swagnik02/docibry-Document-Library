import 'package:docibry/blocs/onBoarding/onboarding_bloc.dart';
import 'package:docibry/blocs/onBoarding/onboarding_events.dart';
import 'package:docibry/blocs/onBoarding/onboarding_states.dart';
import 'package:docibry/ui/home/home_page.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Onboarding extends StatelessWidget {
  final PageController controller = PageController(initialPage: 0);
  Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color.fromRGBO(34, 31, 30, 1),
      body: BlocBuilder<OnboardingBloc, OnboardingStates>(
        builder: (context, state) {
          return Stack(
            alignment: Alignment.center,
            children: [
              PageView(
                controller: controller,
                onPageChanged: (value) {
                  state.pageIndex = value;
                  BlocProvider.of<OnboardingBloc>(context)
                      .add(OnboardingEvents());
                },
                children: [
                  _page(
                    context: context,
                    pageIndex: 0,
                    imageUrl: 'assets/images/page1.png',
                    title: 'Boost Productivity',
                    desc:
                        'Elevate your productivity to new heights and grow with us',
                  ),
                  _page(
                    context: context,
                    pageIndex: 1,
                    imageUrl: 'assets/images/page2.png',
                    title: 'Work Seamlessly',
                    desc: 'Get your work done seamlessly without interruption',
                  ),
                  _page(
                    context: context,
                    pageIndex: 2,
                    imageUrl: 'assets/images/page3.png',
                    title: 'Achieve Higher Goals',
                    desc:
                        'By boosting your producivity we help you achieve higher goals',
                  ),
                ],
              ),
              Positioned(
                bottom: 150,
                child: DotsIndicator(
                  dotsCount: 3,
                  position:
                      BlocProvider.of<OnboardingBloc>(context).state.pageIndex,
                  decorator: DotsDecorator(
                    color: Colors.white.withOpacity(0.2),
                    activeColor: Colors.white,
                    size: const Size.square(9.0),
                    activeSize: const Size(36.0, 9.0),
                    activeShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _page({
    required pageIndex,
    required imageUrl,
    required title,
    required desc,
    required BuildContext context,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Image.asset(
        //   imageUrl,
        // ),
        const SizedBox(height: 40),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 50,
          ),
          child: Text(
            desc,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        const SizedBox(height: 120),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            mainAxisAlignment: pageIndex == 2
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
            children: [
              Visibility(
                visible: pageIndex != 2,
                child: OutlinedButton(
                  onPressed: () => _toHome(context),
                  child: const Text(
                    'Skip',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              pageIndex == 2
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 1,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        pageIndex == 2
                            ? _toHome(context)
                            : controller.animateToPage(pageIndex + 1,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.decelerate);
                      },
                      child: const Text(
                        'Get Started',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : FilledButton(
                      onPressed: () {
                        pageIndex == 2
                            ? _toHome(context)
                            : controller.animateToPage(
                                pageIndex + 1,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.decelerate,
                              );
                      },
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                      ),
                    ),
            ],
          ),
        )
      ],
    );
  }

  void _toHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
      (Route<dynamic> route) => false,
    );
  }
}
