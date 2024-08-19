import 'package:docibry/blocs/onBoarding/onboarding_events.dart';
import 'package:docibry/blocs/onBoarding/onboarding_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardingBloc extends Bloc<OnboardingEvents, OnboardingStates> {
  OnboardingBloc() : super(OnboardingStates()) {
    on<OnboardingEvents>((event, emit) {
      return emit(OnboardingStates(pageIndex: state.pageIndex));
    });
  }
}
