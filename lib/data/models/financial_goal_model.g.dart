// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_goal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FinancialGoalModelAdapter extends TypeAdapter<FinancialGoalModel> {
  @override
  final int typeId = 3;

  @override
  FinancialGoalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FinancialGoalModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      targetAmount: fields[3] as double,
      currentAmount: fields[4] as double,
      deadline: fields[5] as DateTime,
      createdAt: fields[6] as DateTime,
      status: fields[7] as GoalStatus,
      aiPlan: fields[8] as String?,
      milestones: (fields[9] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, FinancialGoalModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.targetAmount)
      ..writeByte(4)
      ..write(obj.currentAmount)
      ..writeByte(5)
      ..write(obj.deadline)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.aiPlan)
      ..writeByte(9)
      ..write(obj.milestones);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinancialGoalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalStatusAdapter extends TypeAdapter<GoalStatus> {
  @override
  final int typeId = 2;

  @override
  GoalStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GoalStatus.active;
      case 1:
        return GoalStatus.completed;
      case 2:
        return GoalStatus.paused;
      default:
        return GoalStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, GoalStatus obj) {
    switch (obj) {
      case GoalStatus.active:
        writer.writeByte(0);
        break;
      case GoalStatus.completed:
        writer.writeByte(1);
        break;
      case GoalStatus.paused:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
