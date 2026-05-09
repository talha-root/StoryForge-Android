// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'story_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StoryMessage _$StoryMessageFromJson(Map<String, dynamic> json) {
  return _StoryMessage.fromJson(json);
}

/// @nodoc
mixin _$StoryMessage {
  @JsonKey(name: 'author_type', defaultValue: 'user')
  String get role => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this StoryMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StoryMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StoryMessageCopyWith<StoryMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoryMessageCopyWith<$Res> {
  factory $StoryMessageCopyWith(
    StoryMessage value,
    $Res Function(StoryMessage) then,
  ) = _$StoryMessageCopyWithImpl<$Res, StoryMessage>;
  @useResult
  $Res call({
    @JsonKey(name: 'author_type', defaultValue: 'user') String role,
    String content,
    @JsonKey(name: 'created_at') DateTime timestamp,
  });
}

/// @nodoc
class _$StoryMessageCopyWithImpl<$Res, $Val extends StoryMessage>
    implements $StoryMessageCopyWith<$Res> {
  _$StoryMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StoryMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? role = null,
    Object? content = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StoryMessageImplCopyWith<$Res>
    implements $StoryMessageCopyWith<$Res> {
  factory _$$StoryMessageImplCopyWith(
    _$StoryMessageImpl value,
    $Res Function(_$StoryMessageImpl) then,
  ) = __$$StoryMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'author_type', defaultValue: 'user') String role,
    String content,
    @JsonKey(name: 'created_at') DateTime timestamp,
  });
}

/// @nodoc
class __$$StoryMessageImplCopyWithImpl<$Res>
    extends _$StoryMessageCopyWithImpl<$Res, _$StoryMessageImpl>
    implements _$$StoryMessageImplCopyWith<$Res> {
  __$$StoryMessageImplCopyWithImpl(
    _$StoryMessageImpl _value,
    $Res Function(_$StoryMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StoryMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? role = null,
    Object? content = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$StoryMessageImpl(
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StoryMessageImpl implements _StoryMessage {
  const _$StoryMessageImpl({
    @JsonKey(name: 'author_type', defaultValue: 'user') required this.role,
    required this.content,
    @JsonKey(name: 'created_at') required this.timestamp,
  });

  factory _$StoryMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$StoryMessageImplFromJson(json);

  @override
  @JsonKey(name: 'author_type', defaultValue: 'user')
  final String role;
  @override
  final String content;
  @override
  @JsonKey(name: 'created_at')
  final DateTime timestamp;

  @override
  String toString() {
    return 'StoryMessage(role: $role, content: $content, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoryMessageImpl &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, role, content, timestamp);

  /// Create a copy of StoryMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StoryMessageImplCopyWith<_$StoryMessageImpl> get copyWith =>
      __$$StoryMessageImplCopyWithImpl<_$StoryMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StoryMessageImplToJson(this);
  }
}

abstract class _StoryMessage implements StoryMessage {
  const factory _StoryMessage({
    @JsonKey(name: 'author_type', defaultValue: 'user')
    required final String role,
    required final String content,
    @JsonKey(name: 'created_at') required final DateTime timestamp,
  }) = _$StoryMessageImpl;

  factory _StoryMessage.fromJson(Map<String, dynamic> json) =
      _$StoryMessageImpl.fromJson;

  @override
  @JsonKey(name: 'author_type', defaultValue: 'user')
  String get role;
  @override
  String get content;
  @override
  @JsonKey(name: 'created_at')
  DateTime get timestamp;

  /// Create a copy of StoryMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StoryMessageImplCopyWith<_$StoryMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
