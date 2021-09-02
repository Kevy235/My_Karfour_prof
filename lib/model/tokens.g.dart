// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tokens.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tokens _$TokensFromJson(Map<String, dynamic> json) {
  return Tokens(
    json['token_type'] as String,
    json['access_token'] as String,
    json['refresh_token'] as String,
    json['expires_in'] as int,
  );
}

Map<String, dynamic> _$TokensToJson(Tokens instance) => <String, dynamic>{
      'token_type': instance.tokenType,
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'expires_in': instance.expiresIn,
    };
