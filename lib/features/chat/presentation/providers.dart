import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/crypto/rsa_encryption_service.dart';
import '../data/datasources.dart';
import '../data/repositories.dart';
import '../domain/encryption_service.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import '../domain/usecases.dart';

final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  return ChatRemoteDataSourceImpl(ref.read(apiClientProvider));
});

final encryptionServiceProvider = Provider<EncryptionService>((ref) => RsaEncryptionService());

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(
    remote: ref.read(chatRemoteDataSourceProvider),
    ws: ref.read(realtimeSocketProvider),
    encryption: ref.read(encryptionServiceProvider),
  );
});

final ensurePublicKeyRegisteredUseCaseProvider =
    Provider((ref) => EnsurePublicKeyRegisteredUseCase(ref.read(chatRepositoryProvider)));

final getConversationUseCaseProvider =
    Provider((ref) => GetConversationUseCase(ref.read(chatRepositoryProvider)));

final sendMessageUseCaseProvider =
    Provider((ref) => SendMessageUseCase(ref.read(chatRepositoryProvider)));

final getConversationsUseCaseProvider =
    Provider((ref) => GetConversationsUseCase(ref.read(chatRepositoryProvider)));

enum ConversationStatus { initial, loading, loaded, error }

class ConversationState {
  final ConversationStatus status;
  final List<MessageEntity> messages;
  final String? errorMessage;

  const ConversationState({
    this.status = ConversationStatus.initial,
    this.messages = const [],
    this.errorMessage,
  });

  ConversationState copyWith({
    ConversationStatus? status,
    List<MessageEntity>? messages,
    String? errorMessage,
  }) {
    return ConversationState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage,
    );
  }
}

/// Un controller por conversación (`.family` con el id del otro
/// participante). Carga el historial una vez y se suscribe al stream de
/// mensajes entrantes del repositorio, quedándose solo con los que vienen
/// de esta conversación.
final conversationControllerProvider =
    StateNotifierProvider.family<ConversationController, ConversationState, String>(
        (ref, otherUserId) {
  return ConversationController(
    otherUserId: otherUserId,
    repository: ref.read(chatRepositoryProvider),
    getConversation: ref.read(getConversationUseCaseProvider),
    sendMessage: ref.read(sendMessageUseCaseProvider),
  );
});

class ConversationController extends StateNotifier<ConversationState> {
  final String _otherUserId;
  final ChatRepository _repository;
  final GetConversationUseCase _getConversation;
  final SendMessageUseCase _sendMessage;
  StreamSubscription<MessageEntity>? _subscription;

  ConversationController({
    required String otherUserId,
    required ChatRepository repository,
    required GetConversationUseCase getConversation,
    required SendMessageUseCase sendMessage,
  })  : _otherUserId = otherUserId,
        _repository = repository,
        _getConversation = getConversation,
        _sendMessage = sendMessage,
        super(const ConversationState()) {
    _load();
    _subscription = _repository.incomingMessages().listen((message) {
      if (message.senderId != _otherUserId) return;
      state = state.copyWith(messages: [...state.messages, message]);
    });
  }

  Future<void> _load() async {
    state = state.copyWith(status: ConversationStatus.loading);
    final result = await _getConversation(_otherUserId);
    result.fold(
      (failure) => state = state.copyWith(
        status: ConversationStatus.error,
        errorMessage: failure.message,
      ),
      (messages) => state = state.copyWith(
        status: ConversationStatus.loaded,
        messages: messages,
      ),
    );
  }

  /// Envío optimista: el mensaje propio aparece de inmediato, sin esperar
  /// la respuesta del servidor.
  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final result = await _sendMessage(
      SendMessageParams(recipientId: _otherUserId, plainText: trimmed),
    );
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (message) => state = state.copyWith(messages: [...state.messages, message]),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

// ─── BANDEJA DE CONVERSACIONES ──────────────────────────────────────────────

enum ConversationsStatus { initial, loading, loaded, error }

class ConversationsState {
  final ConversationsStatus status;
  final List<ConversationSummaryEntity> conversations;
  final String? errorMessage;

  const ConversationsState({
    this.status = ConversationsStatus.initial,
    this.conversations = const [],
    this.errorMessage,
  });

  ConversationsState copyWith({
    ConversationsStatus? status,
    List<ConversationSummaryEntity>? conversations,
    String? errorMessage,
  }) {
    return ConversationsState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      errorMessage: errorMessage,
    );
  }
}

final conversationsControllerProvider =
    StateNotifierProvider<ConversationsController, ConversationsState>((ref) {
  return ConversationsController(
    repository: ref.read(chatRepositoryProvider),
    getConversations: ref.read(getConversationsUseCaseProvider),
  );
});

/// Carga la bandeja una vez y se refresca cada vez que llega un mensaje
/// nuevo por WebSocket (de cualquier conversación) -- así el orden y el
/// contador de no leídos se mantienen al día sin que el usuario haga pull
/// to refresh manualmente.
class ConversationsController extends StateNotifier<ConversationsState> {
  final ChatRepository _repository;
  final GetConversationsUseCase _getConversations;
  StreamSubscription<MessageEntity>? _subscription;

  ConversationsController({
    required ChatRepository repository,
    required GetConversationsUseCase getConversations,
  })  : _repository = repository,
        _getConversations = getConversations,
        super(const ConversationsState()) {
    load();
    _subscription = _repository.incomingMessages().listen((_) => load());
  }

  Future<void> load() async {
    state = state.copyWith(status: ConversationsStatus.loading);
    final result = await _getConversations();
    result.fold(
      (failure) => state = state.copyWith(
        status: ConversationsStatus.error,
        errorMessage: failure.message,
      ),
      (conversations) => state = state.copyWith(
        status: ConversationsStatus.loaded,
        conversations: conversations,
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
