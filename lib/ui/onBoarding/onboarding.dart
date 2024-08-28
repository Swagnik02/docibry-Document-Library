import 'package:docibry/blocs/onBoarding/onboarding_bloc.dart';
import 'package:docibry/blocs/onBoarding/onboarding_events.dart';
import 'package:docibry/blocs/onBoarding/onboarding_states.dart';
import 'package:docibry/ui/Auth/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Onboarding extends StatelessWidget {
  final PageController controller = PageController(initialPage: 0);

  Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<OnboardingBloc, OnboardingStates>(
        builder: (context, state) {
          return Stack(
            alignment: Alignment.center,
            children: [
              PageView(
                controller: controller,
                onPageChanged: (value) {
                  BlocProvider.of<OnboardingBloc>(context)
                      .add(OnboardingPageChanged(value));
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
                        'By boosting your productivity we help you achieve higher goals',
                  ),
                ],
              ),
              Positioned(
                bottom: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: state.pageIndex == index ? 30 : 8,
                      height: 8,
                      margin: const EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    );
                  }),
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
        const SizedBox(height: 40),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
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
                        _toHome(context);
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
                        controller.nextPage(
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
        ),
      ],
    );
  }

  void _toHome(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthPage(),
      ),
    );
  }
}
