// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'navigation_task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NavigationTask {

 String get id;// 任务 ID
 String get senderId;// 发送者 ID
 String get receiverId;// 接收者 ID
 String get senderName;// 发送者昵称
 String get receiverName;// 接收者昵称
// 起点信息
 String get originName;// 起点名称
 double get originLat; double get originLng;// 终点信息
 String get destinationName;// 终点名称
 double get destinationLat; double get destinationLng;// 路线信息
 List<LatLng> get routePoints;// 路线坐标点列表
 double get distance;// 总距离（米）
 int get duration;// 预计时长（秒）
 String get strategy;// 路线策略
// 状态和时间
 String get status; DateTime get createdAt; DateTime? get acceptedAt; DateTime? get startedAt; DateTime? get completedAt; DateTime? get cancelledAt;// 备注
 String? get note;
/// Create a copy of NavigationTask
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NavigationTaskCopyWith<NavigationTask> get copyWith => _$NavigationTaskCopyWithImpl<NavigationTask>(this as NavigationTask, _$identity);

  /// Serializes this NavigationTask to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavigationTask&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.receiverId, receiverId) || other.receiverId == receiverId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.receiverName, receiverName) || other.receiverName == receiverName)&&(identical(other.originName, originName) || other.originName == originName)&&(identical(other.originLat, originLat) || other.originLat == originLat)&&(identical(other.originLng, originLng) || other.originLng == originLng)&&(identical(other.destinationName, destinationName) || other.destinationName == destinationName)&&(identical(other.destinationLat, destinationLat) || other.destinationLat == destinationLat)&&(identical(other.destinationLng, destinationLng) || other.destinationLng == destinationLng)&&const DeepCollectionEquality().equals(other.routePoints, routePoints)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.strategy, strategy) || other.strategy == strategy)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,senderId,receiverId,senderName,receiverName,originName,originLat,originLng,destinationName,destinationLat,destinationLng,const DeepCollectionEquality().hash(routePoints),distance,duration,strategy,status,createdAt,acceptedAt,startedAt,completedAt,cancelledAt,note]);

@override
String toString() {
  return 'NavigationTask(id: $id, senderId: $senderId, receiverId: $receiverId, senderName: $senderName, receiverName: $receiverName, originName: $originName, originLat: $originLat, originLng: $originLng, destinationName: $destinationName, destinationLat: $destinationLat, destinationLng: $destinationLng, routePoints: $routePoints, distance: $distance, duration: $duration, strategy: $strategy, status: $status, createdAt: $createdAt, acceptedAt: $acceptedAt, startedAt: $startedAt, completedAt: $completedAt, cancelledAt: $cancelledAt, note: $note)';
}


}

