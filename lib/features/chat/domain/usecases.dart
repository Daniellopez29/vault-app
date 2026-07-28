import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import 'entities.dart';
import 'repositories.dart';

class EnsurePublicKeyRegisteredUseCase {
  final ChatRepository repository;
  const EnsurePublicKeyRegisteredUseCase(this.repository);

  Future<Either<Failure, void>> call(String userId) =>
      repository.ensurePublicKeyRegistered(userId);
}

class GetConversationUseCase {
  final ChatRepository repository;
  const GetConversationUseCase(this.repository);

  Future<Either<Failure, List<MessageEntity>>> call(String otherUserId) =>
      repository.getConversation(otherUserId);
}

class GetConversationsUseCase {
  final ChatRepository repository;
  const GetConversationsUseCase(this.repository);

  Future<Either<Failure, List<ConversationSummaryEntity>>> call() =>
      repository.getConversations();
}

class SendMessageUseCase {
  final ChatRepository repository;
  const SendMessageUseCase(this.repository);

  Future<Either<Failure, MessageEntity>> call(SendMessageParams params) =>
      repository.sendMessage(recipientId: params.recipientId, plainText: params.plainText);
}

class SendMessageParams {
  final String recipientId;
  final String plainText;

  const SendMessageParams({required this.recipientId, required this.plainText});
}

class MarkMessagesAsReadUseCase {
  final ChatRepository repository;
  const MarkMessagesAsReadUseCase(this.repository);

  Future<Either<Failure, void>> call(List<String> messageIds) =>
      repository.markMessagesAsRead(messageIds);
}
