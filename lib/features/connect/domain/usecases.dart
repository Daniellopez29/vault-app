import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import 'entities.dart';
import 'repositories.dart';

class GetConnectStatusUseCase {
  final ConnectRepository repository;
  const GetConnectStatusUseCase(this.repository);

  Future<Either<Failure, ConnectStatusEntity>> call() => repository.getStatus();
}

class CreateOnboardingLinkParams {
  final String email;
  final String refreshUrl;
  final String returnUrl;

  const CreateOnboardingLinkParams({
    required this.email,
    required this.refreshUrl,
    required this.returnUrl,
  });
}

class CreateOnboardingLinkUseCase {
  final ConnectRepository repository;
  const CreateOnboardingLinkUseCase(this.repository);

  Future<Either<Failure, String>> call(CreateOnboardingLinkParams params) =>
      repository.createOnboardingLink(
        email: params.email,
        refreshUrl: params.refreshUrl,
        returnUrl: params.returnUrl,
      );
}
