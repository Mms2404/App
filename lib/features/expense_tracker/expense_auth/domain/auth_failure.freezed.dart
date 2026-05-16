// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AuthFailure {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() invalidCredentials,
    required TResult Function() network,
    required TResult Function(int statusCode) serverError,
    required TResult Function(String details) unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? invalidCredentials,
    TResult? Function()? network,
    TResult? Function(int statusCode)? serverError,
    TResult? Function(String details)? unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? invalidCredentials,
    TResult Function()? network,
    TResult Function(int statusCode)? serverError,
    TResult Function(String details)? unknown,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_InvalidCredentials value) invalidCredentials,
    required TResult Function(_Network value) network,
    required TResult Function(_ServerError value) serverError,
    required TResult Function(_Unknown value) unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_InvalidCredentials value)? invalidCredentials,
    TResult? Function(_Network value)? network,
    TResult? Function(_ServerError value)? serverError,
    TResult? Function(_Unknown value)? unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_InvalidCredentials value)? invalidCredentials,
    TResult Function(_Network value)? network,
    TResult Function(_ServerError value)? serverError,
    TResult Function(_Unknown value)? unknown,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthFailureCopyWith<$Res> {
  factory $AuthFailureCopyWith(
    AuthFailure value,
    $Res Function(AuthFailure) then,
  ) = _$AuthFailureCopyWithImpl<$Res, AuthFailure>;
}

/// @nodoc
class _$AuthFailureCopyWithImpl<$Res, $Val extends AuthFailure>
    implements $AuthFailureCopyWith<$Res> {
  _$AuthFailureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InvalidCredentialsImplCopyWith<$Res> {
  factory _$$InvalidCredentialsImplCopyWith(
    _$InvalidCredentialsImpl value,
    $Res Function(_$InvalidCredentialsImpl) then,
  ) = __$$InvalidCredentialsImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InvalidCredentialsImplCopyWithImpl<$Res>
    extends _$AuthFailureCopyWithImpl<$Res, _$InvalidCredentialsImpl>
    implements _$$InvalidCredentialsImplCopyWith<$Res> {
  __$$InvalidCredentialsImplCopyWithImpl(
    _$InvalidCredentialsImpl _value,
    $Res Function(_$InvalidCredentialsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InvalidCredentialsImpl extends _InvalidCredentials {
  const _$InvalidCredentialsImpl() : super._();

  @override
  String toString() {
    return 'AuthFailure.invalidCredentials()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InvalidCredentialsImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() invalidCredentials,
    required TResult Function() network,
    required TResult Function(int statusCode) serverError,
    required TResult Function(String details) unknown,
  }) {
    return invalidCredentials();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? invalidCredentials,
    TResult? Function()? network,
    TResult? Function(int statusCode)? serverError,
    TResult? Function(String details)? unknown,
  }) {
    return invalidCredentials?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? invalidCredentials,
    TResult Function()? network,
    TResult Function(int statusCode)? serverError,
    TResult Function(String details)? unknown,
    required TResult orElse(),
  }) {
    if (invalidCredentials != null) {
      return invalidCredentials();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_InvalidCredentials value) invalidCredentials,
    required TResult Function(_Network value) network,
    required TResult Function(_ServerError value) serverError,
    required TResult Function(_Unknown value) unknown,
  }) {
    return invalidCredentials(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_InvalidCredentials value)? invalidCredentials,
    TResult? Function(_Network value)? network,
    TResult? Function(_ServerError value)? serverError,
    TResult? Function(_Unknown value)? unknown,
  }) {
    return invalidCredentials?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_InvalidCredentials value)? invalidCredentials,
    TResult Function(_Network value)? network,
    TResult Function(_ServerError value)? serverError,
    TResult Function(_Unknown value)? unknown,
    required TResult orElse(),
  }) {
    if (invalidCredentials != null) {
      return invalidCredentials(this);
    }
    return orElse();
  }
}

abstract class _InvalidCredentials extends AuthFailure {
  const factory _InvalidCredentials() = _$InvalidCredentialsImpl;
  const _InvalidCredentials._() : super._();
}

/// @nodoc
abstract class _$$NetworkImplCopyWith<$Res> {
  factory _$$NetworkImplCopyWith(
    _$NetworkImpl value,
    $Res Function(_$NetworkImpl) then,
  ) = __$$NetworkImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$NetworkImplCopyWithImpl<$Res>
    extends _$AuthFailureCopyWithImpl<$Res, _$NetworkImpl>
    implements _$$NetworkImplCopyWith<$Res> {
  __$$NetworkImplCopyWithImpl(
    _$NetworkImpl _value,
    $Res Function(_$NetworkImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$NetworkImpl extends _Network {
  const _$NetworkImpl() : super._();

  @override
  String toString() {
    return 'AuthFailure.network()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$NetworkImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() invalidCredentials,
    required TResult Function() network,
    required TResult Function(int statusCode) serverError,
    required TResult Function(String details) unknown,
  }) {
    return network();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? invalidCredentials,
    TResult? Function()? network,
    TResult? Function(int statusCode)? serverError,
    TResult? Function(String details)? unknown,
  }) {
    return network?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? invalidCredentials,
    TResult Function()? network,
    TResult Function(int statusCode)? serverError,
    TResult Function(String details)? unknown,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_InvalidCredentials value) invalidCredentials,
    required TResult Function(_Network value) network,
    required TResult Function(_ServerError value) serverError,
    required TResult Function(_Unknown value) unknown,
  }) {
    return network(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_InvalidCredentials value)? invalidCredentials,
    TResult? Function(_Network value)? network,
    TResult? Function(_ServerError value)? serverError,
    TResult? Function(_Unknown value)? unknown,
  }) {
    return network?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_InvalidCredentials value)? invalidCredentials,
    TResult Function(_Network value)? network,
    TResult Function(_ServerError value)? serverError,
    TResult Function(_Unknown value)? unknown,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(this);
    }
    return orElse();
  }
}

