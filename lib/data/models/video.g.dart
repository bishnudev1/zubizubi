// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VideoAdapter extends TypeAdapter<Video> {
  @override
  final int typeId = 1;

  @override
  Video read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Video(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      likes: (fields[3] as List).cast<dynamic>(),
      hideVideo: fields[4] as bool,
      videoUrl: fields[5] as String,
      created: fields[8] as String,
      creator: fields[6] as String,
      creatorUrl: fields[9] as String,
      creatorName: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Video obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.likes)
      ..writeByte(4)
      ..write(obj.hideVideo)
      ..writeByte(5)
      ..write(obj.videoUrl)
      ..writeByte(6)
      ..write(obj.creator)
      ..writeByte(7)
      ..write(obj.creatorName)
      ..writeByte(8)
      ..write(obj.created)
      ..writeByte(9)
      ..write(obj.creatorUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
