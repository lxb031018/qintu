import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/poi_models.dart';
import '../../../models/location/lat_lng.dart';

/// ============================================
/// 位置分类 POI 列表 Service
///
/// 纯业务逻辑，无状态，不继承 ChangeNotifier
/// 仅负责数据转换和本地存储，不调用其他 service
/// 跨 feature 数据由 provider 层传入
/// ============================================

/// 历史记录项
class HistoryLocationItem {
  final String name;
  final String address;
  final LatLng location;
  final DateTime timestamp;

  const HistoryLocationItem({
    required this.name,
    required this.address,
    required this.location,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'lat': location.latitude,
        'lng': location.longitude,
        'timestamp': timestamp.millisecondsSinceEpoch,
      };

  factory HistoryLocationItem.fromJson(Map<String, dynamic> json) => HistoryLocationItem(
        name: json['name'] as String,
        address: json['address'] as String,
        location: LatLng(json['lat'] as double, json['lng'] as double),
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      );
}

/// 绑定者位置数据（由 provider 层从 relationship_binding 获取后传入）
class BinderLocationData {
  final String openid;
  final String nickname;
  final String? address;
  final double? lat;
  final double? lng;

  const BinderLocationData({
    required this.openid,
    required this.nickname,
    this.address,
    this.lat,
    this.lng,
  });
}

/// 位置分类 POI 列表服务
///
/// 无状态，所有数据操作都直接访问 storage 或通过参数传入
class LocationCategoryService {
  static const String _storageKey = 'route_planning_history';
  static const int _maxHistoryItems = 20;

  /// 添加历史记录
  Future<void> addToHistory({
    required String name,
    required String address,
    required LatLng location,
  }) async {
    final history = await _loadHistoryFromStorage();

    history.removeWhere(
      (item) => item.name == name && item.location == location,
    );

    history.insert(
      0,
      HistoryLocationItem(
        name: name,
        address: address,
        location: location,
        timestamp: DateTime.now(),
      ),
    );

    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }

    await _saveToStorage(history);
  }

  /// 删除指定的历史记录项
  Future<void> deleteHistoryItems(Set<String> poiIds) async {
    final history = await _loadHistoryFromStorage();

    final timestampsToRemove = <int>{};
    for (final id in poiIds) {
      if (id.startsWith('history_')) {
        final timestampStr = id.substring(8);
        final timestamp = int.tryParse(timestampStr);
        if (timestamp != null) {
          timestampsToRemove.add(timestamp);
        }
      }
    }

    history.removeWhere((item) => timestampsToRemove.contains(item.timestamp.millisecondsSinceEpoch));

    await _saveToStorage(history);
  }

  /// 从存储加载历史记录
  Future<List<HistoryLocationItem>> _loadHistoryFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList
            .map((json) => HistoryLocationItem.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // 忽略加载错误
    }
    return [];
  }

  Future<void> _saveToStorage(List<HistoryLocationItem> history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(history.map((item) => item.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      // 忽略存储错误
    }
  }

  /// "绑定者" - 将预获取的绑定者位置数据转换为 PoiSuggestion 列表
  ///
  /// [binders] 由 provider 层从 relationship_binding feature 获取并传入
  List<PoiSuggestion> getBinderLocations(List<BinderLocationData> binders) {
    return binders.where((b) => b.lat != null && b.lng != null).map((b) {
      return PoiSuggestion(
        id: b.openid,
        name: b.nickname,
        district: '',
        address: b.address ?? 'GPS定位',
        location: '${b.lng},${b.lat}',
        source: PoiSource.binder,
      );
    }).toList();
  }

  /// "历史" - 从本地加载
  Future<List<PoiSuggestion>> getHistoryLocations() async {
    final history = await _loadHistoryFromStorage();
    return history.map((item) {
      return PoiSuggestion(
        id: 'history_${item.timestamp.millisecondsSinceEpoch}',
        name: item.name,
        district: '',
        address: item.address,
        location: '${item.location.longitude},${item.location.latitude}',
        source: PoiSource.history,
      );
    }).toList();
  }
}

/// 全局单例
final locationCategoryService = LocationCategoryService();