abstract class _Network extends AuthFailure {
  const factory _Network() = _$NetworkImpl;
  const _Network._() : super._();
}

/// @nodoc
abstract class _$$ServerErrorImplCopyWith<$Res> {
  factory _$$ServerErrorImplCopyWith(
    _$ServerErrorImpl value,
    $Res Function(_$ServerErrorImpl) then,
  ) = __$$ServerErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int statusCode});
}

/// @nodoc
class __$$ServerErrorImplCopyWithImpl<$Res>
    extends _$AuthFailureCopyWithImpl<$Res, _$ServerErrorImpl>
    implements _$$ServerErrorImplCopyWith<$Res> {
  __$$ServerErrorImplCopyWithImpl(
    _$ServerErrorImpl _value,
    $Res Function(_$ServerErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? statusCode = null}) {
    return _then(
      _$ServerErrorImpl(
        null == statusCode
            ? _value.statusCode
            : statusCode // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$ServerErrorImpl extends _ServerError {
  const _$ServerErrorImpl(this.statusCode) : super._();

  @override
  final int statusCode;

  @override
  String toString() {
    return 'AuthFailure.serverError(statusCode: $statusCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServerErrorImpl &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, statusCode);

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServerErrorImplCopyWith<_$ServerErrorImpl> get copyWith =>
      __$$ServerErrorImplCopyWithImpl<_$ServerErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() invalidCredentials,
    required TResult Function() network,
    required TResult Function(int statusCode) serverError,
    required TResult Function(String details) unknown,
  }) {
    return serverError(statusCode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? invalidCredentials,
    TResult? Function()? network,
    TResult? Function(int statusCode)? serverError,
    TResult? Function(String details)? unknown,
  }) {
    return serverError?.call(statusCode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? invalidCredentials,
    TResult Function()? network,
    TResult Function(int statusCode)? serverError,
    TResult Function(String details)? unknown,
    required TResult orElse(),
  }) {
    if (serverError != null) {
      return serverError(statusCode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_InvalidCredentials value) invalidCredentials,
    required TResult Function(_Network value) network,
    required TResult Function(_ServerError value) serverError,
    required TResult Function(_Unknown value) unknown,
  }) {
    return serverError(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_InvalidCredentials value)? invalidCredentials,
    TResult? Function(_Network value)? network,
    TResult? Function(_ServerError value)? serverError,
    TResult? Function(_Unknown value)? unknown,
  }) {
    return serverError?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_InvalidCredentials value)? invalidCredentials,
    TResult Function(_Network value)? network,
    TResult Function(_ServerError value)? serverError,
    TResult Function(_Unknown value)? unknown,
    required TResult orElse(),
  }) {
    if (serverError != null) {
      return serverError(this);
    }
    return orElse();
  }
}

abstract class _ServerError extends AuthFailure {
  const factory _ServerError(final int statusCode) = _$ServerErrorImpl;
  const _ServerError._() : super._();

  int get statusCode;

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServerErrorImplCopyWith<_$ServerErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnknownImplCopyWith<$Res> {
  factory _$$UnknownImplCopyWith(
    _$UnknownImpl value,
    $Res Function(_$UnknownImpl) then,
  ) = __$$UnknownImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String details});
}

/// @nodoc
class __$$UnknownImplCopyWithImpl<$Res>
    extends _$AuthFailureCopyWithImpl<$Res, _$UnknownImpl>
    implements _$$UnknownImplCopyWith<$Res> {
  __$$UnknownImplCopyWithImpl(
    _$UnknownImpl _value,
    $Res Function(_$UnknownImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? details = null}) {
    return _then(
      _$UnknownImpl(
        null == details
            ? _value.details
            : details // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$UnknownImpl extends _Unknown {
  const _$UnknownImpl(this.details) : super._();

  @override
  final String details;

  @override
  String toString() {
    return 'AuthFailure.unknown(details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnknownImpl &&
            (identical(other.details, details) || other.details == details));
  }

  @override
  int get hashCode => Object.hash(runtimeType, details);

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnknownImplCopyWith<_$UnknownImpl> get copyWith =>
      __$$UnknownImplCopyWithImpl<_$UnknownImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() invalidCredentials,
    required TResult Function() network,
    required TResult Function(int statusCode) serverError,
    required TResult Function(String details) unknown,
  }) {
    return unknown(details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? invalidCredentials,
    TResult? Function()? network,
    TResult? Function(int statusCode)? serverError,
    TResult? Function(String details)? unknown,
  }) {
    return unknown?.call(details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? invalidCredentials,
    TResult Function()? network,
    TResult Function(int statusCode)? serverError,
    TResult Function(String details)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_InvalidCredentials value) invalidCredentials,
    required TResult Function(_Network value) network,
    required TResult Function(_ServerError value) serverError,
    required TResult Function(_Unknown value) unknown,
  }) {
    return unknown(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_InvalidCredentials value)? invalidCredentials,
    TResult? Function(_Network value)? network,
    TResult? Function(_ServerError value)? serverError,
    TResult? Function(_Unknown value)? unknown,
  }) {
    return unknown?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_InvalidCredentials value)? invalidCredentials,
    TResult Function(_Network value)? network,
    TResult Function(_ServerError value)? serverError,
    TResult Function(_Unknown value)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(this);
    }
    return orElse();
  }
}

abstract class _Unknown extends AuthFailure {
  const factory _Unknown(final String details) = _$UnknownImpl;
  const _Unknown._() : super._();

  String get details;

  /// Create a copy of AuthFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnknownImplCopyWith<_$UnknownImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
