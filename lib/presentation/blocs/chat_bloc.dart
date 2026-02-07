import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/failures.dart';
import '../../data/models/chat_message_model.dart';
import '../../services/ai_service.dart';
import '../../services/storage_service.dart';

// Events
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatHistory extends ChatEvent {}

class SendMessage extends ChatEvent {
  final String message;

  const SendMessage({required this.message});

  @override
  List<Object?> get props => [message];
}

class ClearChat extends ChatEvent {}

// States
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessageModel> messages;

  const ChatLoaded({required this.messages});

  @override
  List<Object?> get props => [messages];
}

class ChatError extends ChatState {
  final String message;

  const ChatError({required this.message});

  @override
  List<Object?> get props => [message];
}

class MessageSent extends ChatState {}

// BLoC
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final StorageService _storageService;
  final AIService _aiService;

  ChatBloc({
    required StorageService storageService,
    required AIService aiService,
  })  : _storageService = storageService,
        _aiService = aiService,
        super(ChatInitial()) {
    on<LoadChatHistory>(_onLoadChatHistory);
    on<SendMessage>(_onSendMessage);
    on<ClearChat>(_onClearChat);
  }

  Future<void> _onLoadChatHistory(
    LoadChatHistory event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      final messages = _storageService.getAllChatMessages();
      emit(ChatLoaded(messages: messages));
    } catch (e) {
      emit(ChatError(message: 'Failed to load chat history'));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // Add user message
      final userMessage = ChatMessageModel.create(
        content: event.message,
        sender: MessageSender.user,
      );
      await _storageService.saveChatMessage(userMessage);

      // Show typing indicator
      final currentMessages = _storageService.getAllChatMessages();
      emit(ChatLoaded(
        messages: [...currentMessages, ChatMessageModel.typing()],
      ));

      if (!_aiService.isConfigured) {
        // Remove typing indicator and add error message
        final errorMessage = ChatMessageModel.create(
          content: 'Please configure your Gemini API key in Settings to use the AI assistant.',
          sender: MessageSender.ai,
        );
        await _storageService.saveChatMessage(errorMessage);
        
        final updatedMessages = _storageService.getAllChatMessages();
        emit(ChatLoaded(messages: updatedMessages));
        return;
      }

      // Get AI response
      final context = currentMessages
          .where((m) => !m.isTyping)
          .map((m) => {
                'role': m.sender == MessageSender.user ? 'user' : 'model',
                'content': m.content,
              })
          .toList();

      final aiResponse = await _aiService.chatWithAI(
        message: event.message,
        context: context,
      );

      // Add AI response
      final aiMessage = ChatMessageModel.create(
        content: aiResponse,
        sender: MessageSender.ai,
      );
      await _storageService.saveChatMessage(aiMessage);

      final updatedMessages = _storageService.getAllChatMessages();
      emit(ChatLoaded(messages: updatedMessages));
    } on AIServiceFailure catch (e) {
      final errorMessage = ChatMessageModel.create(
        content: 'Sorry, I encountered an error: ${e.message}',
        sender: MessageSender.ai,
      );
      await _storageService.saveChatMessage(errorMessage);
      
      final updatedMessages = _storageService.getAllChatMessages();
      emit(ChatLoaded(messages: updatedMessages));
    } catch (e) {
      final errorMessage = ChatMessageModel.create(
        content: 'Sorry, I encountered an unexpected error. Please try again.',
        sender: MessageSender.ai,
      );
      await _storageService.saveChatMessage(errorMessage);
      
      final updatedMessages = _storageService.getAllChatMessages();
      emit(ChatLoaded(messages: updatedMessages));
    }
  }

  Future<void> _onClearChat(
    ClearChat event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _storageService.clearChatHistory();
      emit(const ChatLoaded(messages: []));
    } catch (e) {
      emit(ChatError(message: 'Failed to clear chat'));
    }
  }
}
