// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 7;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsModel(
      geminiApiKey: fields[0] as String?,
      themeMode: fields[1] as String,
      currency: fields[2] as String,
      defaultPaymentMethod: fields[3] as String?,
      notificationsEnabled: fields[4] as bool,
      privacyMode: fields[5] as bool,
      dateFormat: fields[6] as String,
      aiTipsEnabled: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.geminiApiKey)
      ..writeByte(1)
      ..write(obj.themeMode)
      ..writeByte(2)
      ..write(obj.currency)
      ..writeByte(3)
      ..write(obj.defaultPaymentMethod)
      ..writeByte(4)
      ..write(obj.notificationsEnabled)
      ..writeByte(5)
      ..write(obj.privacyMode)
      ..writeByte(6)
      ..write(obj.dateFormat)
      ..writeByte(7)
      ..write(obj.aiTipsEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
