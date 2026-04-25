import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/poi_api.dart';
import '../../../models/location/lat_lng.dart';

/// ============================================
/// 位置分类 POI 列表 Service
///
/// 纯业务逻辑，无状态，不继承 ChangeNotifier
/// 负责从不同数据源获取各类别的 POI 列表
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

/// 绑定者位置项
class BindingLocationItem {
  final String userId;
  final String name;
  final LatLng location;
  final DateTime? lastUpdated;

  const BindingLocationItem({
    required this.userId,
    required this.name,
    required this.location,
    this.lastUpdated,
  });
}

/// 位置分类 POI 列表服务
class LocationCategoryService {
  static const String _storageKey = 'route_planning_history';
  static const int _maxHistoryItems = 20;

  static final LocationCategoryService _instance = LocationCategoryService._internal();
  factory LocationCategoryService() => _instance;
  LocationCategoryService._internal();

  List<HistoryLocationItem> _history = [];

  /// 获取历史记录
  List<HistoryLocationItem> get history => List.unmodifiable(_history);

  /// 添加历史记录
  Future<void> addToHistory({
    required String name,
    required String address,
    required LatLng location,
  }) async {
    _history.removeWhere(
      (item) => item.name == name && item.location == location,
    );

    _history.insert(
      0,
      HistoryLocationItem(
        name: name,
        address: address,
        location: location,
        timestamp: DateTime.now(),
      ),
    );

    if (_history.length > _maxHistoryItems) {
      _history = _history.sublist(0, _maxHistoryItems);
    }

    await _saveToStorage();
  }

  /// 清除历史记录
  Future<void> clearHistory() async {
    _history = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  /// 从存储加载
  Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _history = jsonList
            .map((json) => HistoryLocationItem.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _history = [];
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(_history.map((item) => item.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      // 忽略存储错误
    }
  }

  
  /// "绑定者" - 返回空（暂不实现，显示占位）
  List<PoiSuggestion> getBinderLocations() {
    return [];
  }

  /// "历史" - 从本地加载
  Future<List<PoiSuggestion>> getHistoryLocations() async {
    await loadFromStorage();
    return _history.map((item) {
      return PoiSuggestion(
        id: 'history_${item.timestamp.millisecondsSinceEpoch}',
        name: item.name,
        district: '',
        address: item.address,
        location: '${item.location.longitude},${item.location.latitude}',
      );
    }).toList();
  }
}