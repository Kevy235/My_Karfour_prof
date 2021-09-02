import 'package:json_annotation/json_annotation.dart';

part 'tokens.g.dart';

@JsonSerializable()
class Tokens {
  @JsonKey(name: 'token_type')
  final String tokenType;

  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  @JsonKey(name: 'expires_in')
  final int expiresIn;

  Tokens(
    this.tokenType,
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
  );

  factory Tokens.fromJson(Map<String, dynamic> json) => _$TokensFromJson(json);

  Map<String, dynamic> toJson() => _$TokensToJson(this);

  bool get isValid =>
      accessToken != null && refreshToken != null && tokenType != null;

  @override
  String toString() => """
    tokenType: $tokenType,
    expiresIn: $expiresIn,
    accessToken: $accessToken,
    refreshToken: $refreshToken,
  """;
}
