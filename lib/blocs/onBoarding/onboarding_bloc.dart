import 'package:flutter_bloc/flutter_bloc.dart';
import 'onboarding_events.dart';
import 'onboarding_states.dart';

class OnboardingBloc extends Bloc<OnboardingPageChanged, OnboardingStates> {
  OnboardingBloc() : super(OnboardingStates()) {
    on<OnboardingPageChanged>((event, emit) {
      emit(state.copyWith(pageIndex: event.pageIndex));
    });
  }
}
