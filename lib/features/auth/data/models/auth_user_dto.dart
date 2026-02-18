import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/auth_user.dart';

part 'auth_user_dto.g.dart';

@JsonSerializable()
class AuthUserDto extends AuthUser {
  const AuthUserDto({required super.id, required super.email});

  factory AuthUserDto.fromJson(Map<String, dynamic> json) =>
      _$AuthUserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AuthUserDtoToJson(this);
}
