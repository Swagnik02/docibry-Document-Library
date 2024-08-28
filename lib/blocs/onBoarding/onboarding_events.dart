import 'package:equatable/equatable.dart';

// Event to update the page index
class OnboardingPageChanged extends Equatable {
  final int pageIndex;

  OnboardingPageChanged(this.pageIndex);

  @override
  List<Object> get props => [pageIndex];
}
