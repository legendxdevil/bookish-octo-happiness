import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 4)
class UserModel extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String email;
  
  @HiveField(2)
  final String? displayName;
  
  @HiveField(3)
  final String? photoUrl;
  
  @HiveField(4)
  final bool isGoogleUser;
  
  @HiveField(5)
  final DateTime createdAt;
  
  @HiveField(6)
  final DateTime lastLoginAt;

  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isGoogleUser = false,
    required this.createdAt,
    required this.lastLoginAt,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isGoogleUser,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isGoogleUser: isGoogleUser ?? this.isGoogleUser,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        isGoogleUser,
        createdAt,
        lastLoginAt,
      ];
}