/// @nodoc
abstract mixin class $NavigationTaskCopyWith<$Res>  {
  factory $NavigationTaskCopyWith(NavigationTask value, $Res Function(NavigationTask) _then) = _$NavigationTaskCopyWithImpl;
@useResult
$Res call({
 String id, String senderId, String receiverId, String senderName, String receiverName, String originName, double originLat, double originLng, String destinationName, double destinationLat, double destinationLng, List<LatLng> routePoints, double distance, int duration, String strategy, String status, DateTime createdAt, DateTime? acceptedAt, DateTime? startedAt, DateTime? completedAt, DateTime? cancelledAt, String? note
});




}
/// @nodoc
class _$NavigationTaskCopyWithImpl<$Res>
    implements $NavigationTaskCopyWith<$Res> {
  _$NavigationTaskCopyWithImpl(this._self, this._then);

  final NavigationTask _self;
  final $Res Function(NavigationTask) _then;

/// Create a copy of NavigationTask
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? senderId = null,Object? receiverId = null,Object? senderName = null,Object? receiverName = null,Object? originName = null,Object? originLat = null,Object? originLng = null,Object? destinationName = null,Object? destinationLat = null,Object? destinationLng = null,Object? routePoints = null,Object? distance = null,Object? duration = null,Object? strategy = null,Object? status = null,Object? createdAt = null,Object? acceptedAt = freezed,Object? startedAt = freezed,Object? completedAt = freezed,Object? cancelledAt = freezed,Object? note = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,receiverId: null == receiverId ? _self.receiverId : receiverId // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,receiverName: null == receiverName ? _self.receiverName : receiverName // ignore: cast_nullable_to_non_nullable
as String,originName: null == originName ? _self.originName : originName // ignore: cast_nullable_to_non_nullable
as String,originLat: null == originLat ? _self.originLat : originLat // ignore: cast_nullable_to_non_nullable
as double,originLng: null == originLng ? _self.originLng : originLng // ignore: cast_nullable_to_non_nullable
as double,destinationName: null == destinationName ? _self.destinationName : destinationName // ignore: cast_nullable_to_non_nullable
as String,destinationLat: null == destinationLat ? _self.destinationLat : destinationLat // ignore: cast_nullable_to_non_nullable
as double,destinationLng: null == destinationLng ? _self.destinationLng : destinationLng // ignore: cast_nullable_to_non_nullable
as double,routePoints: null == routePoints ? _self.routePoints : routePoints // ignore: cast_nullable_to_non_nullable
as List<LatLng>,distance: null == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as double,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,strategy: null == strategy ? _self.strategy : strategy // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,acceptedAt: freezed == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NavigationTask].
extension NavigationTaskPatterns on NavigationTask {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NavigationTask value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NavigationTask() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NavigationTask value)  $default,){
final _that = this;
switch (_that) {
case _NavigationTask():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NavigationTask value)?  $default,){
final _that = this;
switch (_that) {
case _NavigationTask() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String senderId,  String receiverId,  String senderName,  String receiverName,  String originName,  double originLat,  double originLng,  String destinationName,  double destinationLat,  double destinationLng,  List<LatLng> routePoints,  double distance,  int duration,  String strategy,  String status,  DateTime createdAt,  DateTime? acceptedAt,  DateTime? startedAt,  DateTime? completedAt,  DateTime? cancelledAt,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NavigationTask() when $default != null:
return $default(_that.id,_that.senderId,_that.receiverId,_that.senderName,_that.receiverName,_that.originName,_that.originLat,_that.originLng,_that.destinationName,_that.destinationLat,_that.destinationLng,_that.routePoints,_that.distance,_that.duration,_that.strategy,_that.status,_that.createdAt,_that.acceptedAt,_that.startedAt,_that.completedAt,_that.cancelledAt,_that.note);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String senderId,  String receiverId,  String senderName,  String receiverName,  String originName,  double originLat,  double originLng,  String destinationName,  double destinationLat,  double destinationLng,  List<LatLng> routePoints,  double distance,  int duration,  String strategy,  String status,  DateTime createdAt,  DateTime? acceptedAt,  DateTime? startedAt,  DateTime? completedAt,  DateTime? cancelledAt,  String? note)  $default,) {final _that = this;
switch (_that) {
case _NavigationTask():
return $default(_that.id,_that.senderId,_that.receiverId,_that.senderName,_that.receiverName,_that.originName,_that.originLat,_that.originLng,_that.destinationName,_that.destinationLat,_that.destinationLng,_that.routePoints,_that.distance,_that.duration,_that.strategy,_that.status,_that.createdAt,_that.acceptedAt,_that.startedAt,_that.completedAt,_that.cancelledAt,_that.note);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String senderId,  String receiverId,  String senderName,  String receiverName,  String originName,  double originLat,  double originLng,  String destinationName,  double destinationLat,  double destinationLng,  List<LatLng> routePoints,  double distance,  int duration,  String strategy,  String status,  DateTime createdAt,  DateTime? acceptedAt,  DateTime? startedAt,  DateTime? completedAt,  DateTime? cancelledAt,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _NavigationTask() when $default != null:
return $default(_that.id,_that.senderId,_that.receiverId,_that.senderName,_that.receiverName,_that.originName,_that.originLat,_that.originLng,_that.destinationName,_that.destinationLat,_that.destinationLng,_that.routePoints,_that.distance,_that.duration,_that.strategy,_that.status,_that.createdAt,_that.acceptedAt,_that.startedAt,_that.completedAt,_that.cancelledAt,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NavigationTask implements NavigationTask {
  const _NavigationTask({required this.id, required this.senderId, required this.receiverId, required this.senderName, required this.receiverName, required this.originName, required this.originLat, required this.originLng, required this.destinationName, required this.destinationLat, required this.destinationLng, required final  List<LatLng> routePoints, required this.distance, required this.duration, required this.strategy, this.status = NavigationTaskStatuses.pending, required this.createdAt, this.acceptedAt, this.startedAt, this.completedAt, this.cancelledAt, this.note}): _routePoints = routePoints;
  factory _NavigationTask.fromJson(Map<String, dynamic> json) => _$NavigationTaskFromJson(json);

@override final  String id;
// 任务 ID
@override final  String senderId;
// 发送者 ID
@override final  String receiverId;
// 接收者 ID
@override final  String senderName;
// 发送者昵称
@override final  String receiverName;
// 接收者昵称
// 起点信息
@override final  String originName;
// 起点名称
@override final  double originLat;
@override final  double originLng;
// 终点信息
@override final  String destinationName;
// 终点名称
@override final  double destinationLat;
@override final  double destinationLng;
// 路线信息
 final  List<LatLng> _routePoints;
// 路线信息
@override List<LatLng> get routePoints {
  if (_routePoints is EqualUnmodifiableListView) return _routePoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_routePoints);
}

// 路线坐标点列表
@override final  double distance;
// 总距离（米）
@override final  int duration;
// 预计时长（秒）
@override final  String strategy;
// 路线策略
// 状态和时间
@override@JsonKey() final  String status;
@override final  DateTime createdAt;
@override final  DateTime? acceptedAt;
@override final  DateTime? startedAt;
@override final  DateTime? completedAt;
@override final  DateTime? cancelledAt;
// 备注
@override final  String? note;

/// Create a copy of NavigationTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NavigationTaskCopyWith<_NavigationTask> get copyWith => __$NavigationTaskCopyWithImpl<_NavigationTask>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NavigationTaskToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NavigationTask&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.receiverId, receiverId) || other.receiverId == receiverId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.receiverName, receiverName) || other.receiverName == receiverName)&&(identical(other.originName, originName) || other.originName == originName)&&(identical(other.originLat, originLat) || other.originLat == originLat)&&(identical(other.originLng, originLng) || other.originLng == originLng)&&(identical(other.destinationName, destinationName) || other.destinationName == destinationName)&&(identical(other.destinationLat, destinationLat) || other.destinationLat == destinationLat)&&(identical(other.destinationLng, destinationLng) || other.destinationLng == destinationLng)&&const DeepCollectionEquality().equals(other._routePoints, _routePoints)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.strategy, strategy) || other.strategy == strategy)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,senderId,receiverId,senderName,receiverName,originName,originLat,originLng,destinationName,destinationLat,destinationLng,const DeepCollectionEquality().hash(_routePoints),distance,duration,strategy,status,createdAt,acceptedAt,startedAt,completedAt,cancelledAt,note]);

@override
String toString() {
  return 'NavigationTask(id: $id, senderId: $senderId, receiverId: $receiverId, senderName: $senderName, receiverName: $receiverName, originName: $originName, originLat: $originLat, originLng: $originLng, destinationName: $destinationName, destinationLat: $destinationLat, destinationLng: $destinationLng, routePoints: $routePoints, distance: $distance, duration: $duration, strategy: $strategy, status: $status, createdAt: $createdAt, acceptedAt: $acceptedAt, startedAt: $startedAt, completedAt: $completedAt, cancelledAt: $cancelledAt, note: $note)';
}


}

/// @nodoc
abstract mixin class _$NavigationTaskCopyWith<$Res> implements $NavigationTaskCopyWith<$Res> {
  factory _$NavigationTaskCopyWith(_NavigationTask value, $Res Function(_NavigationTask) _then) = __$NavigationTaskCopyWithImpl;
@override @useResult
$Res call({
 String id, String senderId, String receiverId, String senderName, String receiverName, String originName, double originLat, double originLng, String destinationName, double destinationLat, double destinationLng, List<LatLng> routePoints, double distance, int duration, String strategy, String status, DateTime createdAt, DateTime? acceptedAt, DateTime? startedAt, DateTime? completedAt, DateTime? cancelledAt, String? note
});




}
/// @nodoc
class __$NavigationTaskCopyWithImpl<$Res>
    implements _$NavigationTaskCopyWith<$Res> {
  __$NavigationTaskCopyWithImpl(this._self, this._then);

  final _NavigationTask _self;
  final $Res Function(_NavigationTask) _then;

/// Create a copy of NavigationTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? senderId = null,Object? receiverId = null,Object? senderName = null,Object? receiverName = null,Object? originName = null,Object? originLat = null,Object? originLng = null,Object? destinationName = null,Object? destinationLat = null,Object? destinationLng = null,Object? routePoints = null,Object? distance = null,Object? duration = null,Object? strategy = null,Object? status = null,Object? createdAt = null,Object? acceptedAt = freezed,Object? startedAt = freezed,Object? completedAt = freezed,Object? cancelledAt = freezed,Object? note = freezed,}) {
  return _then(_NavigationTask(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,receiverId: null == receiverId ? _self.receiverId : receiverId // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,receiverName: null == receiverName ? _self.receiverName : receiverName // ignore: cast_nullable_to_non_nullable
as String,originName: null == originName ? _self.originName : originName // ignore: cast_nullable_to_non_nullable
as String,originLat: null == originLat ? _self.originLat : originLat // ignore: cast_nullable_to_non_nullable
as double,originLng: null == originLng ? _self.originLng : originLng // ignore: cast_nullable_to_non_nullable
as double,destinationName: null == destinationName ? _self.destinationName : destinationName // ignore: cast_nullable_to_non_nullable
as String,destinationLat: null == destinationLat ? _self.destinationLat : destinationLat // ignore: cast_nullable_to_non_nullable
as double,destinationLng: null == destinationLng ? _self.destinationLng : destinationLng // ignore: cast_nullable_to_non_nullable
as double,routePoints: null == routePoints ? _self._routePoints : routePoints // ignore: cast_nullable_to_non_nullable
as List<LatLng>,distance: null == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as double,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,strategy: null == strategy ? _self.strategy : strategy // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,acceptedAt: freezed == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$NavigationTaskList {

 List<NavigationTask> get tasks; int get total;
/// Create a copy of NavigationTaskList
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NavigationTaskListCopyWith<NavigationTaskList> get copyWith => _$NavigationTaskListCopyWithImpl<NavigationTaskList>(this as NavigationTaskList, _$identity);

  /// Serializes this NavigationTaskList to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavigationTaskList&&const DeepCollectionEquality().equals(other.tasks, tasks)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(tasks),total);

@override
String toString() {
  return 'NavigationTaskList(tasks: $tasks, total: $total)';
}


}

/// @nodoc
abstract mixin class $NavigationTaskListCopyWith<$Res>  {
  factory $NavigationTaskListCopyWith(NavigationTaskList value, $Res Function(NavigationTaskList) _then) = _$NavigationTaskListCopyWithImpl;
@useResult
$Res call({
 List<NavigationTask> tasks, int total
});




}
/// @nodoc
class _$NavigationTaskListCopyWithImpl<$Res>
    implements $NavigationTaskListCopyWith<$Res> {
  _$NavigationTaskListCopyWithImpl(this._self, this._then);

  final NavigationTaskList _self;
  final $Res Function(NavigationTaskList) _then;

/// Create a copy of NavigationTaskList
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tasks = null,Object? total = null,}) {
  return _then(_self.copyWith(
tasks: null == tasks ? _self.tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<NavigationTask>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [NavigationTaskList].
extension NavigationTaskListPatterns on NavigationTaskList {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NavigationTaskList value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NavigationTaskList() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NavigationTaskList value)  $default,){
final _that = this;
switch (_that) {
case _NavigationTaskList():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NavigationTaskList value)?  $default,){
final _that = this;
switch (_that) {
case _NavigationTaskList() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<NavigationTask> tasks,  int total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NavigationTaskList() when $default != null:
return $default(_that.tasks,_that.total);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<NavigationTask> tasks,  int total)  $default,) {final _that = this;
switch (_that) {
case _NavigationTaskList():
return $default(_that.tasks,_that.total);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<NavigationTask> tasks,  int total)?  $default,) {final _that = this;
switch (_that) {
case _NavigationTaskList() when $default != null:
return $default(_that.tasks,_that.total);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NavigationTaskList implements NavigationTaskList {
  const _NavigationTaskList({required final  List<NavigationTask> tasks, required this.total}): _tasks = tasks;
  factory _NavigationTaskList.fromJson(Map<String, dynamic> json) => _$NavigationTaskListFromJson(json);

 final  List<NavigationTask> _tasks;
@override List<NavigationTask> get tasks {
  if (_tasks is EqualUnmodifiableListView) return _tasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tasks);
}

@override final  int total;

/// Create a copy of NavigationTaskList
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NavigationTaskListCopyWith<_NavigationTaskList> get copyWith => __$NavigationTaskListCopyWithImpl<_NavigationTaskList>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NavigationTaskListToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NavigationTaskList&&const DeepCollectionEquality().equals(other._tasks, _tasks)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_tasks),total);

@override
String toString() {
  return 'NavigationTaskList(tasks: $tasks, total: $total)';
}


}

/// @nodoc
abstract mixin class _$NavigationTaskListCopyWith<$Res> implements $NavigationTaskListCopyWith<$Res> {
  factory _$NavigationTaskListCopyWith(_NavigationTaskList value, $Res Function(_NavigationTaskList) _then) = __$NavigationTaskListCopyWithImpl;
@override @useResult
$Res call({
 List<NavigationTask> tasks, int total
});




}
/// @nodoc
class __$NavigationTaskListCopyWithImpl<$Res>
    implements _$NavigationTaskListCopyWith<$Res> {
  __$NavigationTaskListCopyWithImpl(this._self, this._then);

  final _NavigationTaskList _self;
  final $Res Function(_NavigationTaskList) _then;

/// Create a copy of NavigationTaskList
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tasks = null,Object? total = null,}) {
  return _then(_NavigationTaskList(
tasks: null == tasks ? _self._tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<NavigationTask>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
