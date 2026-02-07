// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatMessageModelAdapter extends TypeAdapter<ChatMessageModel> {
  @override
  final int typeId = 6;

  @override
  ChatMessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatMessageModel(
      id: fields[0] as String,
      content: fields[1] as String,
      sender: fields[2] as MessageSender,
      timestamp: fields[3] as DateTime,
      isTyping: fields[4] as bool,
      suggestedActions: (fields[5] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ChatMessageModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.sender)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.isTyping)
      ..writeByte(5)
      ..write(obj.suggestedActions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageSenderAdapter extends TypeAdapter<MessageSender> {
  @override
  final int typeId = 5;

  @override
  MessageSender read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageSender.user;
      case 1:
        return MessageSender.ai;
      default:
        return MessageSender.user;
    }
  }

  @override
  void write(BinaryWriter writer, MessageSender obj) {
    switch (obj) {
      case MessageSender.user:
        writer.writeByte(0);
        break;
      case MessageSender.ai:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageSenderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
