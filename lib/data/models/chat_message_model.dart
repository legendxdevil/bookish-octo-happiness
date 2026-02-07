import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'chat_message_model.g.dart';

@HiveType(typeId: 5)
enum MessageSender {
  @HiveField(0)
  user,
  @HiveField(1)
  ai,
}

@HiveType(typeId: 6)
class ChatMessageModel extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String content;
  
  @HiveField(2)
  final MessageSender sender;
  
  @HiveField(3)
  final DateTime timestamp;
  
  @HiveField(4)
  final bool isTyping;
  
  @HiveField(5)
  final List<String>? suggestedActions;

  const ChatMessageModel({
    required this.id,
    required this.content,
    required this.sender,
    required this.timestamp,
    this.isTyping = false,
    this.suggestedActions,
  });

  factory ChatMessageModel.create({
    required String content,
    required MessageSender sender,
    List<String>? suggestedActions,
  }) {
    return ChatMessageModel(
      id: const Uuid().v4(),
      content: content,
      sender: sender,
      timestamp: DateTime.now(),
      suggestedActions: suggestedActions,
    );
  }

  factory ChatMessageModel.typing() {
    return ChatMessageModel(
      id: const Uuid().v4(),
      content: '',
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
      isTyping: true,
    );
  }

  ChatMessageModel copyWith({
    String? id,
    String? content,
    MessageSender? sender,
    DateTime? timestamp,
    bool? isTyping,
    List<String>? suggestedActions,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      isTyping: isTyping ?? this.isTyping,
      suggestedActions: suggestedActions ?? this.suggestedActions,
    );
  }

  @override
  List<Object?> get props => [
        id,
        content,
        sender,
        timestamp,
        isTyping,
        suggestedActions,
      ];
}
