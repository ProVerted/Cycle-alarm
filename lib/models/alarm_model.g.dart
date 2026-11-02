// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlarmModelAdapter extends TypeAdapter<AlarmModel> {
  @override
  final int typeId = 0;

  @override
  AlarmModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlarmModel(
      id: fields[0] as String,
      label: fields[1] as String,
      hour: fields[2] as int,
      minute: fields[3] as int,
      cycleTotalDays: fields[4] as int,
      cycleOnDays: fields[5] as int,
      isEnabled: fields[6] as bool,
      weekendsCountTowardCycle: fields[7] as bool,
      skipWeekends: fields[8] as bool,
      cycleStartDate: fields[9] as DateTime,
      audioPath: fields[10] as String?,
      snoozeDurationMinutes: fields[11] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AlarmModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.hour)
      ..writeByte(3)
      ..write(obj.minute)
      ..writeByte(4)
      ..write(obj.cycleTotalDays)
      ..writeByte(5)
      ..write(obj.cycleOnDays)
      ..writeByte(6)
      ..write(obj.isEnabled)
      ..writeByte(7)
      ..write(obj.weekendsCountTowardCycle)
      ..writeByte(8)
      ..write(obj.skipWeekends)
      ..writeByte(9)
      ..write(obj.cycleStartDate)
      ..writeByte(10)
      ..write(obj.audioPath)
      ..writeByte(11)
      ..write(obj.snoozeDurationMinutes);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
