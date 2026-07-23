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

/// Una sola instancia por sesión de la app -- mantiene una única conexión
/// WebSocket compartida entre todas las conversaciones que se abran.
final chatWebSocketDataSourceProvider = Provider<ChatWebSocketDataSource>((ref) {
  return ChatWebSocketDataSource(ref.read(apiClientProvider));
});

final encryptionServiceProvider = Provider<EncryptionService>((ref) => RsaEncryptionService());

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(
    remote: ref.read(chatRemoteDataSourceProvider),
    ws: ref.read(chatWebSocketDataSourceProvider),
    encryption: ref.read(encryptionServiceProvider),
  );
});

final ensurePublicKeyRegisteredUseCaseProvider =
    Provider((ref) => EnsurePublicKeyRegisteredUseCase(ref.read(chatRepositoryProvider)));

final getConversationUseCaseProvider =
    Provider((ref) => GetConversationUseCase(ref.read(chatRepositoryProvider)));

final sendMessageUseCaseProvider =
    Provider((ref) => SendMessageUseCase(ref.read(chatRepositoryProvider)));

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
