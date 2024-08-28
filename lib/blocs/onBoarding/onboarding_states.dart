import 'package:equatable/equatable.dart';

class OnboardingStates extends Equatable {
  final int pageIndex;

  OnboardingStates({this.pageIndex = 0});

  @override
  List<Object> get props => [pageIndex];

  OnboardingStates copyWith({int? pageIndex}) {
    return OnboardingStates(
      pageIndex: pageIndex ?? this.pageIndex,
    );
  }
}
